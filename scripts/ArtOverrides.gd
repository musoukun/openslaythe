class_name ArtOverrides
## Codex 生成アートの自動割り当て.
## データ生成後に呼ばれ、規約どおりの場所に画像があれば、そのオブジェクトのテクスチャを差し替える。
##   カード        external/sprites/cards/<color>/<object_id>.png
##   敵            external/sprites/enemies/<object_id>.png   (戦闘アニメーションも差し替え)
##   状態異常      external/sprites/status_effects/<object_id>.png
##   レリック      external/sprites/artifacts/<object_id>.png
##   消耗品        external/sprites/consumables/<object_id>.png
##   Act 背景      external/sprites/backgrounds/<act_id>.png
##   キャラアイコン external/sprites/characters/<id>/<id>_icon.png
## 敵の表示名は res://sprites/enemy_names.json ({"enemies": {id: {name, description}}}) から上書きする。

const ENEMY_NAMES_PATH := "res://sprites/enemy_names.json"
const HERO_IDLE_FPS := 5.0
const HERO_ATTACK_FPS := 12.0
const HERO_REACTION_FPS := 8.0


static func apply() -> void:
	for card: CardData in Global._id_to_card_data.values():
		var color := card.card_color_id.trim_prefix("color_")
		_override(card, "card_texture_path", "external/sprites/cards/%s/%s.png" % [color, card.object_id])
	for status: StatusEffectData in Global._id_to_status_data.values():
		_override(status, "status_effect_texture_path", "external/sprites/status_effects/%s.png" % status.object_id)
	for artifact: ArtifactData in Global._id_to_artifact_data.values():
		_override(artifact, "artifact_texture_path", "external/sprites/artifacts/%s.png" % artifact.object_id)
	for consumable: ConsumableData in Global._id_to_consumable_data.values():
		_override(consumable, "consumable_texture_path", "external/sprites/consumables/%s.png" % consumable.object_id)
	for act: ActData in Global._id_to_act_data.values():
		_override(act, "act_background_texture_path", "external/sprites/backgrounds/%s.png" % act.object_id)
	for character: CharacterData in Global._id_to_character_data.values():
		_override(character, "character_icon_texture_path", "external/sprites/characters/%s/%s_icon.png" % [character.object_id, character.object_id])
		_apply_hero_animations(character)
	for enemy: EnemyData in Global._id_to_enemy_data.values():
		if _override(enemy, "enemy_texture_path", "external/sprites/enemies/%s.png" % enemy.object_id):
			var animation_data: AnimationData = Global.get_animation_data(enemy.enemy_animation_id)
			if animation_data:
				animation_data.add_combatant_animations([enemy.enemy_texture_path])
	_apply_enemy_names()


## ドット絵アニメ (hero_idle_1..4.png / hero_attack_1..4.png) があればキャラのアニメに差し替える
static func _apply_hero_animations(character: CharacterData) -> void:
	var dir := "external/sprites/characters/%s/" % character.object_id
	var idle := _frame_paths(dir + "hero_idle_%d.png")
	var attack := _frame_paths(dir + "hero_attack_%d.png")
	var animation_data: AnimationData = Global.get_animation_data(character.character_animation_id)
	if idle.is_empty() or animation_data == null:
		return
	animation_data.add_animation(AnimationData.ANIMATION_IDLE, AnimationData.ANIMATION_IDLE, idle, HERO_IDLE_FPS)
	animation_data.add_animation(AnimationData.ANIMATION_ATTACK, AnimationData.ANIMATION_IDLE, attack if attack else idle, HERO_ATTACK_FPS)
	animation_data.add_animation(AnimationData.ANIMATION_DEATH, AnimationData.ANIMATION_NONE, [idle[0]], HERO_IDLE_FPS)
	# 被ダメージ / 防御のリアクション (終わったら待機へ)
	var hurt := _frame_paths(dir + "hero_hurt_%d.png")
	if hurt:
		animation_data.add_animation(AnimationData.ANIMATION_HURT, AnimationData.ANIMATION_IDLE, hurt, HERO_REACTION_FPS)
	var block := _frame_paths(dir + "hero_block_%d.png")
	if block:
		animation_data.add_animation(AnimationData.ANIMATION_BLOCK, AnimationData.ANIMATION_IDLE, block, HERO_REACTION_FPS)


## 連番ファイル (1 始まり) を存在する分だけ返す
static func _frame_paths(pattern: String) -> Array[String]:
	var paths: Array[String] = []
	var i := 1
	while FileAccess.file_exists(FileLoader._get_modified_filepath(pattern % i)):
		paths.append(pattern % i)
		i += 1
	return paths


## ファイルが存在すれば property をそのパスに差し替えて true を返す
static func _override(data: Object, property: String, partial_path: String) -> bool:
	if not FileAccess.file_exists(FileLoader._get_modified_filepath(partial_path)):
		return false
	data.set(property, partial_path)
	return true


static func _apply_enemy_names() -> void:
	if not FileAccess.file_exists(ENEMY_NAMES_PATH):
		return
	var json = JSON.parse_string(FileAccess.get_file_as_string(ENEMY_NAMES_PATH))
	if not json is Dictionary:
		return
	var enemies: Dictionary = json.get("enemies", {})
	for enemy_id in enemies:
		var enemy: EnemyData = Global._id_to_enemy_data.get(enemy_id)
		if enemy:
			enemy.enemy_name = enemies[enemy_id].get("name", enemy.enemy_name)
