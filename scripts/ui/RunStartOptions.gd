# Displays run start options
# 幕の開始地点で祝福のキャラ (BlessingContent) が祝福を出し、選ぶと演出つきで渡す (BlessingGiver)。
# 1幕目だけ、開始武器 (BuildContent) とボスレリック交換も並べる。
extends Control

var _option_type_to_option_ids: Dictionary = {}
const COMPLETE_OPTION_COUNT: int = 3	# number of unique options to populate (weapons from BuildContent + artifact swap)
## 選択肢の列 (主人公と祝福のキャラの間。画面の下端・中央を基準にし、下端から上へ伸びる)
## 1200x700 の画面では x=390〜790、下端 y=690。全画面で画面が広がっても中央の下に残る
const OPTION_LEFT: float = -210.0
const OPTION_RIGHT: float = 190.0
const OPTION_BOTTOM: float = -10.0
const FAREWELL_TIME: float = 0.9	# 受け取ったあと、キャラが消えるまでの間

@onready var starting_option_container = $StartingOptionContainer
@onready var map = $%Map

var _giver: BlessingGiver
var _giver_data: DialogueData
var _is_choosing: bool = false

func _ready():
	_aggregate_run_start_options()
	_giver = BlessingGiver.new()
	add_child(_giver)
	move_child(_giver, 0) # 選択肢より奥
	# シーン側のアンカー (右下) に左右されないよう、ここでアンカーも決める
	starting_option_container.anchor_left = 0.5
	starting_option_container.anchor_right = 0.5
	starting_option_container.anchor_top = 1.0
	starting_option_container.anchor_bottom = 1.0
	starting_option_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	starting_option_container.offset_left = OPTION_LEFT
	starting_option_container.offset_right = OPTION_RIGHT
	starting_option_container.offset_top = OPTION_BOTTOM
	starting_option_container.offset_bottom = OPTION_BOTTOM
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
	
	# 祝福のキャラを登場させる
	_giver_data = BlessingContent.get_giver_for_act(Global.player_data.player_act)
	var greet_state: DialogueStateData = BlessingContent.get_greet_state(_giver_data)
	_giver.show_giver(FileLoader.load_texture(greet_state.dialogue_state_dialogue_texture_path), tr(_giver_data.dialogue_name_bbcode), tr(greet_state.dialogue_state_prompt_bbcode))
	
	# 祝福 (小さな祝福 + 代償つきの大きな祝福)
	var rng_run_start_options: RandomNumberGenerator = Global.player_data.get_player_rng("rng_run_start_options")
	for option_data: DialogueOptionData in BlessingContent.pick_blessings(_giver_data, rng_run_start_options):
		_add_option(tr(option_data.dialogue_option_bbcode), tr(option_data.dialogue_option_failed_validator_bbcode), option_data.dialogue_option_actions, option_data.dialogue_option_validators)
	
	if Global.player_data.player_act != 1:
		return
	# populate complete options (1幕目だけ: 開始武器とボスレリック交換)
	var complete_option_ids: Array[String] = []
	complete_option_ids.assign(_option_type_to_option_ids[RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE].filter(
		func(id: String) -> bool: return Global.get_run_start_option_data(id).is_offered_to(Global.player_data.player_character_object_id)))
	for i in min(COMPLETE_OPTION_COUNT, len(complete_option_ids)):
		# get option
		var complete_option_id: String = complete_option_ids.pop_back()
		var complete_run_start_option_data: RunStartOptionData = Global.get_run_start_option_data(complete_option_id)
		var option_bbcode: String = tr(complete_run_start_option_data.run_start_option_bb_code)
		_add_option(option_bbcode, option_bbcode, complete_run_start_option_data.run_start_option_actions, [])

## create a dialogue button for the option
func _add_option(option_bbcode: String, failed_bbcode: String, actions: Array[Dictionary], validators: Array[Dictionary]) -> void:
	var run_start_option_button: DialogueOption = Scenes.DIALOGUE_OPTION.instantiate()
	starting_option_container.add_child(run_start_option_button)
	run_start_option_button.init("", option_bbcode, failed_bbcode, actions, validators)
	run_start_option_button.dialogue_option_clicked.connect(_on_dialogue_option_clicked)
	
func clear_run_start_options() -> void:
	for child in starting_option_container.get_children():
		child.queue_free()
	
func _on_dialogue_option_clicked(dialogue_option: DialogueOption):
	if _is_choosing:
		return # 演出中の2回目のクリックは無視
	_is_choosing = true
	
	# 選ばなかった選択肢を消す
	for child: DialogueOption in starting_option_container.get_children():
		child.option_enabled = false
		if child != dialogue_option:
			child.create_tween().tween_property(child, "modulate:a", 0.0, 0.25)
	
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
