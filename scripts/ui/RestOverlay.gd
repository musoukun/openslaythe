# Overlay for actions at a rest site
# A home-base scene: the hero rests on a glowing rune platform (left) and the actions are framed icon tiles (right).
# Hovering a tile shows a tooltip with the action's name, effect and how often it can be used.
extends Control

const BACKGROUND_PATH := "external/sprites/backgrounds/rest_site.png"
const HERO_ART_PATTERN := "external/sprites/characters/%s/%s_1.png" # character id, frame name
const BREATH_AMPLITUDE := 3.0
const BREATH_DURATION := 1.6
const TOOLTIP_GAP := 6.0
## The top bar lives inside Combat (z 0). While the rest site is open it is lifted above this overlay (z 5)
## but stays below the other overlays (z 10), such as the card picker opened by Smith.
const HUD_NODE_NAMES := ["Background2", "PauseButton", "MapButton", "DeckButton", "MoneyLabel", "HealthLabel", "ArtifactContainer", "Consumables", "RunTimer"]
const HUD_Z_INDEX := 6

## EXCLUSIVE actions list the other exclusive tiles instead (see _get_cost_note)
const COST_TYPE_NOTES := {
	RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE: "Once per visit. Can be combined with other actions.",
	RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE_REPEATABLE: "Can be done any number of times.",
}
const EXCLUSIVE_NOTE := "You can choose only one of: {0}"
const NAME_SEPARATOR := " / "

@onready var rest_action_container: HFlowContainer = %RestActionContainer
@onready var continue_button: Button = %ContinueButton
@onready var background: TextureRect = %Background
@onready var hero: TextureRect = %Hero
@onready var rune_glow: TextureRect = %RuneGlow
@onready var tooltip: PanelContainer = %Tooltip
@onready var tooltip_name: Label = %TooltipName
@onready var tooltip_description: Label = %TooltipDescription
@onready var tooltip_note: Label = %TooltipNote

@onready var map = $%Map
@onready var combat: Control = $"../Combat"

var rest_action_id_to_rest_action_button: Dictionary[String, RestActionButton] = {}
var _scene_tween: Tween

func _ready():
	Signals.combat_started.connect(_on_combat_started)
	Signals.rest_action_ended.connect(_on_rest_action_ended)

	Signals.map_location_selected.connect(_on_map_location_selected)
	continue_button.button_up.connect(_on_continue_button_up)
	visibility_changed.connect(_lift_hud)

func _lift_hud() -> void:
	for node_name in HUD_NODE_NAMES:
		var hud_node := combat.get_node_or_null(node_name) as CanvasItem
		if hud_node:
			hud_node.z_index = HUD_Z_INDEX if visible else 0

func _on_map_location_selected(_location_data: LocationData):
	if _location_data.location_type == LocationData.LOCATION_TYPES.REST_SITE:
		visible = true
		populate_scene()
		populate_rest_actions()
		_play_arrival()
	else:
		visible = false
		clear_rest_actions()

func populate_scene() -> void:
	if background.texture == null and FileAccess.file_exists(FileLoader._get_modified_filepath(BACKGROUND_PATH)):
		background.texture = FileLoader.load_texture(BACKGROUND_PATH)
	hero.texture = _get_hero_rest_texture()

func _get_hero_rest_texture() -> Texture2D:
	# hero specific resting pose, falling back to the hero's idle frame
	var character_id: String = Global.player_data.player_character_object_id
	for frame_name in ["hero_rest", "hero_idle"]:
		var path: String = HERO_ART_PATTERN % [character_id, frame_name]
		if FileAccess.file_exists(FileLoader._get_modified_filepath(path)):
			return FileLoader.load_texture(path)
	return null

func populate_rest_actions() -> void:
	clear_rest_actions()

	# get the rest actions the player can perform
	var player_rest_action_object_ids: Array[String] = Global.player_data.player_available_rest_action_object_ids
	for rest_action_object_id in player_rest_action_object_ids:
		var rest_action_data: RestActionData = Global.get_rest_action_data(rest_action_object_id)
		if rest_action_data != null:
			var rest_action_button: RestActionButton = Scenes.REST_ACTION_BUTTON.instantiate()
			rest_action_container.add_child(rest_action_button)
			rest_action_button.init(rest_action_object_id)
			rest_action_button.rest_action_button_up.connect(_on_rest_action_button_up)
			rest_action_button.rest_action_hovered.connect(_show_tooltip)
			rest_action_button.rest_action_unhovered.connect(_hide_tooltip)
			rest_action_button.set_available(rest_action_button.validate_rest_button())

			rest_action_id_to_rest_action_button[rest_action_object_id] = rest_action_button

## Recall-like arrival: the hero fades in on the glowing platform, then the tiles pop in one by one
func _play_arrival() -> void:
	if _scene_tween:
		_scene_tween.kill()
	hero.modulate = Color(1.6, 1.9, 1.8, 0.0)
	# remember the resting height once, so repeated visits never drift the breathing offset
	if not hero.has_meta("base_y"):
		hero.set_meta("base_y", hero.position.y)
	var base_y: float = hero.get_meta("base_y")
	hero.position.y = base_y
	rune_glow.modulate.a = 0.0
	for button in rest_action_container.get_children():
		button.modulate.a = 0.0

	_scene_tween = create_tween()
	_scene_tween.tween_property(rune_glow, "modulate:a", 1.0, 0.35)
	_scene_tween.tween_property(hero, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)
	for button in rest_action_container.get_children():
		_scene_tween.tween_property(button, "modulate:a", 1.0, 0.12)
	_scene_tween.tween_callback(_start_idle_loop.bind(base_y))

func _start_idle_loop(base_y: float) -> void:
	# breathing and a slowly pulsing rune ring
	_scene_tween = create_tween().set_loops().set_parallel()
	var breath: Tween = _scene_tween
	breath.tween_property(hero, "position:y", base_y - BREATH_AMPLITUDE, BREATH_DURATION).set_trans(Tween.TRANS_SINE)
	breath.tween_property(rune_glow, "modulate:a", 0.6, BREATH_DURATION).set_trans(Tween.TRANS_SINE)
	breath.chain().tween_property(hero, "position:y", base_y, BREATH_DURATION).set_trans(Tween.TRANS_SINE)
	breath.tween_property(rune_glow, "modulate:a", 1.0, BREATH_DURATION).set_trans(Tween.TRANS_SINE)

func _show_tooltip(button: RestActionButton) -> void:
	var rest_action_data: RestActionData = button.get_rest_action_data()
	tooltip_name.text = button.name_label.text
	tooltip_description.text = tr(rest_action_data.rest_action_description)
	tooltip_description.visible = rest_action_data.rest_action_description != ""
	tooltip_note.text = tr("Not available right now.") if button.disabled else _get_cost_note(rest_action_data)
	tooltip_note.visible = tooltip_note.text != ""
	tooltip.reset_size()
	tooltip.visible = true
	_place_tooltip.call_deferred(button)

func _get_cost_note(rest_action_data: RestActionData) -> String:
	if rest_action_data.rest_action_cost_type != RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE:
		return tr(COST_TYPE_NOTES.get(rest_action_data.rest_action_cost_type, ""))
	var exclusive_names: PackedStringArray = []
	for other_button: RestActionButton in rest_action_container.get_children():
		if other_button.get_rest_action_data().rest_action_cost_type == RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE:
			exclusive_names.append(other_button.name_label.text)
	if exclusive_names.size() < 2:
		return ""
	return tr(EXCLUSIVE_NOTE).format([NAME_SEPARATOR.join(exclusive_names)])

func _place_tooltip(button: RestActionButton) -> void:
	# under the tile, flipped above it if it would leave the screen, and kept inside horizontally
	tooltip.reset_size()
	var tile: Rect2 = button.get_global_rect()
	var screen: Rect2 = get_global_rect()
	var pos := Vector2(tile.get_center().x - tooltip.size.x / 2.0, tile.end.y + TOOLTIP_GAP)
	if pos.y + tooltip.size.y > screen.end.y:
		pos.y = tile.position.y - tooltip.size.y - TOOLTIP_GAP
	pos.x = clampf(pos.x, screen.position.x + 8.0, screen.end.x - tooltip.size.x - 8.0)
	tooltip.global_position = pos

func _hide_tooltip(_button: RestActionButton) -> void:
	tooltip.visible = false

func _on_rest_action_button_up(rest_action_button: RestActionButton):
	if ActionHandler.actions_being_performed:
		return

	# perform actions
	var rest_action_data: RestActionData = Global.get_rest_action_data(rest_action_button.rest_action_object_id)
	if rest_action_data != null:
		var action_data: Array[Dictionary] = rest_action_data.rest_actions
		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], action_data, null)

		if rest_action_data.rest_action_auto_end:
			var rest_action_end: BaseAction = ActionGenerator.generate_rest_action_end(rest_action_data.object_id)
			generated_actions.push_front(rest_action_end)

		ActionHandler.add_actions(generated_actions, false)

func _on_rest_action_ended(rest_action_id: String):
	var rest_action_data: RestActionData = Global.get_rest_action_data(rest_action_id)
	if rest_action_data != null:
		var rest_action_button: RestActionButton = rest_action_id_to_rest_action_button[rest_action_id]

		# disable buttons based on pressed button's exclusivity
		var rest_action_cost_type: int = rest_action_data.rest_action_cost_type

		if rest_action_cost_type == RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE:
			# disable non repeatable free buttons after single use
			rest_action_button.excluded = true
		if rest_action_cost_type == RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE:
			# disable all exclusive buttons if action taken exclusive
			for other_button: RestActionButton in rest_action_container.get_children():
				var other_button_rest_action_data: RestActionData = Global.get_rest_action_data(other_button.rest_action_object_id)
				if other_button_rest_action_data.rest_action_cost_type == RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE:
					other_button.excluded = true

		# re-validate all rest buttons
		for button: RestActionButton in rest_action_container.get_children():
			button.set_available(button.validate_rest_button())
	tooltip.visible = false

func clear_rest_actions():
	rest_action_id_to_rest_action_button.clear()
	tooltip.visible = false
	for child in rest_action_container.get_children():
		child.queue_free()

func _on_combat_started(_event_id: String):
	visible = false
	clear_rest_actions()

func _on_continue_button_up():
	if not Global.is_end_of_run():
		map.can_travel = true
		map.show_map()
	else:
		visible = false
		Signals.run_victory.emit()
