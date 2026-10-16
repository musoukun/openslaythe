extends Control
## 死亡画面 (StS2 風)。
## 主人公が倒れ始めたら戦闘の場面を暗い赤に沈めて戦闘 UI を消し、倒れ終わったら
## 羊皮紙の帯「死……」と赤い一言、「続ける」を出す。HUD (HP やお金) は出したまま。
## 「続ける」で統計画面 (RunSummaryOverlay) へ渡す。

const SINK_COLOR := Color(0.40, 0.11, 0.10)
const ENEMY_SINK_COLOR := Color(0.80, 0.62, 0.60)
const MESSAGE_COLOR := Color("#F0574A")
const BANNER_TEXT_COLOR := Color("#3A2716")
const BANNER_SIZE := Vector2(460, 64)
## 倒れたら消す戦闘 UI (Combat の子の名前)
const HIDE_ON_DEATH: Array[String] = [
	"Hand", "EndTurnButton", "Energy", "DrawPile", "DiscardPile", "ExhaustPile",
	"CardPicking", "SelectTargetLabel", "HandSizeExceededRect", "TurnOverlay",
]
## EventData の死亡メッセージが未設定のときの値
const DEFAULT_DEATH_MESSAGE := "Standard Event Death Message"

@onready var combat: Control = $"../Combat"

var _banner: Control
var _message: Label
var _continue_button: Button
var _embers: CPUParticles2D
var _tween: Tween
## 元に戻す見た目 [node, property, value]
var _changed: Array = []


func _ready() -> void:
	visible = false
	_build()
	_continue_button.pressed.connect(_on_continue_pressed)
	Signals.player_killed.connect(_on_player_killed)
	Signals.player_death_animation_finished.connect(_on_player_death_animation_finished)
	Signals.run_started.connect(_restore)
	Signals.run_ended.connect(_restore)


func _build() -> void:
	_embers = HeroDeath.make_embers(160, 3.6)
	_embers.emitting = false
	_embers.emission_rect_extents = Vector2(110, 40)
	_embers.scale_amount_max = 0.9
	_embers.spread = 35.0
	add_child(_embers)

	_banner = Ribbon.new()
	_place(_banner, Vector2(0.5, 0.2), Vector2(-BANNER_SIZE.x / 2.0, 0), BANNER_SIZE)
	_banner.pivot_offset = BANNER_SIZE / 2.0
	add_child(_banner)
	var title := Label.new()
	title.text = tr("Death...")
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", BANNER_TEXT_COLOR)
	title.add_theme_constant_override("outline_size", 0)
	title.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	_banner.add_child(title)

	_message = Label.new()
	_place(_message, Vector2(0.5, 0.2), Vector2(-300, BANNER_SIZE.y + 22), Vector2(600, 32))
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 22)
	_message.add_theme_color_override("font_color", MESSAGE_COLOR)
	add_child(_message)

	_continue_button = Button.new()
	_continue_button.text = tr("Continue on")
	_place(_continue_button, Vector2(0.5, 1.0), Vector2(-100, -110), Vector2(200, 48))
	_continue_button.add_theme_font_size_override("font_size", 22)
	add_child(_continue_button)


## anchor (0..1) の点から offset ずらした位置に size で置く
func _place(node: Control, anchor: Vector2, offset: Vector2, node_size: Vector2) -> void:
	node.anchor_left = anchor.x
	node.anchor_right = anchor.x
	node.anchor_top = anchor.y
	node.anchor_bottom = anchor.y
	node.offset_left = offset.x
	node.offset_top = offset.y
	node.offset_right = offset.x + node_size.x
	node.offset_bottom = offset.y + node_size.y


## 倒れ始め: 場面を沈め、戦闘 UI を消し、クリックを止める
func _on_player_killed(_player: Player) -> void:
	_restore()
	visible = true
	for node: CanvasItem in [_banner, _message, _continue_button]:
		node.modulate.a = 0.0
	_continue_button.disabled = true
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	_sink(combat.find_child("BackgroundButton", false, false), "self_modulate", SINK_COLOR, 1.2)
	_sink(combat.find_child("EnemyContainer", false, false), "modulate", ENEMY_SINK_COLOR, 1.2)
	for node_name in HIDE_ON_DEATH:
		var node := combat.find_child(node_name, false, false) as CanvasItem
		if node:
			_sink(node, "modulate", Color(node.modulate, 0.0), 0.4)


## 倒れ終わり: 帯と一言、続けるボタン
func _on_player_death_animation_finished(player: Player) -> void:
	var sprite := player.animated_sprite_2d
	var feet := sprite.global_position + Vector2(0, BaseCombatant.SPRITE_FEET_Y)
	_embers.position = get_global_transform().affine_inverse() * (feet + Vector2(0, -90))
	_embers.emitting = true
	_message.text = _death_message()

	_banner.scale = Vector2(1.25, 1.25)
	_tween = create_tween().set_parallel()
	_tween.tween_property(_banner, "modulate:a", 1.0, 0.35)
	_tween.tween_property(_banner, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_message, "modulate:a", 1.0, 0.5).set_delay(0.45)
	_tween.tween_property(_continue_button, "modulate:a", 1.0, 0.4).set_delay(0.9)
	_tween.chain().tween_callback(func(): _continue_button.disabled = false)


func _on_continue_pressed() -> void:
	visible = false
	_embers.emitting = false
	Signals.death_screen_closed.emit()


## 負けた戦闘の一言。イベントに死亡メッセージが無ければ汎用の一言
func _death_message() -> String:
	var event_data: EventData = Global.get_player_event_data()
	if event_data and event_data.event_death_message_bbcode not in ["", DEFAULT_DEATH_MESSAGE]:
		return tr(event_data.event_death_message_bbcode)
	return tr("Your journey ends here.")


func _sink(node: CanvasItem, property: String, to: Color, duration: float) -> void:
	if node == null:
		return
	_changed.append([node, property, node.get(property)])
	_tween.tween_property(node, property, to, duration)


## 沈めた見た目を元に戻す (次のランへ持ち越さない)
func _restore() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	for change in _changed:
		if is_instance_valid(change[0]):
			change[0].set(change[1], change[2])
	_changed.clear()
	_embers.emitting = false
	visible = false


## 羊皮紙の帯 (両端が後ろへ折り返した巻き布)
class Ribbon extends Control:
	const PAPER_TOP := Color("#E8D6AC")
	const PAPER_BOTTOM := Color("#C7AA78")
	const PAPER_BACK := Color("#A98B5C")
	const FOLD := Color("#6E5435")
	const EDGE := Color("#5A4128")
	const TAIL_W := 54.0
	const TAIL_DROP := 14.0

	func _draw() -> void:
		var w := size.x
		var h := size.y
		# 後ろの尾 (左右)、先は V 字に切れ込む
		for side: int in [-1, 1]:
			var x0: float = 0.0 if side == -1 else w
			var x1: float = x0 + side * TAIL_W
			var tail := PackedVector2Array([
				Vector2(x0 - side * 10, TAIL_DROP), Vector2(x1, TAIL_DROP),
				Vector2(x1 - side * 16, (h + TAIL_DROP * 2) / 2.0), Vector2(x1, h + TAIL_DROP),
				Vector2(x0 - side * 10, h + TAIL_DROP),
			])
			draw_colored_polygon(tail, PAPER_BACK)
			draw_polyline(tail + PackedVector2Array([tail[0]]), EDGE, 2.0, true)
			# 折り返しの影
			draw_colored_polygon(PackedVector2Array([Vector2(x0, h), Vector2(x0 + side * 12, h + TAIL_DROP), Vector2(x0 - side * 10, h + TAIL_DROP)]), FOLD)
		# 表の帯 (上が明るい)
		var band := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
		draw_polygon(band, PackedColorArray([PAPER_TOP, PAPER_TOP, PAPER_BOTTOM, PAPER_BOTTOM]))
		draw_polyline(band + PackedVector2Array([band[0]]), EDGE, 2.5, true)
		draw_line(Vector2(10, 6), Vector2(w - 10, 6), Color(EDGE, 0.35), 1.5)
		draw_line(Vector2(10, h - 6), Vector2(w - 10, h - 6), Color(EDGE, 0.35), 1.5)
