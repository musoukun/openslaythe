## ショップの購入画面: 緑の布の上に商品を並べる (上段: カード / 下段: レリック・ポーション・カード削除)。
## 商人の大きな手が上から伸び、カーソルのある商品を指さして追従する (指さしの絵1枚を回転・移動させる)。
## 子ノードはすべてコードで組む。ShopOverlay が持つ。
extends Control
class_name ShopCounter

signal back_pressed

const HAND_TEXTURE := preload("res://sprites/ui/shop_hand.png")
const BACK_TEXTURE := preload("res://sprites/ui/shop_next_arrow.png")

const HUD_HEIGHT := 64.0	# 上部バーは暗くせず、押せるままにする
const CLOTH_SIZE := Vector2(1180, 470)	# カード6枚 (Card.CARD_SCALE で拡大) が1段に収まる幅
const CLOTH_TOP := 136.0
const CLOTH_COLOR := Color(0.18, 0.36, 0.25)
const CLOTH_BORDER := Color(0.72, 0.58, 0.3)

## 手の絵 (220x640) の中の指先の位置と、表示の大きさ
const HAND_TIP := Vector2(124, 634)
const HAND_SCALE := 0.6
## 袖口 (手の絵の上端の金の帯) の左右の端と、その上に足す袖の色・長さ
const SLEEVE_X := Vector2(24, 198)
const SLEEVE_COLOR := Color(0.5, 0.09, 0.06)
const SLEEVE_LENGTH := 900.0
## 腕の付け根 (画面の上の外)。指先との向きで手を傾ける
const SHOULDER := Vector2(0.5, -520.0)	# x は画面幅に対する割合
const HAND_MAX_TILT := deg_to_rad(38.0)
const HAND_FOLLOW_SPEED := 14.0
const HAND_REST_Y := 300.0	# 商品に乗っていないときは、カーソルを追ってもこれより下へは伸ばさない

var _card_row: HBoxContainer
var _ware_row: HBoxContainer
var _items: Array[Control] = []
var _gaps: Array[Control] = []
var _hand: TextureRect
var _tip := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_dim()
	_build_cloth()
	_build_back_button()
	_build_hand()


## 購入画面を開く: 布が下から、手が上から出てくる
func open() -> void:
	visible = true
	modulate.a = 0.0
	_tip = Vector2(size.x * SHOULDER.x, -200.0)
	create_tween().tween_property(self, "modulate:a", 1.0, 0.2)


func close() -> void:
	HandManager.tooltip.hide_tooltip()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(hide)


## 並んでいる商品 (カード → レリック → ポーション → カード削除 の順)
func get_items() -> Array[Control]:
	return _items


func clear_items() -> void:
	for item in _items + _gaps:
		item.queue_free()
	_items.clear()
	_gaps.clear()


## 商品を並べる。button は BaseShopButton を init 済みで渡す
func add_card(button: Control) -> void:
	_card_row.add_child(button)
	_items.append(button)


func add_ware(button: Control) -> void:
	_ware_row.add_child(button)
	_items.append(button)


## 下段の区切り (レリック | ポーション | カード削除)
func add_ware_gap(width: float, expand: bool = false) -> void:
	var gap := Control.new()
	gap.custom_minimum_size.x = width
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if expand:
		gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ware_row.add_child(gap)
	_gaps.append(gap)


func _process(delta: float) -> void:
	if not visible:
		return
	var mouse := get_local_mouse_position()
	var target := Vector2(mouse.x, min(mouse.y, HAND_REST_Y))
	var hovered := _get_hovered_item(mouse)
	if hovered != null:
		var rect := hovered.get_global_rect()
		rect.position -= get_global_rect().position
		target = Vector2(rect.get_center().x, rect.position.y + min(rect.size.y * 0.3, 44.0))
	_tip = _tip.lerp(target, 1.0 - exp(-HAND_FOLLOW_SPEED * delta))
	# 腕の付け根から指先へ向けて傾ける (絵は真下を指している)
	var shoulder := Vector2(size.x * SHOULDER.x, SHOULDER.y)
	var tilt := atan2(shoulder.x - _tip.x, _tip.y - shoulder.y)
	_hand.rotation = clamp(tilt, -HAND_MAX_TILT, HAND_MAX_TILT)
	_hand.position = _tip - _hand.pivot_offset


func _get_hovered_item(mouse: Vector2) -> Control:
	var global_mouse := mouse + get_global_rect().position
	for item in _items:
		if item.get_global_rect().has_point(global_mouse):
			return item
	return null


func _build_dim() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.6)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.offset_top = HUD_HEIGHT
	add_child(dim)


func _build_cloth() -> void:
	var cloth := PanelContainer.new()
	cloth.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloth.anchor_left = 0.5
	cloth.anchor_right = 0.5
	cloth.offset_left = -CLOTH_SIZE.x / 2.0
	cloth.offset_right = CLOTH_SIZE.x / 2.0
	cloth.offset_top = CLOTH_TOP
	cloth.offset_bottom = CLOTH_TOP + CLOTH_SIZE.y
	var style := StyleBoxFlat.new()
	style.bg_color = CLOTH_COLOR
	style.border_color = CLOTH_BORDER
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 16
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 26
	style.content_margin_bottom = 20
	cloth.add_theme_stylebox_override("panel", style)
	add_child(cloth)
	# 布の内側の刺繍の線
	var stitch := Panel.new()
	stitch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stitch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var stitch_style := StyleBoxFlat.new()
	stitch_style.draw_center = false
	stitch_style.border_color = Color(CLOTH_BORDER, 0.45)
	stitch_style.set_border_width_all(2)
	stitch_style.set_corner_radius_all(4)
	stitch_style.set_expand_margin_all(18)
	stitch.add_theme_stylebox_override("panel", stitch_style)
	cloth.add_child(stitch)

	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 30)
	cloth.add_child(rows)
	_card_row = HBoxContainer.new()
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_row.add_theme_constant_override("separation", 12)
	_card_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(_card_row)
	_ware_row = HBoxContainer.new()
	_ware_row.add_theme_constant_override("separation", 14)
	_ware_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(_ware_row)


func _build_back_button() -> void:
	var back := TextureButton.new()
	back.name = "BackButton"
	back.texture_normal = BACK_TEXTURE
	back.flip_h = true
	back.ignore_texture_size = true
	back.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	back.anchor_top = 1.0
	back.anchor_bottom = 1.0
	back.offset_left = 8
	back.offset_right = 178
	back.offset_top = -92
	back.offset_bottom = -8
	back.button_up.connect(back_pressed.emit)
	add_child(back)
	var label := ShopScene.make_button_label(tr("Back"), 24)
	label.offset_left = 14	# 矢じりの分だけ右へ寄せる
	back.add_child(label)
	ShopScene.add_hover_grow(back)


func _build_hand() -> void:
	_hand = TextureRect.new()
	_hand.texture = HAND_TEXTURE
	_hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hand.stretch_mode = TextureRect.STRETCH_SCALE
	_hand.size = HAND_TEXTURE.get_size() * HAND_SCALE
	_hand.pivot_offset = HAND_TIP * HAND_SCALE
	add_child(_hand)
	# 袖を画面の上の外まで伸ばす (手の絵は袖口で切れているので、腕が宙に浮いて見えないように)
	var sleeve := TextureRect.new()
	sleeve.show_behind_parent = true
	sleeve.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sleeve.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sleeve.position = Vector2(SLEEVE_X.x * HAND_SCALE, -SLEEVE_LENGTH)
	sleeve.size = Vector2((SLEEVE_X.y - SLEEVE_X.x) * HAND_SCALE, SLEEVE_LENGTH + 20)
	# 左右の縁は墨の線、そこから丸みのある布の陰影
	var shade := Gradient.new()
	shade.offsets = PackedFloat32Array([0.0, 0.04, 0.3, 0.55, 0.85, 0.96, 1.0])
	shade.colors = PackedColorArray([
		Color(0.1, 0.02, 0.02), SLEEVE_COLOR.darkened(0.45), SLEEVE_COLOR.lightened(0.12), SLEEVE_COLOR,
		SLEEVE_COLOR.darkened(0.35), SLEEVE_COLOR.darkened(0.55), Color(0.1, 0.02, 0.02)])
	var texture := GradientTexture2D.new()
	texture.gradient = shade
	texture.width = 64
	texture.height = 4
	sleeve.texture = texture
	_hand.add_child(sleeve)
