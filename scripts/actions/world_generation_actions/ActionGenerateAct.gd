## Generates the world map for an act (Slay the Spire 2 style).
## See: ActionGenerator.generate_act() and generate_next_act(), docs/PLAN.md (StS2 調査)
##
## 1. 7列 x N行 (Act1=15, Act2=14, Act3=13) の格子に、下から上へ 6 本の経路を引く (交差しない)
## 2. 経路が通った格子点だけを部屋にし、StS2 の「1幕あたりの個数」方式で部屋の種類を割り当てる
##    - 1行目: 敵 / 最後から7行目: 宝箱 / 最終行: 休憩所 / その上: ボス
##    - エリート5・商人3・?(Act1 10〜14, 以降 9〜13)・休憩(Act1/2 6〜7, Act3 5〜6)、残りは敵
##    - 最初の5行にエリート・休憩を置かない、最終行の1つ下に休憩を置かない
##    - エリート/商人/休憩は親子で連続させない、同じ親の子どうしで同種を避ける
## 3. 「?」の中身は 敵10%/商人3%/宝箱2% から始まり、外れるたびに +10/+3/+2 (当たると初期値へ)
## 4. 表示位置は格子に少しランダムなずれを加える (縦に約3画面分)
extends BaseAction

const COLUMNS := 7
const PATHS := 6
const FLOORS_BY_ACT := {1: 15, 2: 14, 3: 13}
const MIN_ELITE_REST_FLOOR := 6	# 1始まり
const TREASURE_FROM_TOP := 7	# 最後から何行目が宝箱か
const EASY_COMBATS_BY_ACT := {1: 3, 2: 2, 3: 2}	# 最初の何戦が弱いプールか (階で近似)

## 1幕あたりの部屋数 [最小, 最大] (StS2)
const ELITE_COUNT := 5
const SHOP_COUNT := 3
const UNKNOWN_COUNT_BY_ACT := {1: [10, 14], 2: [9, 13], 3: [9, 13]}
const REST_COUNT_BY_ACT := {1: [6, 7], 2: [6, 7], 3: [5, 6]}

## 「?」の中身の初期確率と、外れた時の増分
const UNKNOWN_BASE := {
	LocationData.LOCATION_TYPES.COMBAT: 0.10,
	LocationData.LOCATION_TYPES.TREASURE: 0.02,
	LocationData.LOCATION_TYPES.SHOP: 0.03,
}
const NO_CONSECUTIVE := [LocationData.LOCATION_TYPES.MINIBOSS, LocationData.LOCATION_TYPES.SHOP, LocationData.LOCATION_TYPES.REST_SITE]

## レイアウト (MapLocation は 64px, 左上基準)
const MAP_WIDTH := 888.0
const COLUMN_SPACING := 112.0
const FLOOR_SPACING := 136.0
const JITTER := Vector2(20, 16)
const TOP_MARGIN := 230.0	# ボスのイラスト用

var rng: RandomNumberGenerator
var FLOORS := 15
var unknown_chances := {}


func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var rng_name: String = action_interceptor_processor.get_shadowed_action_values("rng_name", "rng_world_generation")
		rng = Global.player_data.get_player_rng(rng_name)

		var act_id: String = get_action_value("act_id", "")
		var act_data: ActData = Global.get_act_data(act_id)
		var act_number: int = get_action_value("act_number", Global.player_data.player_act)
		Global.player_data.player_act_id = act_id
		Global.player_data.player_act = act_number
		FLOORS = FLOORS_BY_ACT.get(act_number, 13)
		unknown_chances = UNKNOWN_BASE.duplicate()	# 幕ごとにリセット

		var start_floor := _make_start_floor(act_number)
		var grid := _build_paths()	# grid[floor][col] = Array[int] (次の階の列) / 部屋が無ければ null
		var types := _assign_types(grid, act_number)
		var rooms := _create_rooms(grid, types, act_number, act_data)
		_connect(grid, rooms, start_floor, act_number, act_data)


#region Paths

func _build_paths() -> Array:
	var grid := []
	for f in FLOORS:
		var row := []
		row.resize(COLUMNS)
		grid.append(row)
	var first_start := -1
	for p in PATHS:
		var col := rng.randi_range(0, COLUMNS - 1)
		# 最初の2本は別の列から始める
		while p == 1 and col == first_start:
			col = rng.randi_range(0, COLUMNS - 1)
		if p == 0:
			first_start = col
		for f in FLOORS:
			if grid[f][col] == null:
				grid[f][col] = []
			if f == FLOORS - 1:
				break
			var next_col := _choose_next(grid, f, col)
			if not grid[f][col].has(next_col):
				grid[f][col].append(next_col)
			col = next_col
	return grid


## 斜めの辺が既存の辺と交差しない次の列を選ぶ
func _choose_next(grid: Array, f: int, col: int) -> int:
	var options := [col - 1, col, col + 1].filter(func(c): return c >= 0 and c < COLUMNS)
	options.shuffle()
	for next_col in options:
		if not _crosses(grid, f, col, next_col):
			return next_col
	return col


func _crosses(grid: Array, f: int, col: int, next_col: int) -> bool:
	if next_col == col:
		return false
	# 右上へ行くなら、右隣から左上へ行く辺と交差する (左も同様)
	var neighbor: int = next_col	# col+1 or col-1
	var edges = grid[f][neighbor]
	return edges != null and edges.has(col)

#endregion

#region Room types

func _assign_types(grid: Array, act_number: int) -> Dictionary:
	var types := {}	# Vector2i(col, floor) -> type
	var parents := {}	# Vector2i -> Array[Vector2i]
	for f in FLOORS:
		for col in COLUMNS:
			if grid[f][col] == null:
				continue
			for next_col in grid[f][col]:
				var key := Vector2i(next_col, f + 1)
				if not parents.has(key):
					parents[key] = []
				parents[key].append(Vector2i(col, f))
	# 固定の行
	var free_keys: Array[Vector2i] = []
	for f in FLOORS:
		for col in COLUMNS:
			if grid[f][col] == null:
				continue
			var key := Vector2i(col, f)
			if f == 0:
				types[key] = LocationData.LOCATION_TYPES.COMBAT
			elif f == FLOORS - TREASURE_FROM_TOP:
				types[key] = LocationData.LOCATION_TYPES.TREASURE
			elif f == FLOORS - 1:
				types[key] = LocationData.LOCATION_TYPES.REST_SITE
			else:
				free_keys.append(key)
	# 個数ぶんの袋を作り、下の階から順に「置けるもの」を袋から取り出す
	var bag: Array[int] = []
	_fill(bag, LocationData.LOCATION_TYPES.MINIBOSS, ELITE_COUNT)
	_fill(bag, LocationData.LOCATION_TYPES.SHOP, SHOP_COUNT)
	_fill(bag, LocationData.LOCATION_TYPES.EVENT, _gaussian_count(UNKNOWN_COUNT_BY_ACT.get(act_number, [9, 13])))
	var rest_range: Array = REST_COUNT_BY_ACT.get(act_number, [5, 6])
	_fill(bag, LocationData.LOCATION_TYPES.REST_SITE, rng.randi_range(rest_range[0], rest_range[1]))
	while bag.size() < free_keys.size():
		bag.append(LocationData.LOCATION_TYPES.COMBAT)
	_shuffle(bag)
	for key in free_keys:
		types[key] = LocationData.LOCATION_TYPES.COMBAT
		for i in bag.size():
			if _allowed(bag[i], key, key.y + 1, types, parents.get(key, []), grid):
				types[key] = bag[i]
				bag.remove_at(i)
				break
	return types


func _fill(bag: Array[int], type: int, count: int) -> void:
	for i in count:
		bag.append(type)


func _shuffle(bag: Array[int]) -> void:
	for i in range(bag.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t := bag[i]
		bag[i] = bag[j]
		bag[j] = t


## [最小, 最大] の範囲で中央に寄った整数
func _gaussian_count(range_minmax: Array) -> int:
	var mean: float = (range_minmax[0] + range_minmax[1]) / 2.0
	return clampi(roundi(rng.randfn(mean, 1.0)), range_minmax[0], range_minmax[1])


func _allowed(type: int, key: Vector2i, floor_number: int, types: Dictionary, parent_keys: Array, grid: Array) -> bool:
	if type in [LocationData.LOCATION_TYPES.MINIBOSS, LocationData.LOCATION_TYPES.REST_SITE] and floor_number < MIN_ELITE_REST_FLOOR:
		return false
	if type == LocationData.LOCATION_TYPES.REST_SITE and floor_number >= FLOORS - 1:
		return false
	for parent in parent_keys:
		# 親子で連続させない
		if type in NO_CONSECUTIVE and types.get(parent) == type:
			return false
		# 同じ親の他の子 (決定済み) と同種を避ける
		if type != LocationData.LOCATION_TYPES.COMBAT:
			for sibling_col in grid[parent.y][parent.x]:
				var sibling := Vector2i(sibling_col, key.y)
				if sibling != key and types.get(sibling) == type:
					return false
	return true


## 「?」の中身を決める。外れた種類は確率が上がり、当たった種類は初期値に戻る
func _roll_unknown() -> int:
	var roll := rng.randf()
	var result := LocationData.LOCATION_TYPES.EVENT
	var threshold := 0.0
	for type in unknown_chances:
		threshold += unknown_chances[type]
		if result == LocationData.LOCATION_TYPES.EVENT and roll < threshold:
			result = type
	for type in unknown_chances:
		unknown_chances[type] = UNKNOWN_BASE[type] if type == result else unknown_chances[type] + UNKNOWN_BASE[type]
	return result

#endregion

#region LocationData

func _create_rooms(grid: Array, types: Dictionary, act_number: int, act_data: ActData) -> Dictionary:
	var rooms := {}
	var left := (MAP_WIDTH - COLUMN_SPACING * (COLUMNS - 1)) / 2.0 - 32.0
	for f in FLOORS:
		for col in COLUMNS:
			if grid[f][col] == null:
				continue
			var key := Vector2i(col, f)
			var location := _new_location(act_number, f + 1)
			location.location_index = Vector2(col, f)
			location.location_position = Vector2(left + col * COLUMN_SPACING, _floor_y(f)) + Vector2(
				rng.randf_range(-JITTER.x, JITTER.x), rng.randf_range(-JITTER.y, JITTER.y))
			_set_type(location, types[key], f + 1, act_data)
			rooms[key] = location
	return rooms


func _set_type(location: LocationData, type: int, floor_number: int, act_data: ActData) -> void:
	location.location_type = type
	match type:
		LocationData.LOCATION_TYPES.COMBAT:
			var easy_floors: int = EASY_COMBATS_BY_ACT.get(location.location_act, 2)
			location.location_event_pool_object_id = act_data.act_easy_combat_event_pool_object_id if floor_number <= easy_floors else act_data.act_hard_combat_event_pool_object_id
		LocationData.LOCATION_TYPES.MINIBOSS:
			location.location_event_pool_object_id = act_data.act_miniboss_event_pool_object_id
		LocationData.LOCATION_TYPES.EVENT:
			# 「?」: 訪れるまで中身は分からない (たまに敵・商人・宝箱)
			location.location_obfuscated = true
			var outcome := _roll_unknown()
			if outcome != LocationData.LOCATION_TYPES.EVENT:
				_set_type(location, outcome, floor_number, act_data)
				location.location_obfuscated = true
			else:
				location.location_event_pool_object_id = act_data.act_non_combat_event_pool_object_id


func _new_location(act_number: int, floor_number: int) -> LocationData:
	var location := LocationData.new()
	location.location_id = "location_%d_%d" % [act_number, Global.player_data.location_id_to_location_data.size() + 1]
	location.location_act = act_number
	location.location_floor = floor_number
	Global.player_data.location_id_to_location_data[location.location_id] = location
	return location


func _floor_y(f: int) -> float:
	# f=0 が一番下
	return TOP_MARGIN + (FLOORS - 1 - f) * FLOOR_SPACING + FLOOR_SPACING


func _make_start_floor(act_number: int) -> LocationData:
	if act_number == 1:
		Global.clear_locations()
		var start := LocationData.new()
		start.location_id = "location_0"
		start.location_act = 1
		start.location_floor = 0
		start.location_type = LocationData.LOCATION_TYPES.STARTING
		start.location_event_object_id = "event_act_1_easy_combat_1"
		start.location_position = Vector2(MAP_WIDTH / 2.0 - 32.0, _floor_y(-1))
		Global.player_data.location_id_to_location_data[start.location_id] = start
		Global.player_data.player_location_id = start.location_id
		return start
	# 2幕目以降: 前の幕のボス部屋を起点にする
	var current := Global.get_player_location_data()
	Global.clear_locations()
	current.location_next_location_ids.clear()
	Global.player_data.location_id_to_location_data[current.location_id] = current
	return current


func _connect(grid: Array, rooms: Dictionary, start: LocationData, act_number: int, act_data: ActData) -> void:
	for key: Vector2i in rooms:
		var location: LocationData = rooms[key]
		if key.y == 0:
			start.location_next_location_ids.append(location.location_id)
		for next_col in grid[key.y][key.x]:
			var next_key := Vector2i(next_col, key.y + 1)
			if rooms.has(next_key):
				location.location_next_location_ids.append(rooms[next_key].location_id)
	# ボス
	var boss := _new_location(act_number, FLOORS + 1)
	boss.location_type = LocationData.LOCATION_TYPES.BOSS
	boss.location_event_pool_object_id = act_data.act_boss_event_pool_object_id
	boss.location_index = Vector2((COLUMNS - 1) / 2.0, FLOORS)
	boss.location_position = Vector2(MAP_WIDTH / 2.0 - 32.0, TOP_MARGIN - 40.0)
	for key: Vector2i in rooms:
		if key.y == FLOORS - 1:
			rooms[key].location_next_location_ids.append(boss.location_id)

#endregion
