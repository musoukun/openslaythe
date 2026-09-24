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
	for enemy: EnemyData in Global._id_to_enemy_data.values():
		if _override(enemy, "enemy_texture_path", "external/sprites/enemies/%s.png" % enemy.object_id):
			var animation_data: AnimationData = Global.get_animation_data(enemy.enemy_animation_id)
			if animation_data:
				animation_data.add_combatant_animations([enemy.enemy_texture_path])
	_apply_enemy_names()


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
