## 幕の開始地点に立つ祝福のキャラ (立ち絵・名前・ひとこと) と、祝福を渡すときの演出。
## 子ノードはすべてコードで組む。RunStartOptions が show_giver() / bless() を呼ぶ。
extends Control
class_name BlessingGiver

## 1200x700 の画面での配置。下半分は祝福の柱の列 (RunStartOptions) なので、上の帯に収める
const SPRITE_RECT := Rect2(955, 62, 210, 200)	# 右上。足元を柱の列の上端 (y≈268) に合わせる
const SPEECH_RECT := Rect2(40, 92, 880, 0)	# 高さは文の長さで伸びる
const GLOW_SIZE := Vector2(340, 340)
const RUNE_COLOR := Color(0.25, 0.79, 0.71)	# 共通の世界のルーンの青緑 #3FC9B5
const GOLD_COLOR := Color(0.95, 0.66, 0.23)
const TYPE_SPEED := 45.0	# 1秒あたりの文字数

var _sprite: TextureRect
var _glow: TextureRect
var _name_label: RichTextLabel
var _line_label: RichTextLabel
var _speech: PanelContainer
var _bob_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow = _make_glow(GLOW_SIZE, Color(RUNE_COLOR, 0.55))
	_glow.position = SPRITE_RECT.get_center() - _glow.size / 2.0
	add_child(_glow)

	_sprite = TextureRect.new()
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite.position = SPRITE_RECT.position
	_sprite.size = SPRITE_RECT.size
	_sprite.pivot_offset = Vector2(SPRITE_RECT.size.x / 2.0, SPRITE_RECT.size.y)
	add_child(_sprite)

	_speech = PanelContainer.new()
	_speech.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speech.position = SPEECH_RECT.position
	_speech.custom_minimum_size.x = SPEECH_RECT.size.x
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.13, 0.14, 0.92)
	style.border_color = Color(RUNE_COLOR, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(14)
	_speech.add_theme_stylebox_override("panel", style)
	add_child(_speech)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_speech.add_child(box)
	_name_label = _make_label(22)
	_line_label = _make_label(17)
	box.add_child(_name_label)
	box.add_child(_line_label)


## キャラを登場させ、あいさつを1文字ずつ表示する
func show_giver(texture: Texture2D, name_bbcode: String, line_bbcode: String) -> void:
	visible = true
	modulate = Color.WHITE
	_sprite.texture = texture
	_sprite.modulate = Color(1, 1, 1, 0)
	_sprite.position = SPRITE_RECT.position + Vector2(0, 24)
	_glow.modulate = Color(1, 1, 1, 0)
	_glow.scale = Vector2.ONE
	_name_label.parse_bbcode(name_bbcode)
	_speech.modulate = Color(1, 1, 1, 0)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, "modulate:a", 1.0, 0.5)
	tween.tween_property(_sprite, "position:y", SPRITE_RECT.position.y, 0.6)
	tween.tween_property(_glow, "modulate:a", 1.0, 0.8)
	tween.tween_property(_speech, "modulate:a", 1.0, 0.3).set_delay(0.3)
	say(line_bbcode, 0.3)
	_start_bob()


## ひとことを差し替えて1文字ずつ表示する
func say(line_bbcode: String, delay: float = 0.0) -> void:
	_line_label.parse_bbcode(line_bbcode)
	_line_label.visible_ratio = 0.0
	var chars: int = max(_line_label.get_total_character_count(), 1)
	create_tween().tween_property(_line_label, "visible_ratio", 1.0, chars / TYPE_SPEED).set_delay(delay)


## 祝福を渡す演出: キャラが光り、光の玉が target (HUD の項目) へ飛んで弾ける。玉が届いたら終わる
func bless(line_bbcode: String, target: Control) -> void:
	say(line_bbcode)
	# キャラが光る
	var glow := create_tween().set_parallel()
	glow.tween_property(_sprite, "modulate", Color(1.9, 1.9, 1.7), 0.18)
	glow.tween_property(_glow, "scale", Vector2(1.5, 1.5), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	glow.chain().tween_property(_sprite, "modulate", Color.WHITE, 0.5)
	glow.tween_property(_glow, "scale", Vector2.ONE, 0.6)
	_burst(SPRITE_RECT.get_center(), 2.4)
	await get_tree().create_timer(0.35).timeout
	# 光の玉が飛ぶ
	var end: Vector2 = SPRITE_RECT.get_center()
	if target != null:
		end = target.get_global_rect().get_center() - get_global_rect().position
	await _fly_orb(SPRITE_RECT.get_center(), end)
	_burst(end, 1.2)
	if target != null:
		_pulse(target)


## キャラを消す
func hide_giver() -> void:
	if _bob_tween:
		_bob_tween.kill()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	visible = false


func _fly_orb(start: Vector2, end: Vector2) -> void:
	var orb := _make_glow(Vector2(110, 110), Color(1.0, 0.85, 0.45))
	add_child(orb)
	var trail := CPUParticles2D.new()
	trail.texture = _glow_texture(Vector2(40, 40), Color(RUNE_COLOR, 0.9))
	trail.material = _additive()
	trail.amount = 60
	trail.lifetime = 0.45
	trail.local_coords = false
	trail.gravity = Vector2.ZERO
	trail.spread = 180.0
	trail.initial_velocity_min = 10.0
	trail.initial_velocity_max = 40.0
	trail.scale_amount_min = 0.5
	trail.scale_amount_max = 1.2
	trail.color_ramp = _fade_ramp(RUNE_COLOR)
	trail.position = orb.size / 2.0
	orb.add_child(trail)
	# 上にふくらむ弧を描いて飛ぶ
	var control := (start + end) / 2.0 + Vector2(0, -180)
	var move := func(t: float) -> void:
		orb.position = start.lerp(control, t).lerp(control.lerp(end, t), t) - orb.size / 2.0
	var tween := create_tween()
	tween.tween_method(move, 0.0, 1.0, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	trail.emitting = false
	orb.modulate.a = 0.0
	get_tree().create_timer(0.5).timeout.connect(orb.queue_free)


## 中心から広がって消える光の輪
func _burst(center: Vector2, size_scale: float) -> void:
	var flash := _make_glow(Vector2(160, 160), Color(1.0, 0.85, 0.5))
	flash.position = center - flash.size / 2.0
	flash.pivot_offset = flash.size / 2.0
	flash.scale = Vector2(0.3, 0.3)
	add_child(flash)
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(flash, "scale", Vector2(size_scale, size_scale), 0.45)
	tween.tween_property(flash, "modulate:a", 0.0, 0.45)
	tween.chain().tween_callback(flash.queue_free)


## 受け取った HUD の項目をぽんと弾ませる
func _pulse(target: Control) -> void:
	target.pivot_offset = target.size / 2.0
	var tween := target.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", Vector2(1.3, 1.3), 0.12)
	tween.tween_property(target, "scale", Vector2.ONE, 0.25)
	var flash := target.create_tween()
	flash.tween_property(target, "modulate", Color(1.8, 1.7, 1.3), 0.1)
	flash.tween_property(target, "modulate", Color.WHITE, 0.4)


## 待っている間、後光がゆっくり明滅する
func _start_bob() -> void:
	if _bob_tween:
		_bob_tween.kill()
	_bob_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(_glow, "modulate:a", 0.6, 1.4).set_delay(0.8)
	_bob_tween.tween_property(_glow, "modulate:a", 1.0, 1.4)


func _make_label(font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", font_size)
	return label


## 中心が明るく外へ透明になる丸い光
func _make_glow(glow_size: Vector2, color: Color) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = _glow_texture(glow_size, color)
	rect.size = glow_size
	rect.pivot_offset = glow_size / 2.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = _additive()
	return rect


func _glow_texture(glow_size: Vector2, color: Color) -> GradientTexture2D:
	var texture := GradientTexture2D.new()
	texture.gradient = _fade_ramp(color)
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = int(glow_size.x)
	texture.height = int(glow_size.y)
	return texture


## 光を重ねるほど明るくなる (加算合成)
func _additive() -> CanvasItemMaterial:
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return material


func _fade_ramp(color: Color) -> Gradient:
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0.0))
	return ramp
