# Displays run start options
# 幕の開始地点で祝福のキャラ (BlessingContent) が出て、選ぶと演出つきで渡す (BlessingGiver)。
# 1幕目は主人公の型・装備 (BuildContent / ComboContent) だけ、2幕目以降は祝福のキャラの祝福を並べる。
# 選択肢は LoL のルーン選択風に、暗い背景の上へ縦の柱 (BlessingColumn) を横一列に並べる。
extends Control

var _option_type_to_option_ids: Dictionary = {}
const COMPLETE_OPTION_COUNT: int = 4	# 1幕目に並べる型・装備の数の上限 (BuildContent の武器 + ComboContent の昇り竜の型)
## 柱の列 (画面の下端・中央を基準に横一列。全画面で画面が広がっても中央の下に残る)
const COLUMN_WIDTH: float = 230.0	# 柱1本の幅の上限 (柱が少ない幕では細く寄せる)
const COLUMN_HEIGHT: float = 420.0
const ROW_MAX_WIDTH: float = 1150.0
const OPTION_BOTTOM: float = -12.0
const BACKDROP_COLOR := Color(0.02, 0.03, 0.06, 0.95)	# 背景の絵を沈める暗い濃紺
const BACKDROP_TOP: float = 64.0	# 上の HUD の帯は隠さない (受け取った祝福の光の玉が飛んでいく先)
const FAREWELL_TIME: float = 0.9	# 受け取ったあと、キャラが消えるまでの間

@onready var starting_option_container = $StartingOptionContainer
@onready var map = $%Map

var _giver: BlessingGiver
var _giver_data: DialogueData
var _is_choosing: bool = false
var _backdrop: ColorRect

func _ready():
	_aggregate_run_start_options()
	_giver = BlessingGiver.new()
	add_child(_giver)
	move_child(_giver, 0) # 選択肢より奥
	_backdrop = ColorRect.new()
	_backdrop.color = BACKDROP_COLOR
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.offset_top = BACKDROP_TOP
	add_child(_backdrop)
	move_child(_backdrop, 0) # 一番奥
	# シーン側のアンカー (右下) に左右されないよう、ここでアンカーも決める
	starting_option_container.anchor_left = 0.5
	starting_option_container.anchor_right = 0.5
	starting_option_container.anchor_top = 1.0
	starting_option_container.anchor_bottom = 1.0
	starting_option_container.offset_top = OPTION_BOTTOM - COLUMN_HEIGHT
	starting_option_container.offset_bottom = OPTION_BOTTOM
	starting_option_container.grow_vertical = Control.GROW_DIRECTION_BEGIN # 説明が長くても下端は画面の中に残る
	starting_option_container.add_theme_constant_override("separation", 0)
	Signals.run_started.connect(_on_run_started)
	Signals.player_killed.connect(_on_player_killed)
	Signals.run_ended.connect(_on_run_ended)
	Signals.map_location_selected.connect(_on_map_location_selected)
	Signals.act_started.connect(_on_act_started)

func _aggregate_run_start_options() -> void:
	# sorts the various options into boxes based on type
	for option_type in RunStartOptionData.RUN_START_OPTION_TYPES.values():
		_option_type_to_option_ids[option_type] = [] as Array[String]
	for run_start_option_data in Global._id_to_run_start_option_data.values() as Array[RunStartOptionData]:
		_option_type_to_option_ids[run_start_option_data.run_start_option_type].append(run_start_option_data.object_id)

func populate_run_start_options() -> void:
	# Presents a list of options to the player
	clear_run_start_options()
	_is_choosing = false
	visible = true
	_backdrop.modulate.a = 0.0
	create_tween().tween_property(_backdrop, "modulate:a", 1.0, 0.5)
	
	# 祝福のキャラを登場させる
	_giver_data = BlessingContent.get_giver_for_act(Global.player_data.player_act)
	var greet_state: DialogueStateData = BlessingContent.get_greet_state(_giver_data)
	_giver.show_giver(FileLoader.load_texture(greet_state.dialogue_state_dialogue_texture_path), tr(_giver_data.dialogue_name_bbcode), tr(greet_state.dialogue_state_prompt_bbcode))
	
	if Global.player_data.player_act == 1:
		_add_starting_gear()
	else:
		_add_blessings()
	_layout_columns()

## 1幕目: 主人公の型・装備だけを並べる (LoL のルーンのように主人公ごとに決まった選択肢。汎用の祝福とボスレリック交換は出さない)
func _add_starting_gear() -> void:
	var complete_option_ids: Array[String] = []
	complete_option_ids.assign(_option_type_to_option_ids[RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE].filter(
		func(id: String) -> bool:
			var option: RunStartOptionData = Global.get_run_start_option_data(id)
			var is_swap: bool = option.run_start_option_actions.any(func(a: Dictionary) -> bool: return a.has(Scripts.ACTION_SWAP_BOSS_ARTIFACT))
			return option.is_offered_to(Global.player_data.player_character_object_id) and not is_swap))
	for i in min(COMPLETE_OPTION_COUNT, len(complete_option_ids)):
		var complete_run_start_option_data: RunStartOptionData = Global.get_run_start_option_data(complete_option_ids.pop_back())
		var option_bbcode: String = tr(complete_run_start_option_data.run_start_option_bb_code)
		_add_option(option_bbcode, option_bbcode, complete_run_start_option_data.run_start_option_actions, [], tr("Starting gear"))

## 2幕目以降: 祝福のキャラの祝福 (小さな祝福 + 代償つきの大きな祝福)
func _add_blessings() -> void:
	var rng_run_start_options: RandomNumberGenerator = Global.player_data.get_player_rng("rng_run_start_options")
	for option_data: DialogueOptionData in BlessingContent.pick_blessings(_giver_data, rng_run_start_options):
		var parts: Array[Dictionary] = BlessingColumn.parts_of(option_data.dialogue_option_actions)
		var summary: String = tr("Great blessing, at a cost") if parts.any(func(p): return p.cost) else tr("Small blessing")
		_add_option(tr(option_data.dialogue_option_bbcode), tr(option_data.dialogue_option_failed_validator_bbcode), option_data.dialogue_option_actions, option_data.dialogue_option_validators, summary)

## 選択肢の柱を1本足す
func _add_option(option_bbcode: String, failed_bbcode: String, actions: Array[Dictionary], validators: Array[Dictionary], summary: String) -> void:
	var column := BlessingColumn.new()
	starting_option_container.add_child(column)
	column.init("", option_bbcode, failed_bbcode, actions, validators)
	column.setup(actions, summary)
	column.dialogue_option_clicked.connect(_on_dialogue_option_clicked)

## 柱の数に合わせて列の幅を決め、画面の中央に寄せて左から順に出す
func _layout_columns() -> void:
	var columns: Array[Node] = starting_option_container.get_children().filter(func(c): return not c.is_queued_for_deletion())
	var row_width: float = min(columns.size() * COLUMN_WIDTH, ROW_MAX_WIDTH)
	starting_option_container.offset_left = -row_width / 2.0
	starting_option_container.offset_right = row_width / 2.0
	for i in columns.size():
		(columns[i] as BlessingColumn).appear(0.3 + i * 0.07)
	
func clear_run_start_options() -> void:
	for child in starting_option_container.get_children():
		child.queue_free()
	
func _on_dialogue_option_clicked(dialogue_option: DialogueOption):
	if _is_choosing:
		return # 演出中の2回目のクリックは無視
	_is_choosing = true
	
	# 選んだ柱は光ったまま、選ばなかった柱は暗く沈める
	for child: BlessingColumn in starting_option_container.get_children():
		child.option_enabled = false
		if child == dialogue_option:
			child.select()
		else:
			child.dim()
	
	# キャラが光り、光の玉が受け取り先の HUD へ飛ぶ
	var gift_state: DialogueStateData = BlessingContent.get_gift_state(_giver_data)
	await _giver.bless(tr(gift_state.dialogue_state_prompt_bbcode), _get_reward_target(dialogue_option.action_data))
	
	var player: Player = Global.get_player()
	# generate fake card play request
	var card_play_request: CardPlayRequest = HandManager.create_card_play_request(null, player, false, false)
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(player, card_play_request, [player], dialogue_option.action_data, null)
	ActionHandler.add_actions(generated_actions)
	
	if ActionHandler.actions_being_performed:
		await ActionHandler.actions_ended
	clear_run_start_options()
	await get_tree().create_timer(FAREWELL_TIME).timeout
	create_tween().tween_property(_backdrop, "modulate:a", 0.0, 0.4)
	await _giver.hide_giver()
	visible = false
	
	map.can_travel = true
	map.show_map()

## 祝福の中身から、光の玉が飛んでいく HUD の項目を選ぶ (代償より得るものを優先)
func _get_reward_target(action_data: Array[Dictionary]) -> Control:
	var targets: Array = [
		[[Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL, Scripts.ACTION_ADD_ARTIFACT, Scripts.ACTION_SWAP_BOSS_ARTIFACT], "ArtifactContainer"],
		[[Scripts.ACTION_ADD_CONSUMABLE], "Consumables"],
		[[Scripts.ACTION_PICK_CARDS], "DeckButton"],
		[[Scripts.ACTION_ADD_MONEY], "MoneyLabel"],
		[[Scripts.ACTION_ADD_HEALTH], "HealthLabel"],
	]
	var scripts: Array = []
	for action: Dictionary in action_data:
		scripts.append_array(action.keys())
	for target: Array in targets:
		for script_path: String in target[0]:
			if scripts.has(script_path):
				return get_tree().root.find_child(target[1], true, false) as Control
	return null
	
func _on_run_started():
	visible = false
	clear_run_start_options()
	
func _on_run_ended():
	visible = false
	clear_run_start_options()

func _on_player_killed(_player: Player) -> void:
	visible = false
	clear_run_start_options()

func _on_map_location_selected(location_data: LocationData):
	# determine what to do when the player visits a new location
	var location_type: int = location_data.location_type

	visible = false
	match location_type:
		LocationData.LOCATION_TYPES.STARTING:
			populate_run_start_options()

## 2幕目以降: 前の幕のボスを倒して次の幕へ進んだら、また祝福のキャラが来る
func _on_act_started():
	map.can_travel = false
	map.hide_map()
	populate_run_start_options()
