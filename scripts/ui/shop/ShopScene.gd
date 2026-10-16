## ショップの場面: 遺跡の中の商人の天幕。右の緑の布に商人が座り、主人公がひとことしゃべる。
## 商人をクリックすると購入画面 (ShopCounter) が開く。右下の「次へ」でマップへ進む。
## 背景の絵は上部バーの下に敷くため、戦闘画面の背景として出す (Combat._update_background)。
## 主人公は戦闘画面の Player (待機の絵) がそのまま左の敷物に立つ。
## 子ノードはすべてコードで組む。ShopOverlay が持つ。
extends Control
class_name ShopScene

signal merchant_clicked
signal next_pressed

const BACKGROUND_PATH := "res://sprites/ui/shop_background.png"
const MERCHANT_TEXTURE := preload("res://sprites/ui/shop_merchant.png")
const NEXT_TEXTURE := preload("res://sprites/ui/shop_next_arrow.png")
const OUTLINE_SHADER := preload("res://sprites/shaders/outline.gdshader")

## 背景は画面いっぱいに引き伸ばして敷くので、商人の足元は画面に対する割合で置く (緑の布の中央)
const MERCHANT_FEET := Vector2(0.72, 0.765)
const MERCHANT_SIZE := Vector2(350, 350)
## 吹き出し (主人公の頭の右上)。1200x700 の画面での位置
const SPEECH_POS := Vector2(352, 140)
const SPEECH_WIDTH := 250.0
const SPEECH_SECONDS := 5.0
const TYPE_SPEED := 30.0	# 1秒あたりの文字数
const SPEECH_COLOR := Color(0.07, 0.13, 0.16, 0.94)
const RUNE_COLOR := Color(0.25, 0.79, 0.71)	# 共通の世界のルーンの青緑 #3FC9B5

## 主人公のひとこと (どの主人公でも言えるもの)
const HERO_LINES: Array[String] = [
	"Phew... finally, a place to catch my breath.",
	"Ooh, shiny things...",
	"Let's see what you've got.",
	"My coin purse is feeling heavy.",
]

var _merchant: TextureButton
var _merchant_material: ShaderMaterial
var _speech: PanelContainer
var _speech_label: RichTextLabel
var _speech_tween: Tween
var _next_button: TextureButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_merchant()
	_build_speech()
	_build_next_button()


## 場面を出す: 商人が現れ、主人公がひとことしゃべる
func enter() -> void:
	visible = true
	_merchant.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_merchant, "modulate:a", 1.0, 0.4)
	say(tr(HERO_LINES.pick_random()), 0.5)


## 主人公の吹き出しに1文字ずつ表示し、しばらくしたら消す
func say(text: String, delay: float = 0.0) -> void:
	if _speech_tween:
		_speech_tween.kill()
	_speech_label.text = text
	_speech_label.visible_ratio = 0.0
	_speech.modulate.a = 0.0
	var chars: int = max(_speech_label.get_total_character_count(), 1)
	_speech_tween = create_tween()
	_speech_tween.tween_interval(delay)
	_speech_tween.tween_property(_speech, "modulate:a", 1.0, 0.2)
	_speech_tween.tween_property(_speech_label, "visible_ratio", 1.0, chars / TYPE_SPEED)
	_speech_tween.tween_interval(SPEECH_SECONDS)
	_speech_tween.tween_property(_speech, "modulate:a", 0.0, 0.5)


func hide_speech() -> void:
	if _speech_tween:
		_speech_tween.kill()
	_speech.modulate.a = 0.0


func _build_merchant() -> void:
	_merchant = TextureButton.new()
	_merchant.name = "Merchant"
	_merchant.texture_normal = MERCHANT_TEXTURE
	_merchant.ignore_texture_size = true
	_merchant.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_place_at(_merchant, MERCHANT_FEET, Rect2(-MERCHANT_SIZE.x / 2.0, -MERCHANT_SIZE.y, MERCHANT_SIZE.x, MERCHANT_SIZE.y))
	_merchant.pivot_offset = Vector2(MERCHANT_SIZE.x / 2.0, MERCHANT_SIZE.y)
	_merchant.tooltip_text = ""
	# ホバーで白い縁取り (StS2 の商人と同じ「押せる」合図)
	_merchant_material = ShaderMaterial.new()
	_merchant_material.shader = OUTLINE_SHADER
	_merchant_material.set_shader_parameter("outline_color", Color(1, 1, 1, 0))
	_merchant_material.set_shader_parameter("width", 5.0)
	_merchant.material = _merchant_material
	_merchant.mouse_entered.connect(_on_merchant_hover.bind(true))
	_merchant.mouse_exited.connect(_on_merchant_hover.bind(false))
	_merchant.button_up.connect(merchant_clicked.emit)
	add_child(_merchant)
	# 座ったまま、ゆっくり息をする
	var breathe := _merchant.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(_merchant, "scale", Vector2(1.0, 1.025), 1.6)
	breathe.tween_property(_merchant, "scale", Vector2.ONE, 1.6)


func _on_merchant_hover(hovered: bool) -> void:
	var color := Color(1, 1, 1, 0.95) if hovered else Color(1, 1, 1, 0)
	_merchant_material.set_shader_parameter("outline_color", color)
	_merchant.self_modulate = Color(1.12, 1.12, 1.12) if hovered else Color.WHITE


func _build_speech() -> void:
	_speech = PanelContainer.new()
	_speech.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speech.position = SPEECH_POS
	_speech.custom_minimum_size.x = SPEECH_WIDTH
	_speech.modulate.a = 0.0
	var style := StyleBoxFlat.new()
	style.bg_color = SPEECH_COLOR
	style.border_color = Color(RUNE_COLOR, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(14)
	_speech.add_theme_stylebox_override("panel", style)
	add_child(_speech)
	_speech_label = RichTextLabel.new()
	_speech_label.fit_content = true
	_speech_label.scroll_active = false
	_speech_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speech_label.add_theme_font_size_override("normal_font_size", 18)
	_speech.add_child(_speech_label)
	# 吹き出しのしっぽ (左下の主人公の頭へ向ける)
	var tail := Polygon2D.new()
	tail.polygon = PackedVector2Array([Vector2(26, -2), Vector2(62, -2), Vector2(4, 30)])
	tail.color = SPEECH_COLOR
	_speech.resized.connect(func(): tail.position = Vector2(0, _speech.size.y))
	_speech.add_child(tail)


func _build_next_button() -> void:
	_next_button = TextureButton.new()
	_next_button.name = "NextButton"
	_next_button.texture_normal = NEXT_TEXTURE
	_next_button.ignore_texture_size = true
	_next_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_next_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_next_button.offset_left = -268
	_next_button.offset_top = -150
	_next_button.offset_right = -28
	_next_button.offset_bottom = -30
	_next_button.button_up.connect(next_pressed.emit)
	add_child(_next_button)
	var label := make_button_label(tr("Proceed"), 30)
	label.offset_right = -16	# 矢じりの分だけ左へ寄せる
	_next_button.add_child(label)
	add_hover_grow(_next_button)


## 赤い矢印の上に重ねる文字
static func make_button_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1, 0.96, 0.88))
	label.add_theme_color_override("font_outline_color", Color(0.25, 0.04, 0.03))
	label.add_theme_constant_override("outline_size", 8)
	return label


## ホバーで少し明るく大きくなる
static func add_hover_grow(button: Control) -> void:
	button.resized.connect(func(): button.pivot_offset = button.size / 2.0)
	button.mouse_entered.connect(func():
		var tween := button.create_tween().set_parallel()
		tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.1)
		tween.tween_property(button, "scale", Vector2.ONE * 1.08, 0.1))
	button.mouse_exited.connect(func():
		var tween := button.create_tween().set_parallel()
		tween.tween_property(button, "modulate", Color.WHITE, 0.1)
		tween.tween_property(button, "scale", Vector2.ONE, 0.1))


## 画面に対する割合の位置 (anchor) を基準に rect を置く
static func _place_at(control: Control, anchor: Vector2, rect: Rect2) -> void:
	control.anchor_left = anchor.x
	control.anchor_right = anchor.x
	control.anchor_top = anchor.y
	control.anchor_bottom = anchor.y
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.end.x
	control.offset_bottom = rect.end.y
