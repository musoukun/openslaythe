class_name VeraRageForm
extends RefCounted
## Vera (character_green) の HP が下がるほど、待機絵を竜に近い姿 (hero_rage_idle_2〜4.png) に切り替える (見た目だけ)。
## 段階: HP 50% 以下で 2 (前かがみ)、25% 以下で 3 (小さな翼)、10% 以下で 4 (四足の構え)。回復すれば戻る。
## 共有の SpriteFrames を書き換えないよう、初めて切り替えるときに複製して自分用にする
## (ランの開始時に Player.reset_player が共有のものへ戻す)。

const HERO_ID := "character_green"
const STAGE_PATH := "external/sprites/characters/character_green/hero_rage_idle_%d.png"
## この HP 割合以下で段階 2, 3, 4
const STAGE_THRESHOLDS: Array[float] = [0.5, 0.25, 0.1]
const META_ORIGINAL := "vera_rage_original_idle"
const META_STAGE := "vera_rage_stage"
## 段階が上がったときの「ぐっと膨らむ」演出
const POP_SCALE := 1.08
const POP_TIME := 0.25


static func stage_for(health: int, health_max: int) -> int:
	var ratio := float(health) / maxf(health_max, 1)
	var stage := 1
	for threshold in STAGE_THRESHOLDS:
		if ratio <= threshold:
			stage += 1
	return stage


## 今の HP に合わせて待機絵を切り替える (戦闘開始時と HP が変わったときに Vfx から呼ばれる)
static func update(player: Player) -> void:
	if player == null or Global.player_data == null:
		return
	if Global.player_data.player_character_object_id != HERO_ID:
		return
	var sprite := player.animated_sprite_2d
	var frames := sprite.sprite_frames
	if frames == null or not frames.has_animation(AnimationData.ANIMATION_IDLE):
		return
	var stage := stage_for(Global.player_data.player_health, Global.player_data.player_health_max)
	if not frames.has_meta(META_ORIGINAL):
		if stage == 1:
			return
		frames = frames.duplicate()
		frames.set_meta(META_ORIGINAL, frames.get_frame_texture(AnimationData.ANIMATION_IDLE, 0))
		var animation := sprite.animation
		sprite.sprite_frames = frames
		sprite.play(animation)
	var previous: int = frames.get_meta(META_STAGE, 1)
	if previous == stage:
		return
	var texture: Texture2D = frames.get_meta(META_ORIGINAL)
	if stage > 1:
		var stage_texture := FileLoader.load_texture(STAGE_PATH % stage)
		if stage_texture == null:
			return
		texture = stage_texture
	frames.set_frame(AnimationData.ANIMATION_IDLE, 0, texture)
	frames.set_meta(META_STAGE, stage)
	if stage > previous:
		var tween := sprite.create_tween()
		tween.tween_property(sprite, "scale", Vector2.ONE * POP_SCALE, POP_TIME * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", Vector2.ONE, POP_TIME * 0.6)
		Vfx.add_trauma(0.25)
