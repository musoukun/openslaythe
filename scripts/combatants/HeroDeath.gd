class_name HeroDeath
## 主人公の倒れ方。
## 1. 倒れる絵 (AnimationData の death に hero_death_N.png が2枚以上) があれば先に流す
## 2. CharacterData.character_death_style の締めくくりで消える
##   dissolve  光って、火の粉にほどけて舞い上がる (絵の無い主人公の既定)
##   collapse  崩れ落ちたまま色が抜け、火の粉になって消える
##   explode   白く光って膨らみ、光の破片になって弾ける

const STYLE_DISSOLVE := "dissolve"
const STYLE_COLLAPSE := "collapse"
const STYLE_EXPLODE := "explode"

const EMBER_COLORS: Array[Color] = [Color(1.0, 0.96, 0.78), Color(1.0, 0.72, 0.32), Color(1.0, 0.42, 0.12, 0.0)]


## 倒れ方を最後まで演じる (await できる)
static func play(player: Player, style: String) -> void:
	var sprite := player.animated_sprite_2d
	if player._breath_tween and player._breath_tween.is_valid():
		player._breath_tween.kill()
	player.layered_health_bar.visible = false
	player.incoming_damage.visible = false

	var frames := sprite.sprite_frames
	if frames and frames.has_animation(AnimationData.ANIMATION_DEATH) and frames.get_frame_count(AnimationData.ANIMATION_DEATH) > 1:
		frames.set_animation_loop(AnimationData.ANIMATION_DEATH, false)
		sprite.play(AnimationData.ANIMATION_DEATH)
		await sprite.animation_finished
		await player.get_tree().create_timer(0.4).timeout
	elif style == STYLE_COLLAPSE:
		await _sink(player)

	match style:
		STYLE_EXPLODE:
			await _explode(player)
		STYLE_COLLAPSE:
			await _fade_to_embers(player, 1.6, Vector2(0, -30))
		_:
			await _dissolve(player)


## 絵が無いときの崩れ落ち: 沈みながら前に傾く
static func _sink(player: Player) -> void:
	var sprite := player.animated_sprite_2d
	var tween := player.create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "rotation", 0.35, 0.7)
	tween.tween_property(sprite, "offset", sprite.offset + Vector2(0, 30), 0.7)
	tween.tween_property(sprite, "self_modulate", Color(0.7, 0.6, 0.6), 0.7)
	await tween.finished


static func _fade_to_embers(player: Player, duration: float, embers_offset: Vector2) -> void:
	var sprite := player.animated_sprite_2d
	spawn_embers(player, 70, duration * 0.6, embers_offset)
	var tween := player.create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "self_modulate", Color(0.55, 0.22, 0.15, 0.0), duration)
	await tween.finished


static func _dissolve(player: Player) -> void:
	var sprite := player.animated_sprite_2d
	var tween := player.create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "self_modulate", Color(1.8, 1.6, 1.2), 0.35)
	await tween.finished
	spawn_embers(player, 90, 1.0, Vector2(0, -60))
	tween = player.create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "self_modulate:a", 0.0, 1.2)
	tween.tween_property(sprite, "offset", sprite.offset + Vector2(0, -14), 1.2)
	await tween.finished


static func _explode(player: Player) -> void:
	var sprite := player.animated_sprite_2d
	var tween := player.create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "self_modulate", Color(3.0, 2.8, 2.4), 0.45)
	tween.tween_property(sprite, "scale", sprite.scale * 1.12, 0.45)
	await tween.finished
	var burst := spawn_embers(player, 120, 0.6, Vector2(0, -80))
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.gravity = Vector2(0, 60)
	burst.initial_velocity_min = 160.0
	burst.initial_velocity_max = 380.0
	sprite.self_modulate.a = 0.0
	await player.get_tree().create_timer(0.8).timeout


## 体から火の粉を一度だけ噴き上げる。終わったら自分で消える
static func spawn_embers(player: Player, amount: int, emission_time: float, offset: Vector2) -> CPUParticles2D:
	var sprite := player.animated_sprite_2d
	var embers := make_embers(amount, 2.2)
	embers.one_shot = true
	embers.explosiveness = 1.0 - clampf(emission_time / embers.lifetime, 0.0, 1.0)
	embers.emission_rect_extents = Vector2(60, 70)
	embers.position = sprite.position + Vector2(0, BaseCombatant.SPRITE_FEET_Y) + offset
	sprite.get_parent().add_child(embers)
	embers.finished.connect(embers.queue_free)
	embers.emitting = true
	return embers


## 上へ漂う火の粉 (死亡画面の舞い続ける粒にも使う)
static func make_embers(amount: int, lifetime: float) -> CPUParticles2D:
	var embers := CPUParticles2D.new()
	embers.amount = amount
	embers.lifetime = lifetime
	embers.texture = _dot_texture()
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	embers.material = material
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.direction = Vector2.UP
	embers.spread = 25.0
	embers.gravity = Vector2(0, -40)
	embers.initial_velocity_min = 30.0
	embers.initial_velocity_max = 110.0
	embers.angular_velocity_min = -90.0
	embers.angular_velocity_max = 90.0
	embers.scale_amount_min = 0.25
	embers.scale_amount_max = 0.7
	embers.hue_variation_min = -0.03
	embers.hue_variation_max = 0.03
	var ramp := Gradient.new()
	ramp.colors = PackedColorArray(EMBER_COLORS)
	ramp.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	embers.color_ramp = ramp
	return embers


## 中心が明るく外へ消えるやわらかい点
static func _dot_texture() -> Texture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.5, 0.0)
	texture.width = 24
	texture.height = 24
	return texture
