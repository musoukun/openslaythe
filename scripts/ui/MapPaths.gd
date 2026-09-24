extends Control
class_name MapPaths
## マップ上のロケーション同士を点線でつなぐ。

const DASH_LENGTH := 8.0
const LINE_WIDTH := 3.0
const LINE_COLOR := Color(0.12, 0.1, 0.08, 0.7)
const VISITED_COLOR := Color(0.95, 0.75, 0.3, 0.95)
const ICON_MARGIN := 30.0	# アイコンに線が重ならないよう端を詰める

## [from: Vector2, to: Vector2, visited: bool]
var segments: Array = []

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_segments(new_segments: Array) -> void:
	segments = new_segments
	# 描画範囲を全線分が収まる大きさにする (サイズ0だと描画されないため)
	var bounds := Rect2()
	for seg in segments:
		bounds = bounds.expand(seg[0]).expand(seg[1])
	size = bounds.end
	queue_redraw()

func _draw() -> void:
	for seg in segments:
		var from: Vector2 = seg[0]
		var to: Vector2 = seg[1]
		var dir := (to - from).normalized()
		from += dir * ICON_MARGIN
		to -= dir * ICON_MARGIN
		if from.distance_to(to) < 1.0:
			continue
		draw_dashed_line(from, to, VISITED_COLOR if seg[2] else LINE_COLOR, LINE_WIDTH, DASH_LENGTH)
