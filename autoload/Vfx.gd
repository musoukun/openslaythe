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
## 画面揺れ (trauma 方式: GDC 2016 "Juicing Your Cameras With Math")。
## 揺れの量は trauma (0〜1) の2乗に比例し、trauma は時間で減る。重ねるほど強く、自然に収まる
var _trauma: float = 0.0
var _shake_noise := FastNoiseLite.new()
var _shake_time: float = 0.0
var _last_ticks_usec: int = 0
const SHAKE_MAX_OFFSET := 18.0	# trauma 1 のときの最大のずれ (px)
const SHAKE_MAX_ROLL := 0.012	# trauma 1 のときの最大の傾き (rad)
const SHAKE_PX_PER_TRAUMA := 10.0	# vfx.json の screen_shake (px) を trauma に換算
const TRAUMA_DECAY := 1.4	# 1 秒あたりに減る trauma
const HIT_STOP_MAX := 0.15
## ダメージによる演出の強さ: 1 + damage / DAMAGE_POWER_SCALE (上限 DAMAGE_POWER_MAX)
const DAMAGE_POWER_SCALE := 25.0
const DAMAGE_POWER_MAX := 3.0
## コンボ: 1枚目は TRAUMA_BASE、以降 1枚ごとに TRAUMA_STEP ずつ強く (TRAUMA_CAP 枚目で頭打ち)
const COMBO_TRAUMA_BASE := 0.08
const COMBO_TRAUMA_STEP := 0.035
const COMBO_TRAUMA_CAP := 8
## 揺れの強さの倍率 (0 で揺れない。揺れが苦手な人向けの設定の受け口)
var shake_scale: float = 1.0
## コンボの音: 1枚ごとにドレミの順に上がるベル
const COMBO_SCALE_STEPS: Array[int] = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19]
## 効果音 (CC0。出どころは sounds/sfx/CREDITS.md)。「名前_番号.ogg」は同じ名前の中からランダムに鳴らす
const SFX_DIR := "res://sounds/sfx/"
var _sfx: Dictionary = {}	# 名前 -> Array[AudioStream]
var _last_draw_sound_msec: int = 0
var _hit_stop_until: float = 0.0
var _hit_stop_token: int = 0
const HIT_STOP_TIME_SCALE := 0.05


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	_load_config()

	Signals.combatant_damaged.connect(_on_combatant_damaged)
	Signals.combatant_block_added.connect(func(c):
		play_trigger("block_gain", c)
		play_sfx("block", -8.0))
	Signals.enemy_killed.connect(func(e):
		play_trigger("death", e)
		play_sfx("crumble", -2.0, 0.9)
		play_sfx("enemy_die", -8.0))
	Signals.card_drawn.connect(_on_card_drawn)
	Signals.player_money_changed.connect(func(delta: int):
		if delta > 0:
			play_sfx("coins", -6.0))
	Signals.card_played.connect(_on_card_played)
	Signals.card_exhausted.connect(_on_card_exhausted)
	Signals.energy_changed.connect(func(): play_trigger("energy_gain", _get_player()))
	Signals.player_health_changed.connect(_on_player_health_changed)
	Signals.combat_started.connect(func(_id):
		_last_player_health = _player_health()
		VeraFlameAura.update(_get_player() as Player))
	# 保険: 戦闘終了時は必ず通常速度に戻す
	Signals.combat_ended.connect(func(): Engine.time_scale = 1.0)
	_load_sfx()
	_shake_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_shake_noise.frequency = 0.6
	_last_ticks_usec = Time.get_ticks_usec()


## 揺れはヒットストップ中も実時間で動かす
func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var dt := (now - _last_ticks_usec) / 1000000.0
	_last_ticks_usec = now
	if _trauma <= 0.0:
		return
	_trauma = maxf(_trauma - TRAUMA_DECAY * dt, 0.0)
	_shake_time += dt * 60.0
	var vp := get_viewport()
	if _trauma == 0.0:
		vp.canvas_transform = Transform2D.IDENTITY
		return
	var amount := _trauma * _trauma
	var offset := Vector2(_shake_noise.get_noise_2d(1.0, _shake_time), _shake_noise.get_noise_2d(2.0, _shake_time)) * SHAKE_MAX_OFFSET * amount
	var roll := _shake_noise.get_noise_2d(3.0, _shake_time) * SHAKE_MAX_ROLL * amount
	# 画面の中心を軸に少し傾ける
	var center := vp.get_visible_rect().size / 2.0
	vp.canvas_transform = Transform2D(roll, center + offset) * Transform2D(0.0, -center)


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount * shake_scale, 0.0, 1.0)


## 効果音を鳴らす。pitch は基準の高さ、jitter はランダムな揺らぎ (同じ音の繰り返しに聞こえないように)
func play_sfx(sfx_name: String, volume_db: float = 0.0, pitch: float = 1.0, jitter: float = 0.05) -> void:
	var variants: Array = _sfx.get(sfx_name, [])
	if variants.is_empty():
		return
	var player := SoundManager.play_sound_with_pitch(variants.pick_random(), pitch * randf_range(1.0 - jitter, 1.0 + jitter))
	if player:
		player.volume_db = volume_db


func _load_sfx() -> void:
	var dir := DirAccess.open(SFX_DIR)
	if dir == null:
		return
	var seen := {}
	for file in dir.get_files():
		var ogg := file.trim_suffix(".import")	# 書き出し後は .ogg.import だけが残る
		if not ogg.ends_with(".ogg") or seen.has(ogg):
			continue
		seen[ogg] = true
		var stream: AudioStream = load(SFX_DIR + ogg)
		if stream == null:
			continue
		var base := ogg.get_basename()
		var parts := base.rsplit("_", true, 1)
		var sfx_name := parts[0] if parts.size() == 2 and parts[1].is_valid_int() else base
		if not _sfx.has(sfx_name):
			_sfx[sfx_name] = []
		_sfx[sfx_name].append(stream)


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
		if unblocked_damage > 0:
			play_sfx("player_hit", -6.0)
	if unblocked_damage > 0 and is_instance_valid(combatant):
		spawn_damage_number(_get_center(combatant), unblocked_damage, not combatant is Enemy)


func _flush_enemy_hits() -> void:
	var trigger := "attack_all" if _pending_enemy_hits.size() > 1 else "attack_single"
	var biggest: int = _pending_enemy_hits.map(func(h): return h[1]).max()
	# 当たった音: 石を砕く音。大ダメージは重い打撃と崩れる音を重ね、低く大きく鳴らす
	var power := damage_power(biggest)
	play_sfx("hit_stone", -8.0 + 3.0 * power, 1.1 - 0.08 * power)
	if biggest >= HEAVY_DAMAGE:
		play_sfx("hit_heavy", -4.0 + 2.0 * power, 1.0 - 0.06 * power)
		play_sfx("crumble", -10.0 + 3.0 * power, 0.9)
	for hit in _pending_enemy_hits:
		var t := "attack_heavy" if hit[1] >= HEAVY_DAMAGE and triggers.has("attack_heavy") else trigger
		play_trigger(t, hit[0], hit[1])
	_pending_enemy_hits.clear()


func _on_card_played(card_play_request) -> void:
	var card_data: CardData = card_play_request.card_data
	if card_data == null:
		return
	_after_card_played.call_deferred()
	play_sfx("card_play", -10.0)
	# 竜炎のカードは炎、ルカのマナで払う呪文は魔法の音 (どちらも元の音が小さいので持ち上げる)
	if card_data.card_tags.has("reactor"):
		play_sfx("dragonfire", 8.0)
	elif card_data.card_values.has("mana_cost"):
		play_sfx("magic", 4.0, 1.1)
	if card_data.object_id == PHOTOSYNTHESIS_CARD_ID:
		play_trigger("photosynthesis", _get_player())
	elif card_data.card_type == CardData.CARD_TYPES.POWER:
		play_trigger("card_play_power", _get_player())


## StatsHandler が使った枚数を数えたあとに呼ぶ
func _after_card_played() -> void:
	var combo := combo_count()
	# コンボ: このターンに使った枚数が増えるほど、カードを出すたびの揺れが少しずつ強くなる
	add_trauma(COMBO_TRAUMA_BASE + COMBO_TRAUMA_STEP * mini(combo, COMBO_TRAUMA_CAP))
	if combo >= 2:
		play_sfx("combo_bell", -6.0, pow(2.0, COMBO_SCALE_STEPS[mini(combo - 2, COMBO_SCALE_STEPS.size() - 1)] / 12.0), 0.0)
		play_sfx("combo_chips", -12.0 + minf(combo, 8.0), 1.0 + 0.04 * combo)


## 引くたびの音。ターン開始にまとめて引いたときは、間を空けて鳴らしすぎないようにする
func _on_card_drawn(_card_data: CardData) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_draw_sound_msec < 60:
		return
	_last_draw_sound_msec = now
	play_sfx("card_draw", -14.0)


func _on_card_exhausted(card_data: CardData) -> void:
	if card_data and card_data.object_id == WASTE_CARD_ID:
		play_trigger("waste_exhaust", _get_player())


func _on_player_health_changed() -> void:
	var health := _player_health()
	if _last_player_health >= 0 and health > _last_player_health:
		play_trigger("heal", _get_player())
	_last_player_health = health
	# Vera は HP が低いほど輪郭の炎が強まる
	VeraFlameAura.update(_get_player() as Player)


## BaseCombatant.add_status_effect_charges から呼ばれる
func on_status_applied(combatant: BaseCombatant, status_effect_data: StatusEffectData, charge_amount: int) -> void:
	if combatant is Player and status_effect_data.object_id == HeroBlueContent.STATUS_MANA and charge_amount > 0:
		play_sfx("mana_gain", -10.0, 1.0 + 0.05 * combatant.get_status_charges(HeroBlueContent.STATUS_MANA))
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
		_spawn_sprite(e, tex, pos, sqrt(damage_power(damage)))
	if e.has("particles"):
		_spawn_particles(e["particles"], pos, e.get("blend", "mix"))

	# 強い攻撃ほど揺れ・停止・エフェクトの大きさを強く (ダメージ50で3倍が上限)
	var power := damage_power(damage)
	if e.get("screen_shake", 0) > 0:
		shake(e["screen_shake"] * power)
	if e.get("hit_stop", 0) > 0:
		hit_stop(e["hit_stop"] * power)


## このターンに使ったカードの枚数 (戦闘外は 0)
func combo_count() -> int:
	var stats: CombatStatsData = StatsHandler.current_combat_stats
	return stats.get_turn_enum_stat(CombatStatsData.STATS.CARDS_PLAYED) if stats else 0


## ダメージ数字。大きいほど大きく、色は白 → 黄 → 橙 → 赤。大ダメージは跳ね上がって少し長く残る
func spawn_damage_number(pos: Vector2, damage: int, to_player: bool) -> void:
	var power := damage_power(damage)
	var label := Label.new()
	label.text = str(damage)
	var settings := LabelSettings.new()
	settings.font_size = int(26 * power)
	settings.outline_size = int(6 * power)
	settings.outline_color = Color(0.05, 0.05, 0.1)
	settings.font_color = Color("#ff5a5a") if to_player else _damage_color(damage)
	label.label_settings = settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(200, settings.font_size * 1.4)
	label.pivot_offset = label.size / 2.0
	label.position = pos - label.pivot_offset + Vector2(randf_range(-24, 24), -40)
	label.scale = Vector2.ONE * 0.3
	_layer.add_child(label)
	var rise := 50.0 + 30.0 * power
	var stay := 0.35 + 0.15 * power
	var tw := label.create_tween().set_ignore_time_scale(true)
	tw.tween_property(label, "scale", Vector2.ONE * 1.25, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "scale", Vector2.ONE, 0.08)
	tw.parallel().tween_property(label, "position:y", label.position.y - rise, stay + 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(stay - 0.17)
	tw.tween_callback(label.queue_free)


func _damage_color(damage: int) -> Color:
	if damage >= 35:
		return Color("#ff3b6b")
	if damage >= 20:
		return Color("#ff9a2e")
	if damage >= 10:
		return Color("#ffe14a")
	return Color.WHITE


## 1 から DAMAGE_POWER_MAX まで。ダメージが大きいほど大きい
func damage_power(damage: int) -> float:
	return clampf(1.0 + damage / DAMAGE_POWER_SCALE, 1.0, DAMAGE_POWER_MAX)


func _spawn_sprite(e: Dictionary, tex: Texture2D, pos: Vector2, size_power: float = 1.0) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.modulate = Color.from_string(e.get("color", "#ffffff"), Color.WHITE)
	s.material = _make_material(e.get("blend", "mix"))
	var duration: float = e.get("duration", 0.35)
	var scale_from: float = e.get("scale_from", 1.0) * size_power
	var scale_to: float = e.get("scale_to", 1.0) * size_power
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


## strength は vfx.json の screen_shake と同じ px 単位。trauma に足すので、続けて揺らすほど強くなる
func shake(strength: float, _duration: float = 0.25) -> void:
	add_trauma(strength / SHAKE_PX_PER_TRAUMA)


func hit_stop(duration: float) -> void:
	duration = minf(duration, HIT_STOP_MAX)
	var now := Time.get_ticks_msec() / 1000.0
	if now + duration <= _hit_stop_until:
		return	# 既に同じかそれより長い停止中
	_hit_stop_until = now + duration
	# 最後に呼ばれた停止だけが解除する (タイマーは時計より早く発火しうるので時刻比較はしない)
	_hit_stop_token += 1
	var token := _hit_stop_token
	Engine.time_scale = HIT_STOP_TIME_SCALE
	await get_tree().create_timer(duration, true, false, true).timeout
	if token == _hit_stop_token:
		Engine.time_scale = 1.0
		_hit_stop_until = 0.0

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
