extends Node
## 戦闘VFXディレクター.
## Codex が設計した res://sprites/vfx/vfx.json (effects + triggers) を読み込み、
## ゲームのシグナルをトリガーに、テクスチャのスケール/回転/フェード + パーティクル +
## 画面揺れ + ヒットストップを手続き的に再生する。

const VFX_JSON_PATH := "res://sprites/vfx/vfx.json"
## 特定ステータス付与時の専用トリガー (無ければ buff/debuff 汎用)
const STATUS_TRIGGERS := {
	"status_effect_overheat": "overheat",
	"status_effect_overshield": "overshield_gain",
	"status_effect_pollen": "pollen_tick",
}
const PHOTOSYNTHESIS_CARD_ID := "card_photoelectric_synthesis"
const WASTE_CARD_ID := "card_waste"
## このダメージ以上は attack_heavy
const HEAVY_DAMAGE := 15

var effects: Dictionary = {}
var triggers: Dictionary = {}

var _layer: CanvasLayer
var _textures: Dictionary = {}
var _pending_enemy_hits: Array = []	# [combatant, damage] 同フレームの被弾をまとめて単体/全体を判定
var _last_player_health: int = -1
var _shake_tween: Tween
var _hit_stop_until: float = 0.0


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	_load_config()

	Signals.combatant_damaged.connect(_on_combatant_damaged)
	Signals.combatant_block_added.connect(func(c): play_trigger("block_gain", c))
	Signals.enemy_killed.connect(func(e): play_trigger("death", e))
	Signals.card_played.connect(_on_card_played)
	Signals.card_exhausted.connect(_on_card_exhausted)
	Signals.energy_changed.connect(func(): play_trigger("energy_gain", _get_player()))
	Signals.player_health_changed.connect(_on_player_health_changed)
	Signals.combat_started.connect(func(_id): _last_player_health = _player_health())


func _load_config() -> void:
	if not FileAccess.file_exists(VFX_JSON_PATH):
		push_warning("Vfx: %s not found" % VFX_JSON_PATH)
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(VFX_JSON_PATH))
	if data is Dictionary:
		effects = data.get("effects", {})
		triggers = data.get("triggers", {})


#region Signal handlers

func _on_combatant_damaged(combatant: BaseCombatant, unblocked_damage: int, _capped: int, _overkill: int) -> void:
	if combatant is Enemy:
		if _pending_enemy_hits.is_empty():
			_flush_enemy_hits.call_deferred()
		_pending_enemy_hits.append([combatant, unblocked_damage])
	else:
		play_trigger("enemy_attack", combatant, unblocked_damage)


func _flush_enemy_hits() -> void:
	var trigger := "attack_all" if _pending_enemy_hits.size() > 1 else "attack_single"
	for hit in _pending_enemy_hits:
		var t := "attack_heavy" if hit[1] >= HEAVY_DAMAGE and triggers.has("attack_heavy") else trigger
		play_trigger(t, hit[0], hit[1])
	_pending_enemy_hits.clear()


func _on_card_played(card_play_request) -> void:
	var card_data: CardData = card_play_request.card_data
	if card_data == null:
		return
	if card_data.object_id == PHOTOSYNTHESIS_CARD_ID:
		play_trigger("photosynthesis", _get_player())
	elif card_data.card_type == CardData.CARD_TYPES.POWER:
		play_trigger("card_play_power", _get_player())


func _on_card_exhausted(card_data: CardData) -> void:
	if card_data and card_data.object_id == WASTE_CARD_ID:
		play_trigger("waste_exhaust", _get_player())


func _on_player_health_changed() -> void:
	var health := _player_health()
	if _last_player_health >= 0 and health > _last_player_health:
		play_trigger("heal", _get_player())
	_last_player_health = health


## BaseCombatant.add_status_effect_charges から呼ばれる
func on_status_applied(combatant: BaseCombatant, status_effect_data: StatusEffectData, charge_amount: int) -> void:
	if charge_amount <= 0:
		return
	if STATUS_TRIGGERS.has(status_effect_data.object_id):
		play_trigger(STATUS_TRIGGERS[status_effect_data.object_id], combatant)
	elif status_effect_data.status_effect_type == StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF:
		play_trigger("status_debuff", combatant)
	elif status_effect_data.status_effect_type == StatusEffectData.STATUS_EFFECT_TYPES.BUFF:
		play_trigger("status_buff", combatant)

#endregion

#region Playback

func play_trigger(trigger: String, combatant: Node, damage: int = 0) -> void:
	if combatant == null or not is_instance_valid(combatant):
		return
	var pos := _get_center(combatant)
	for effect_id in triggers.get(trigger, []):
		play_effect(effect_id, pos, damage)


func play_effect(effect_id: String, pos: Vector2, damage: int = 0) -> void:
	var e: Dictionary = effects.get(effect_id, {})
	if e.is_empty():
		return
	var offset: Array = e.get("offset", [0, 0])
	pos += Vector2(offset[0], offset[1])

	var tex := _load_texture(e.get("texture", ""))
	if tex:
		_spawn_sprite(e, tex, pos)
	if e.has("particles"):
		_spawn_particles(e["particles"], pos, e.get("blend", "mix"))

	# 強い攻撃ほど揺れと停止を少し強く (ダメージ20で1.5倍が上限)
	var power := 1.0 + clampf(damage / 40.0, 0.0, 0.5)
	if e.get("screen_shake", 0) > 0:
		shake(e["screen_shake"] * power)
	if e.get("hit_stop", 0) > 0:
		hit_stop(e["hit_stop"] * power)


func _spawn_sprite(e: Dictionary, tex: Texture2D, pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.modulate = Color.from_string(e.get("color", "#ffffff"), Color.WHITE)
	s.material = _make_material(e.get("blend", "mix"))
	var duration: float = e.get("duration", 0.35)
	var scale_from: float = e.get("scale_from", 1.0)
	var scale_to: float = e.get("scale_to", 1.0)
	var rot_offset := randf_range(0.0, 360.0) if e.get("random_rotation", false) else 0.0
	s.scale = Vector2.ONE * scale_from
	s.rotation_degrees = e.get("rotation_from", 0.0) + rot_offset
	_layer.add_child(s)

	var tw := s.create_tween().set_parallel(true).set_ignore_time_scale(true)
	tw.tween_property(s, "scale", Vector2.ONE * scale_to, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "rotation_degrees", e.get("rotation_to", 0.0) + rot_offset, duration).set_ease(Tween.EASE_OUT)
	var base_alpha := s.modulate.a
	match e.get("alpha", "fade_out"):
		"flash":
			s.modulate.a = base_alpha
			tw.tween_property(s, "modulate:a", 0.0, duration * 0.6).set_delay(duration * 0.4)
		"fade_in_out":
			s.modulate.a = 0.0
			tw.tween_property(s, "modulate:a", base_alpha, duration * 0.3)
			tw.tween_property(s, "modulate:a", 0.0, duration * 0.7).set_delay(duration * 0.3)
		_:
			tw.tween_property(s, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(s.queue_free)


func _spawn_particles(p: Dictionary, pos: Vector2, blend: String) -> void:
	var tex := _load_texture(p.get("texture", ""))
	var parts := CPUParticles2D.new()
	parts.position = pos
	parts.texture = tex
	parts.material = _make_material(blend)
	parts.one_shot = true
	parts.explosiveness = 0.9
	parts.amount = int(p.get("amount", 10))
	parts.lifetime = p.get("lifetime", 0.6)
	parts.direction = Vector2.UP
	parts.spread = p.get("spread_deg", 360.0) / 2.0
	var speed: Array = p.get("speed", [80, 200])
	parts.initial_velocity_min = speed[0]
	parts.initial_velocity_max = speed[1]
	parts.gravity = Vector2(0, p.get("gravity", 0))
	var sc: Array = p.get("scale", [0.1, 0.2])
	parts.scale_amount_min = sc[0]
	parts.scale_amount_max = sc[1]
	parts.angle_min = -180.0
	parts.angle_max = 180.0
	parts.color = Color.from_string(p.get("color", "#ffffff"), Color.WHITE)
	var fade := Gradient.new()
	fade.set_color(0, Color.WHITE)
	fade.set_color(1, Color(1, 1, 1, 0))
	parts.color_ramp = fade
	_layer.add_child(parts)
	parts.emitting = true
	get_tree().create_timer(parts.lifetime + 0.2, true, false, true).timeout.connect(parts.queue_free)


func shake(strength: float, duration: float = 0.25) -> void:
	var vp := get_viewport()
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween().set_ignore_time_scale(true)
	var steps := 8
	for i in steps:
		var falloff := 1.0 - float(i) / steps
		var off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		_shake_tween.tween_method(func(v: Vector2): vp.canvas_transform = Transform2D(0, v),
			vp.canvas_transform.origin, off, duration / steps)
	_shake_tween.tween_callback(func(): vp.canvas_transform = Transform2D.IDENTITY)


func hit_stop(duration: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now + duration <= _hit_stop_until:
		return
	_hit_stop_until = now + duration
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	if Time.get_ticks_msec() / 1000.0 >= _hit_stop_until - 0.001:
		Engine.time_scale = 1.0

#endregion

#region Helpers

func _make_material(blend: String) -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	if blend == "add":
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


func _load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if not _textures.has(path):
		var res_path := path if path.begins_with("res://") else "res://" + path
		_textures[path] = load(res_path) if ResourceLoader.exists(res_path) else null
	return _textures[path]


func _get_center(combatant: Node) -> Vector2:
	var sprite = combatant.get("animated_sprite_2d")
	if sprite is AnimatedSprite2D and sprite.is_inside_tree():
		var frames: SpriteFrames = sprite.sprite_frames
		var h := 0.0
		if frames and frames.has_animation(sprite.animation) and frames.get_frame_count(sprite.animation) > 0:
			var t := frames.get_frame_texture(sprite.animation, 0)
			if t:
				h = t.get_height() * sprite.global_scale.y
		# スプライト中心 (centered の場合は位置 + offset、そうでなければ半分上)
		var center_offset: Vector2 = sprite.offset * sprite.global_scale if sprite.centered else Vector2(0, -h / 2.0)
		return sprite.global_position + center_offset
	if combatant is Control:
		return combatant.get_global_rect().get_center()
	return combatant.global_position


func _get_player() -> Node:
	return get_tree().get_first_node_in_group("players")


func _player_health() -> int:
	return Global.player_data.player_health if Global.player_data else -1

#endregion
