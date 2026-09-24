extends CanvasLayer
## F3 で FPS と直近1秒の最悪フレーム時間を表示する (重さの調査用)

var _label: Label
var _worst_ms := 0.0
var _elapsed := 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.position = Vector2(8, 668)
	_label.add_theme_color_override("font_color", Color.YELLOW)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 4)
	_label.visible = false
	add_child(_label)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		_label.visible = not _label.visible


func _process(delta: float) -> void:
	if not _label.visible:
		return
	_worst_ms = max(_worst_ms, delta * 1000.0)
	_elapsed += delta
	if _elapsed >= 1.0:
		_label.text = "FPS %d | worst %.1f ms | time_scale %.2f" % [Engine.get_frames_per_second(), _worst_ms, Engine.time_scale]
		_worst_ms = 0.0
		_elapsed = 0.0
