## 対象が要るカードを選んでいる間、カードの上端からカーソルまで弧を描いて伸びる矢印 (StS の対象選択)
## 節 (山形) が先端へ流れ、敵の上に乗ると赤くなる。Hand が出し入れする
extends Node2D
class_name TargetArrow

const SAMPLES: int = 48 # 弧を折れ線にするときの分割数
const SEGMENT_SPACING: float = 20.0 # 節と節の間隔
const SEGMENT_SIZE_START: float = 9.0 # 根元の節の大きさ
const SEGMENT_SIZE_END: float = 17.0 # 先端近くの節の大きさ
const FLOW_SPEED: float = 48.0 # 節が先端へ流れる速さ (px/秒)
const HEAD_LENGTH: float = 48.0
const HEAD_HALF_WIDTH: float = 30.0
const ARC_HEIGHT_RATIO: float = 0.3 # 弧の膨らみ (根元から先端までの距離に対する割合)

const COLOR_IDLE: Color = Color(0.93, 0.89, 0.8)
const COLOR_ON_TARGET: Color = Color(0.92, 0.14, 0.1)
const OUTLINE_COLOR: Color = Color(0.08, 0.04, 0.03, 0.9)
const OUTLINE_WIDTH: float = 2.0

var card: Card = null # 矢印の根元のカード
var _flow: float = 0.0
var _mouse_position: Vector2 = Vector2.ZERO # 矢印の先端。マウスの動きのイベントで更新する

func _ready() -> void:
	top_level = true # 親 (Hand) の位置に関係なく画面座標で描く
	z_index = 100 # 敵や手札より手前
	hide_arrow()

func show_from(_card: Card) -> void:
	card = _card
	_mouse_position = get_global_mouse_position()
	visible = true
	set_process(true)
	queue_redraw()

func hide_arrow() -> void:
	card = null
	visible = false
	set_process(false)

func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		_mouse_position = make_input_local(event).position

func _process(delta: float) -> void:
	if card == null or not is_instance_valid(card):
		hide_arrow()
		return
	_flow = fmod(_flow + delta * FLOW_SPEED, SEGMENT_SPACING)
	queue_redraw()

func _draw() -> void:
	if card == null or not is_instance_valid(card):
		return
	var card_rect: Rect2 = card.card_visual.get_global_rect()
	var start: Vector2 = Vector2(card_rect.get_center().x, card_rect.position.y)
	var end: Vector2 = _mouse_position
	# 根元と先端の中間を上へ持ち上げた、山なりの弧
	var control: Vector2 = Vector2((start.x + end.x) / 2.0, min(start.y, end.y) - start.distance_to(end) * ARC_HEIGHT_RATIO)
	var color: Color = COLOR_ON_TARGET if _is_over_enemy(end) else COLOR_IDLE

	var points: PackedVector2Array = []
	var lengths: PackedFloat32Array = [0.0]
	for i in SAMPLES + 1:
		var t: float = float(i) / SAMPLES
		points.append(start.lerp(control, t).lerp(control.lerp(end, t), t))
		if i > 0:
			lengths.append(lengths[i - 1] + points[i].distance_to(points[i - 1]))
	var total_length: float = lengths[SAMPLES]
	if total_length < 1.0:
		return

	# 節: 根元から先端の手前まで、間隔ごとに置く (_flow ぶんずらして流す)
	var distance: float = _flow
	while distance < total_length - HEAD_LENGTH * 0.8:
		var ratio: float = distance / total_length
		var size: float = lerp(SEGMENT_SIZE_START, SEGMENT_SIZE_END, ratio)
		var fade: float = clamp(distance / SEGMENT_SPACING, 0.0, 1.0) # 根元で急に現れないように
		_draw_chevron(_point_at(points, lengths, distance), _direction_at(points, lengths, distance), size, Color(color, fade))
		distance += SEGMENT_SPACING

	# 矢じり
	var direction: Vector2 = (points[SAMPLES] - points[SAMPLES - 1]).normalized()
	var normal: Vector2 = direction.orthogonal()
	var base: Vector2 = end - direction * HEAD_LENGTH
	var head: PackedVector2Array = [
		end,
		base + normal * HEAD_HALF_WIDTH,
		end - direction * HEAD_LENGTH * 0.7,
		base - normal * HEAD_HALF_WIDTH,
	]
	_draw_shape(head, color)

## 先へ向いた山形を1つ描く
func _draw_chevron(center: Vector2, direction: Vector2, size: float, color: Color) -> void:
	var normal: Vector2 = direction.orthogonal()
	var chevron: PackedVector2Array = [
		center + direction * size,
		center - direction * size * 0.6 + normal * size,
		center - direction * size * 0.1,
		center - direction * size * 0.6 - normal * size,
	]
	_draw_shape(chevron, color)

func _draw_shape(shape: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(shape, color)
	var outline: PackedVector2Array = shape.duplicate()
	outline.append(shape[0])
	draw_polyline(outline, Color(OUTLINE_COLOR, OUTLINE_COLOR.a * color.a), OUTLINE_WIDTH, true)

## 弧の根元から distance 進んだところの位置
func _point_at(points: PackedVector2Array, lengths: PackedFloat32Array, distance: float) -> Vector2:
	var i: int = _segment_index(lengths, distance)
	var t: float = inverse_lerp(lengths[i], lengths[i + 1], distance) if lengths[i + 1] > lengths[i] else 0.0
	return points[i].lerp(points[i + 1], t)

## 弧の根元から distance 進んだところの向き
func _direction_at(points: PackedVector2Array, lengths: PackedFloat32Array, distance: float) -> Vector2:
	var i: int = _segment_index(lengths, distance)
	return (points[i + 1] - points[i]).normalized()

func _segment_index(lengths: PackedFloat32Array, distance: float) -> int:
	var i: int = lengths.bsearch(distance) - 1
	return clampi(i, 0, lengths.size() - 2)

func _is_over_enemy(position_: Vector2) -> bool:
	for enemy: BaseCombatant in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_alive() and enemy.selection_button.get_global_rect().has_point(position_):
			return true
	return false
