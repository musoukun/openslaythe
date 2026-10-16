extends Button
class_name RestActionButton
## A rest site tile: framed icon with the action name below. Hover/focus is reported to RestOverlay for the tooltip.

const BORDER_NORMAL := Color(0.721569, 0.580392, 0.309804)
const BORDER_HOVER := Color(1, 0.858824, 0.54902)
const HOVER_SCALE := Vector2(1.08, 1.08)
const DISABLED_MODULATE := Color(0.45, 0.45, 0.45)

@onready var frame: Panel = %Frame
@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

var rest_action_object_id: String = ""
var excluded: bool = false # excluded buttons are disabled

var _frame_style: StyleBoxFlat
var _hover_tween: Tween

signal rest_action_button_up(button: RestActionButton)
signal rest_action_hovered(button: RestActionButton)
signal rest_action_unhovered(button: RestActionButton)

func _ready():
	button_up.connect(_on_button_up)
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	focus_entered.connect(_set_hovered.bind(true))
	focus_exited.connect(_set_hovered.bind(false))
	# each tile changes its own border color, so it needs its own copy of the style
	_frame_style = frame.get_theme_stylebox("panel").duplicate()
	frame.add_theme_stylebox_override("panel", _frame_style)

func init(_rest_action_object_id: String) -> void:
	rest_action_object_id = _rest_action_object_id
	var rest_action_data: RestActionData = Global.get_rest_action_data(rest_action_object_id)
	# names may contain manual line breaks; the label wraps on its own
	name_label.text = tr(rest_action_data.rest_action_name).replace("\n", " ")
	if rest_action_data.rest_action_texture_path != "":
		icon_rect.texture = FileLoader.load_texture(rest_action_data.rest_action_texture_path)

func get_rest_action_data() -> RestActionData:
	return Global.get_rest_action_data(rest_action_object_id)

func set_available(available: bool) -> void:
	disabled = not available
	modulate = Color.WHITE if available else DISABLED_MODULATE

func _set_hovered(hovered: bool) -> void:
	_frame_style.border_color = BORDER_HOVER if hovered and not disabled else BORDER_NORMAL
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", HOVER_SCALE if hovered and not disabled else Vector2.ONE, 0.08)
	if hovered:
		rest_action_hovered.emit(self)
	else:
		rest_action_unhovered.emit(self)

func _on_button_up():
	rest_action_button_up.emit(self)

func validate_rest_button() -> bool:
	# returns whether the validators pass for this rest action
	# used for checking if the button should be enabled/disabled
	# this does not factor in rest action exclusivity
	if excluded:
		return false

	var rest_action_data: RestActionData = get_rest_action_data()
	return Global.validate(rest_action_data.rest_action_validators, null, null)
