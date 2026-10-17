extends Control
class_name MapHighlight
## マップのアイコンに付ける目印。
## CURRENT = 現在地 (赤インクの丸 + 小さな矢印)、NEXT = 次に行ける場所 (ゆっくり明滅する丸)。

enum Kind { CURRENT, NEXT }

## 羊皮紙になじむインク色で、控えめに見せる
const CURRENT_COLOR := Color(0.55, 0.14, 0.08)
const NEXT_COLOR := Color(0.62, 0.38, 0.12)
const RING_WIDTH := 3.0
const RING_PADDING := 4.0	# アイコンの外周からリングまでの余白
const GLOW_LAYERS := 5
const PULSE_TIME := 1.0
const ARROW_SIZE := Vector2(14, 10)
const ARROW_GAP := 6.0		# アイコン上端と矢印の間
const ARROW_BOB := 3.0		# 矢印の上下の振れ幅

var kind: Kind = Kind.NEXT
var pulse: float = 0.0:	# 0..1 で往復するアニメーション値
	set(value):
		pulse = value
		queue_redraw()

## target の子として目印を付ける
static func attach(target: Control, highlight_kind: Kind) -> MapHighlight:
	var highlight := MapHighlight.new()
	highlight.kind = highlight_kind
	target.add_child(highlight)
	return highlight

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_behind_parent = true	# アイコンの絵を隠さない
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tween := create_tween().set_loops()
	tween.tween_property(self, "pulse", 1.0, PULSE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "pulse", 0.0, PULSE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _draw() -> void:
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 + RING_PADDING
	var color := CURRENT_COLOR if kind == Kind.CURRENT else NEXT_COLOR
	if kind == Kind.CURRENT:
		draw_arc(center, radius, 0.0, TAU, 48, color, RING_WIDTH, true)
		_draw_arrow(Vector2(center.x, -ARROW_GAP - ARROW_BOB * pulse), color)
	else:
		_draw_glow(center, radius, color, 0.04 + 0.08 * pulse)
		draw_arc(center, radius, 0.0, TAU, 48, Color(color, 0.25 + 0.45 * pulse), RING_WIDTH * 0.7, true)

## 同心円を重ねて柔らかい光にする
func _draw_glow(center: Vector2, radius: float, color: Color, alpha: float) -> void:
	for i in GLOW_LAYERS:
		var t := float(i) / GLOW_LAYERS
		draw_circle(center, radius * (1.0 + 0.35 * t), Color(color, alpha * (1.0 - t)), true, -1.0, true)

## 下向きの三角 (先端が tip)
func _draw_arrow(tip: Vector2, color: Color) -> void:
	var half := ARROW_SIZE.x / 2.0
	var points := PackedVector2Array([tip, tip + Vector2(-half, -ARROW_SIZE.y), tip + Vector2(half, -ARROW_SIZE.y)])
	draw_colored_polygon(points, color)
