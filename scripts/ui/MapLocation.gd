extends TextureButton
class_name MapLocation

## 種類別アイコン (Codex 生成: sprites/map/location_<type>.png)
const ICON_PATH := "res://sprites/map/location_%s.png"
const UNKNOWN_TYPE := "event"
const VISITED_MODULATE := Color(0.55, 0.55, 0.55, 1.0)
const HOVER_SCALE := Vector2(1.2, 1.2)

var location_data: LocationData = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var map_label: Label = $MapLabel

signal map_location_button_up(map_location: MapLocation)

func _ready():
	button_up.connect(_on_button_up)
	mouse_entered.connect(_tween_scale.bind(HOVER_SCALE))
	mouse_exited.connect(_tween_scale.bind(Vector2.ONE))
	pivot_offset = size / 2.0

func init(_location_data: LocationData):
	location_data = _location_data
	position = location_data.location_position

	var type_key: String = LocationData.LOCATION_TYPES.keys()[location_data.location_type].to_lower()
	# display the type of location
	if location_data.location_obfuscated and not location_data.location_visited:
		map_label.text = "???" # unvisited obfuscated locations are marked hidden
		type_key = UNKNOWN_TYPE
	else:
		map_label.text = type_key.replace("_", " ").capitalize()

	var icon_path := ICON_PATH % type_key
	if ResourceLoader.exists(icon_path):
		texture_normal = load(icon_path)
		map_label.visible = false
		tooltip_text = map_label.text
	if location_data.location_visited:
		self_modulate = VISITED_MODULATE

## Center of the icon in the parent (LocationContainer) coordinates
func get_center() -> Vector2:
	return position + size / 2.0

func flash_location() -> void:
	animation_player.play("flash_map_location")

func _tween_scale(target: Vector2) -> void:
	create_tween().tween_property(self, "scale", target, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_up():
	location_data.location_visited = true
	map_location_button_up.emit(self)
