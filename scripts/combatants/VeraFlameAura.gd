class_name VeraFlameAura
extends RefCounted
## Vera (character_green) の HP が低いほど、体の輪郭に炎をまとわせる見た目 (ゲームバランスには関わらない)。
## Player の AnimatedSprite2D の縁取りを flame_outline.gdshader (縁取り + 炎) に差し替え、
## HP 割合から炎の強さ (intensity) を決めてなめらかに変える。Vera 以外は何もしない
## (ランの開始時に Player.reset_player が普通の縁取りへ戻す)。

const HERO_ID := "character_green"
const SHADER := preload("res://sprites/shaders/flame_outline.gdshader")
## HP 割合 → 炎の強さ。間は直線でつなぐ
## 100〜80%: うっすら / 50〜25%: はっきり / 25% 未満: かなり激しく、0 に近いほどさらに強く
const STAGES: Array[Vector2] = [
	Vector2(1.0, 0.12),
	Vector2(0.8, 0.2),
	Vector2(0.5, 0.45),
	Vector2(0.25, 0.7),
	Vector2(0.0, 1.0),
]
const TWEEN_TIME := 0.5


static func intensity_for(health: int, health_max: int) -> float:
	var ratio := clampf(float(health) / maxf(health_max, 1), 0.0, 1.0)
	for i in range(1, STAGES.size()):
		var hi: Vector2 = STAGES[i - 1]
		var lo: Vector2 = STAGES[i]
		if ratio >= lo.x:
			return lerpf(lo.y, hi.y, (ratio - lo.x) / (hi.x - lo.x))
	return STAGES[-1].y


## 今の HP に合わせて炎を更新する (戦闘開始時と HP が変わったときに Vfx から呼ばれる)
static func update(player: Player) -> void:
	if player == null or Global.player_data == null:
		return
	if Global.player_data.player_character_object_id != HERO_ID:
		return
	var sprite := player.animated_sprite_2d
	var material := sprite.material as ShaderMaterial
	if material == null or material.shader != SHADER:
		material = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter("intensity", 0.0)
		sprite.material = material
	var target := intensity_for(Global.player_data.player_health, Global.player_data.player_health_max)
	sprite.create_tween().tween_property(material, "shader_parameter/intensity", target, TWEEN_TIME)
