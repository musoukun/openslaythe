class_name VeraRageForm
extends RefCounted
## Vera (character_green) の HP が下がるほど、絵を竜に近い姿 (hero_rage<段階>_<アニメ>_<番号>.png) に切り替える (見た目だけ)。
## 段階: HP 50% 以下で 2 (前かがみ)、25% 以下で 3 (小さな翼)、10% 以下で 4 (四足の構え)。回復すれば戻る。
## 待機・攻撃・被弾・防御を切り替える (その段階の絵が無いアニメは元の絵のまま)。
## 共有の SpriteFrames を書き換えないよう、初めて切り替えるときに複製して自分用にする
## (ランの開始時に Player.reset_player が共有のものへ戻す)。

const HERO_ID := "character_green"
const FRAME_PATH := "external/sprites/characters/character_green/hero_rage%d_%s_%%d.png"
## アニメ名 -> ファイル名の部分
const ANIMATION_FILES := {
	AnimationData.ANIMATION_IDLE: "idle",
	AnimationData.ANIMATION_ATTACK: "attack",
	AnimationData.ANIMATION_HURT: "hurt",
	AnimationData.ANIMATION_BLOCK: "block",
}
## この HP 割合以下で段階 2, 3, 4
const STAGE_THRESHOLDS: Array[float] = [0.5, 0.25, 0.1]
const META_ORIGINAL := "vera_rage_original"	# アニメ名 -> 元のコマ (Array[Texture2D])
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


## 今の HP に合わせて絵を切り替える (戦闘開始時と HP が変わったときに Vfx から呼ばれる)
static func update(player: Player) -> void:
	if player == null or Global.player_data == null:
		return
	if Global.player_data.player_character_object_id != HERO_ID:
		return
	var sprite := player.animated_sprite_2d
	var frames := sprite.sprite_frames
	if frames == null:
		return
	var stage := stage_for(Global.player_data.player_health, Global.player_data.player_health_max)
	if not frames.has_meta(META_ORIGINAL):
		if stage == 1:
			return
		frames = _make_own_copy(sprite)
	var previous: int = frames.get_meta(META_STAGE, 1)
	if previous == stage:
		return
	var original: Dictionary = frames.get_meta(META_ORIGINAL)
	for animation: String in original:
		var textures: Array = original[animation]
		if stage > 1:
			var stage_textures := _load_stage_frames(stage, animation)
			if not stage_textures.is_empty():
				textures = stage_textures
		_replace_frames(sprite, animation, textures)
	frames.set_meta(META_STAGE, stage)
	if stage > previous:
		var tween := sprite.create_tween()
		tween.tween_property(sprite, "scale", Vector2.ONE * POP_SCALE, POP_TIME * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", Vector2.ONE, POP_TIME * 0.6)
		Vfx.add_trauma(0.25)


## 共有の SpriteFrames を複製してスプライトに付け、元のコマを覚えておく
static func _make_own_copy(sprite: AnimatedSprite2D) -> SpriteFrames:
	var frames: SpriteFrames = sprite.sprite_frames.duplicate()
	var original := {}
	for animation: String in ANIMATION_FILES:
		if not frames.has_animation(animation):
			continue
		var textures: Array[Texture2D] = []
		for i in frames.get_frame_count(animation):
			textures.append(frames.get_frame_texture(animation, i))
		original[animation] = textures
	frames.set_meta(META_ORIGINAL, original)
	var animation := sprite.animation
	var frame := sprite.frame
	sprite.sprite_frames = frames
	sprite.play(animation)
	sprite.frame = frame
	return frames


static func _load_stage_frames(stage: int, animation: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for path in ArtOverrides._frame_paths(FRAME_PATH % [stage, ANIMATION_FILES[animation]]):
		var texture := FileLoader.load_texture(path)
		if texture:
			textures.append(texture)
	return textures


## アニメのコマを入れ替える (再生中のアニメはコマ数が減っても範囲外にならないようにする)
static func _replace_frames(sprite: AnimatedSprite2D, animation: String, textures: Array) -> void:
	var frames := sprite.sprite_frames
	frames.clear(animation)
	for texture: Texture2D in textures:
		frames.add_frame(animation, texture)
	if sprite.animation == animation:
		sprite.set_frame_and_progress(mini(sprite.frame, textures.size() - 1), sprite.frame_progress)
