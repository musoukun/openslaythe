extends Node
class_name PlaythroughBot
## 開発用: タイトルから最終ボスまで、マウスのクリックだけでランを通しで遊ぶ (DevAutoPilot の --auto=playthrough)。
## クリックは Viewport の GUI に流すので、本物のマウスと同じく「上に何かが被っていると押せない」。
## 押そうとした場所に別の Control が被っていたら BLOCKED として出力する (本物のカーソルは動かさない)。
## 出力は "PLAY ..." の行。詰まり (同じ状態が続く) は STUCK、終わりは RESULT。

const TICK := 0.25 # 1手ごとの待ち (ゲーム内時間)
const STUCK_SECONDS := 40.0 # 同じ状態がこれだけ続いたら詰まりとみなす
const GIVE_UP_SECONDS := 120.0

var hero_id: String = "character_green"
var run_seed: int = 12345
## テスト専用: 自分のターンの始めに体力を満タンに戻す (ボットが弱くても最後の画面まで流れを確かめるため。ゲームの数値は変えない)
var god_mode: bool = false

var _root: Node
var _last_signature: String = ""
var _same_since: float = 0.0
var _stuck_reported: bool = false
var _failed_cards: Dictionary = {} # このターンにクリックしても何も起きなかったカード
var _turn_key: String = ""
var _visited_types: Dictionary = {}
var _shop_step: int = 0
var _rest_done: bool = false
var _blocked_seen: Dictionary = {}
var _clock: float = 0.0
## 撮影先 (--shots=<フォルダ>)。ウィンドウがあるときだけ撮る (headless では絵が描かれない)
var shots_dir: String = ""
var _shots_taken: Dictionary = {}


func run() -> void:
	_root = get_tree().root
	Signals.player_turn_started.connect(_on_player_turn_started)
	Signals.map_location_selected.connect(_on_location_selected)
	var map := _find("Map") as Control
	map.visibility_changed.connect(func(): if map.visible: _log("MAP shown by %s" % [get_stack().slice(1, 6).map(func(f): return "%s:%d" % [f.source.get_file(), f.line])]))
	await _start_run_from_title()
	while true:
		await _wait(TICK)
		var state := _detect_state()
		if state == "victory" or state == "defeat":
			await _shot(state)
			_log("RESULT %s act=%d floor=%s %s" % [state, Global.player_data.player_act, _floor(), _summary()])
			return
		_watch_stuck(state)
		if _clock - _same_since > GIVE_UP_SECONDS:
			_log("RESULT stuck state=%s act=%d floor=%s %s" % [state, Global.player_data.player_act, _floor(), _summary()])
			return
		await _act(state)


#region 状態の判定

func _detect_state() -> String:
	if _visible("RunSummaryOverlay"):
		return "victory" if _find("RunSummaryOverlay").victory_label.visible else "defeat"
	if _visible("DeathScreen"):
		return "death_screen"
	if _visible("CardSelectionOverlay"):
		return "card_selection"
	if _visible("CardDraftSelectionOverlay"):
		return "card_draft"
	if HandManager.hand.card_picking.is_visible_in_tree():
		return "hand_pick"
	if _visible("RunStartOptions"):
		return "blessing"
	if _visible("DialogueOverlay"):
		return "event"
	if _visible("Map") and _find("Map").can_travel:
		return "map" # 報酬画面の「進む」でマップが上に開く (報酬画面は下に残る)
	if _visible("RewardOverlay"):
		return "reward"
	if _find("Combat").chest.is_visible_in_tree():
		return "chest"
	if _visible("ShopOverlay"):
		return "shop"
	if _visible("RestOverlay"):
		return "rest"
	if _visible("Map"):
		return "map"
	if not Global.get_alive_enemies().is_empty():
		return "combat"
	return "waiting"


## 同じ状態が長く続いたら一度だけ詰まりとして出力する
func _watch_stuck(state: String) -> void:
	var signature := "%s|%s|%s|%s|%s|%s" % [state, _floor(), Global.player_data.player_health, HandManager.player_hand.size(), Global.player_data.player_energy,
		Global.get_alive_enemies().map(func(e): return e.get_combatant_health())]
	if signature != _last_signature:
		_last_signature = signature
		_same_since = _clock
		_stuck_reported = false
	elif not _stuck_reported and _clock - _same_since > STUCK_SECONDS:
		_stuck_reported = true
		_log("STUCK state=%s for %ds act=%d floor=%s %s overlays=%s" % [state, int(_clock - _same_since), Global.player_data.player_act, _floor(), _summary(), _visible_overlays()])
#endregion


#region 状態ごとの操作

func _act(state: String) -> void:
	match state:
		"death_screen":
			var button: Button = _find("DeathScreen")._continue_button
			if not button.disabled:
				await click(button, "death continue")
		"card_selection":
			await _card_selection()
		"card_draft":
			var cards := _cards_in(_find("CardDraftSelectionOverlay").card_container)
			if cards.is_empty():
				await click(_find("CardDraftSelectionOverlay").skip_button, "draft skip")
			else:
				_log("DRAFT pick %s from %s" % [cards[0].card_data.object_id, cards.map(func(c): return c.card_data.object_id)])
				await click(cards[0].card_button, "draft card")
		"hand_pick":
			await _hand_pick()
		"blessing":
			await _wait(2.5) # 祝福のキャラが出てきて選択肢が並ぶまで待つ
			await _shot("blessing_act%d" % Global.player_data.player_act)
			await _click_first_option(_find("RunStartOptions"), "blessing")
		"event":
			await _click_first_option(_find("DialogueOverlay"), "event")
		"reward":
			var overlay := _find("RewardOverlay")
			var buttons: Array = overlay.reward_container.get_children().filter(func(b): return b is BaseButton and b.visible and not b.is_queued_for_deletion())
			if buttons.is_empty():
				await click(overlay.continue_button, "reward continue")
			else:
				await click(buttons[0], "reward " + buttons[0].name)
		"chest":
			await click(_find("Combat").chest, "chest")
		"shop":
			await _shop()
		"rest":
			await _rest()
		"map":
			await _map()
		"combat":
			await _combat()


func _card_selection() -> void:
	var overlay := _find("CardSelectionOverlay")
	var action = overlay.current_card_pick_action
	if action == null:
		await click(overlay.back_button, "card list back")
		return
	if overlay.confirm_button.visible:
		await click(overlay.confirm_button, "card pick confirm")
		return
	for card: Card in _cards_in(overlay.card_container):
		if action.is_card_pickable(card.card_data, false) and not action.picked_cards.has(card.card_data):
			_log("PICK %s (%s)" % [card.card_data.object_id, action.get_card_pick_text()])
			await click(card.card_button, "card pick")
			return
	if overlay.back_button.visible:
		await click(overlay.back_button, "card pick back")


func _hand_pick() -> void:
	var hand: Hand = HandManager.hand
	var action := hand.current_card_pick_action
	if action != null and not action.are_enough_cards_picked():
		for card: Card in hand.get_player_hand_cards():
			if action.is_card_pickable(card.card_data, false) and not action.picked_cards.has(card.card_data):
				await click(card.card_button, "hand pick")
				return
	await click(hand.confirm_pick_button, "hand pick confirm")


func _click_first_option(overlay: Node, label: String) -> void:
	for option: DialogueOption in overlay.find_children("*", "DialogueOption", true, false):
		if option.is_visible_in_tree() and option.option_enabled:
			_log("%s option: %s rect=%s" % [label.to_upper(), option.rich_text_label.get_parsed_text().strip_edges().replace("\n", " "), option.get_global_rect()])
			await click(option, label + " option")
			await _wait(1.0)
			return


## ショップ: 商人を押してカウンターを開き、買えるカードを1枚買って戻り、「次へ」で出る
func _shop() -> void:
	var overlay := _find("ShopOverlay")
	match _shop_step:
		0:
			await _wait(1.0)
			await click(overlay.scene._merchant, "shop merchant")
			_shop_step = 1
		1:
			_shop_step = 2
			for item: Control in overlay.get_shop_items():
				if item.get("card") is Card and int(item.price_label.text) <= Global.player_data.player_money:
					var money := Global.player_data.player_money
					await click(item.card.card_button, "shop buy card")
					await _wait(1.0)
					_log("SHOP bought %s money %d -> %d deck=%d" % [item.card.card_data.object_id if is_instance_valid(item) else "?", money, Global.player_data.player_money, Global.player_data.player_deck.size()])
					return
			_log("SHOP nothing affordable (money %d)" % Global.player_data.player_money)
		2:
			await click(overlay.counter.find_child("BackButton", true, false), "shop counter back")
			_shop_step = 3
		_:
			await click(overlay.scene._next_button, "shop next")


## 休憩所: 体力が少なければ休む、多ければ鍛える (タイルの並びから名前で探す)。1つ選んだら先へ
func _rest() -> void:
	var overlay := _find("RestOverlay")
	if _rest_done:
		await click(overlay.continue_button, "rest continue")
		return
	await _wait(1.0)
	var buttons: Array = overlay.rest_action_container.get_children().filter(func(b): return b is RestActionButton and not b.disabled)
	var low_health: bool = Global.player_data.player_health * 2 < Global.player_data.player_health_max
	var wanted := "rest_action_rest" if low_health else "rest_action_upgrade_card"
	var chosen: RestActionButton = null
	for button: RestActionButton in buttons:
		if button.rest_action_object_id == wanted:
			chosen = button
	if chosen == null and not buttons.is_empty():
		chosen = buttons[0]
	_log("REST actions=%s choose %s hp=%d/%d" % [buttons.map(func(b): return b.rest_action_object_id), chosen.rest_action_object_id if chosen else "none", Global.player_data.player_health, Global.player_data.player_health_max])
	_rest_done = true
	if chosen:
		await click(chosen, "rest " + chosen.rest_action_object_id)


## マップ: 行ける部屋のうち、まだ行っていない種類を優先する (休憩所は体力が少ないときだけ優先)
func _map() -> void:
	var map := _find("Map")
	if not map.can_travel:
		return
	var next_ids: Array = Global.get_next_locations().map(func(l): return l.location_id)
	var best: MapLocation = null
	var best_score := -INF
	for map_location: MapLocation in map.location_container.get_children().filter(func(c): return c is MapLocation):
		if not next_ids.has(map_location.location_data.location_id):
			continue
		var type: int = map_location.location_data.location_type
		var score: float = -_visited_types.get(type, 0)
		if type == LocationData.LOCATION_TYPES.REST_SITE and Global.player_data.player_health * 2 < Global.player_data.player_health_max:
			score += 10
		if type == LocationData.LOCATION_TYPES.MINIBOSS and Global.player_data.player_health * 3 < Global.player_data.player_health_max * 2:
			score -= 10
		if score > best_score:
			best_score = score
			best = map_location
	if best == null:
		_log("MAP no reachable location (next=%s)" % [next_ids])
		return
	map.scroll_container.ensure_control_visible(best)
	await _wait(0.2)
	await click(best, "map " + LocationData.LOCATION_TYPES.keys()[best.location_data.location_type])


func _on_player_turn_started() -> void:
	_failed_cards.clear()
	if god_mode and Global.player_data.player_health < Global.player_data.player_health_max:
		Global.get_player().set_health(Global.player_data.player_health_max)


func _on_location_selected(location_data: LocationData) -> void:
	var type: int = location_data.location_type
	_visited_types[type] = _visited_types.get(type, 0) + 1
	_shop_step = 0
	_rest_done = false
	_log("ENTER act=%d floor=%s %s %s" % [Global.player_data.player_act, location_data.location_floor, LocationData.LOCATION_TYPES.keys()[type], _summary()])
	if type == LocationData.LOCATION_TYPES.BOSS:
		await _wait(3.0)
		await _shot("boss_act%d" % Global.player_data.player_act)


## 戦闘: 受けるダメージが防御を上回るなら防御カード、そうでなければパワー → アタック → スキルの順に出す。出せなければターン終了
func _combat() -> void:
	var combat := _find("Combat")
	var hand: Hand = HandManager.hand
	if hand.hand_disabled or combat.end_turn_button.disabled or ActionHandler.actions_being_performed or not HandManager.card_play_queue.is_empty():
		return
	var enemies: Array[Enemy] = Global.get_alive_enemies()
	if enemies.is_empty():
		return
	var player: Player = Global.get_player()
	var incoming := 0
	for enemy: Enemy in enemies:
		if enemy.is_attacking():
			incoming += enemy.enemy_intent_attack_damage * max(1, enemy.enemy_intent_number_of_attacks)
	var need_block := incoming - player.get_block()
	var playable: Array[Card] = []
	for card: Card in hand.get_player_hand_cards():
		if not _failed_cards.has(card.card_data) and card.can_play_card(null, false):
			playable.append(card)
	if playable.is_empty():
		await click(combat.end_turn_button, "end turn")
		await _wait(1.0)
		return
	playable.sort_custom(func(a: Card, b: Card): return _card_priority(a.card_data, need_block) > _card_priority(b.card_data, need_block))
	var card: Card = playable[0]
	var card_data: CardData = card.card_data # 出したカードの Card はすぐ消えるので先に持っておく
	var before := "%d|%d" % [HandManager.player_hand.size(), Global.player_data.player_energy]
	await click(card.card_button, "card " + card_data.object_id)
	if is_instance_valid(card) and hand.current_selected_card == card:
		var target: Enemy = enemies[0]
		for enemy: Enemy in enemies:
			if is_instance_valid(enemy) and enemy.get_combatant_health() < target.get_combatant_health():
				target = enemy
		await click(target.selection_button, "target " + target.name)
	await _wait(0.6)
	var after := "%d|%d" % [HandManager.player_hand.size(), Global.player_data.player_energy]
	if before == after and HandManager.player_hand.has(card_data):
		_failed_cards[card_data] = true
		_log("CARD no effect after click: %s (hand|energy %s)" % [card_data.object_id, after])
	elif _shots_taken.has("card_click") == false:
		await _shot("card_click")


func _card_priority(card_data: CardData, need_block: int) -> int:
	var blocks: bool = card_data.card_values.get("block", 0) > 0
	if need_block > 0 and blocks:
		return 4
	match card_data.card_type:
		CardData.CARD_TYPES.POWER:
			return 3
		CardData.CARD_TYPES.ATTACK:
			return 2
	return 1
#endregion


#region タイトルからラン開始

func _start_run_from_title() -> void:
	await _wait(1.5) # タイトルのボタンの並びが落ち着くまで待つ
	await click(_find("NewRunButton"), "title new run")
	await _wait(0.5)
	var menu := _find("NewRunMenu")
	for button: CharacterSelectionButton in menu.find_children("*", "CharacterSelectionButton", true, false):
		if button.character_object_id == hero_id:
			await click(button, "character " + hero_id)
	menu.seed_input.text = str(run_seed)
	menu.seed_input.text_changed.emit(menu.seed_input.text)
	await click(_find("StartRunButton"), "start run")
	await _wait(1.0)
	_log("LAYOUT viewport=%s RunScreen=%s RunStartOptions=%s Combat=%s Map=%s" % [get_viewport().get_visible_rect().size, _find("RunScreen").size, _find("RunStartOptions").size, _find("Combat").size, _find("Map").size])
	_log("RUN started hero=%s seed=%d is_run=%s %s" % [Global.player_data.player_character_object_id if Global.is_run else "-", run_seed, Global.is_run, _summary()])
#endregion


#region クリック

## コントロールの中心を本物のクリックと同じ経路で押す。上に別のものが被っていたら BLOCKED を出力する
func click(control: Control, label: String) -> void:
	if control == null or not is_instance_valid(control):
		_log("CLICK target missing: " + label)
		return
	# 人と同じく、まずカーソルを乗せてホバーの演出 (カードの拡大など) が終わってから押す
	_push_motion(control.get_global_rect().get_center())
	await _wait(0.3)
	if not is_instance_valid(control):
		_log("CLICK target vanished while hovering: " + label)
		return
	if label.begins_with("card card_") and not _shots_taken.has("card_hover"):
		await _shot("card_hover") # 押す直前 (カーソルが乗って拡大したカード)
	var pos: Vector2 = control.get_global_rect().get_center()
	if not get_viewport().get_visible_rect().has_point(pos):
		# 画面の外。本物のマウスでは押せない (Godot は画面外の座標でも押せてしまうので、ここで不具合として出す)
		_log("OFFSCREEN %s at %s: %s is outside the screen %s" % [label, pos, control.get_path(), get_viewport().get_visible_rect().size])
	_push_motion(pos)
	await get_tree().process_frame
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered != control and not (hovered and control.is_ancestor_of(hovered)):
		var key := label.get_slice(" ", 0) + "|" + (str(hovered.get_path()) if hovered else "null")
		if not _blocked_seen.has(key):
			_blocked_seen[key] = true
			_log("BLOCKED %s at %s: wanted %s, mouse is over %s" % [label, pos, control.get_path(), hovered.get_path() if hovered else "nothing"])
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.position = pos
		event.global_position = pos
		get_viewport().push_input(event)
		await get_tree().process_frame


func _push_motion(pos: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	get_viewport().push_input(motion)
#endregion


#region 補助

func _find(node_name: String) -> Node:
	return _root.find_child(node_name, true, false)

func _visible(node_name: String) -> bool:
	var node := _find(node_name) as CanvasItem
	return node != null and node.is_visible_in_tree()

func _visible_overlays() -> Array:
	return ["RunSummaryOverlay", "DeathScreen", "CardSelectionOverlay", "CardDraftSelectionOverlay", "RunStartOptions", "DialogueOverlay", "RewardOverlay", "ShopOverlay", "RestOverlay", "Map", "Combat"].filter(_visible)

func _cards_in(container: Node) -> Array:
	return container.get_children().filter(func(c): return c is Card and not c.is_queued_for_deletion())

func _floor() -> String:
	var location := Global.get_player_location_data()
	return str(location.location_floor) if location else "-"

func _summary() -> String:
	var p := Global.player_data
	return "hp=%d/%d gold=%d deck=%d relics=%d" % [p.player_health, p.player_health_max, p.player_money, p.player_deck.size(), p.player_artifact_uid_to_artifact_data.size()]

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	_clock += seconds

## 画面をそのまま PNG に保存する (1つの名前につき1回)
func _shot(shot_name: String) -> void:
	if shots_dir == "" or DisplayServer.get_name() == "headless" or _shots_taken.has(shot_name):
		return
	_shots_taken[shot_name] = true
	await RenderingServer.frame_post_draw
	var path := shots_dir.path_join("%02d_%s.png" % [_shots_taken.size(), shot_name])
	get_viewport().get_texture().get_image().save_png(path)
	_log("SHOT " + path)

func _log(text: String) -> void:
	print("PLAY [%6.1fs] %s" % [_clock, text])
#endregion
