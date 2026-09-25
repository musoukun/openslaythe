## UI component for a selectable option. Used for run start options and dialogue options.
## Supports rich text.
extends PanelContainer
class_name DialogueOption

@onready var rich_text_label = $RichTextLabel

## The dialogue option this button represents. Run start option buttons will have this as empty.
var dialogue_option_object_id: String = ""

var action_data: Array[Dictionary] = []
var validators: Array[Dictionary] = []
var option_enabled: bool = false

signal dialogue_option_clicked(dialogue_option: DialogueOption)

## 読みやすい見た目 (暗い板 + 縁、ホバーで明るく)
const FONT_SIZE := 17
const PANEL_COLOR := Color(0.05, 0.13, 0.14, 0.95)
const PANEL_HOVER_COLOR := Color(0.13, 0.27, 0.27, 0.98)
const BORDER_COLOR := Color(0.51, 0.79, 0.63, 0.8)

var _style: StyleBoxFlat

func _ready():
	gui_input.connect(_on_gui_input)
	self_modulate = Color.WHITE
	_style = StyleBoxFlat.new()
	_style.bg_color = PANEL_COLOR
	_style.border_color = BORDER_COLOR
	_style.set_border_width_all(2)
	_style.set_corner_radius_all(8)
	_style.set_content_margin_all(10)
	add_theme_stylebox_override("panel", _style)
	rich_text_label.add_theme_font_size_override("normal_font_size", FONT_SIZE)
	mouse_entered.connect(func(): _style.bg_color = PANEL_HOVER_COLOR if option_enabled else PANEL_COLOR)
	mouse_exited.connect(func(): _style.bg_color = PANEL_COLOR)

func init(_dialogue_option_object_id: String, option_bbcode: String, option_failed_validator_bbcode: String, _action_data: Array[Dictionary], _validators: Array[Dictionary]) -> void:
	dialogue_option_object_id = _dialogue_option_object_id
	action_data = _action_data
	validators = _validators
	option_enabled = validate_dialogue_option()
	if option_enabled:
		set_dialogue_bb_code(option_bbcode)
	else:
		set_dialogue_bb_code(option_failed_validator_bbcode)

func validate_dialogue_option() -> bool:
	# checks if option passes all validators
	return Global.validate(validators, null, null)

func set_dialogue_bb_code(bb_code: String) -> void:
	rich_text_label.parse_bbcode(bb_code)

func _on_gui_input(event: InputEvent):
	if option_enabled:
		if event.is_action_pressed("left_click"):
			dialogue_option_clicked.emit(self)
