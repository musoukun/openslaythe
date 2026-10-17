class_name BuildContent
## ビルド軸 (LoL の AD / AP に当たる「物理」と「竜炎」) の定義。
## カードに軸のタグを付け、ラン開始時に選ぶ武器レリックがその軸のダメージを伸ばす。
## 計算は InterceptorTagScaling が player_values["tag_damage_<tag>"] を読んで行う。
## GlobalProdDataGenerator.generate_production_data() から、カード登録後に register() が呼ばれる。

const TAG_PHYSICAL := "physical"
const TAG_REACTOR := "reactor"
const INTERCEPTOR_ID := "interceptor_tag_scaling"

## 爪・尾の攻撃。手数で伸びる
const PHYSICAL_CARD_IDS: Array[String] = [
	"card_basic_attack_green", "card_clippers", "card_reap", "card_wildflower", "card_vines",
	"card_green_searing_claw", "card_green_frenzied_claws", "card_green_claw_flurry",
]
## 竜炎の攻撃 (タグ ID は reactor のまま)。枚数は少ないが1発の上乗せが大きい
const REACTOR_CARD_IDS: Array[String] = [
	"card_meltdown", "card_big_boom", "card_fusion_cannon", "card_chloroplast", "card_conclusion",
]


static func register() -> void:
	_register_interceptor()
	_register_axis(TAG_PHYSICAL, "Physical", PHYSICAL_CARD_IDS)
	_register_axis(TAG_REACTOR, "Dragonfire", REACTOR_CARD_IDS)
	_register_weapon("artifact_weapon_pruning_blade", "Honed Claws", "Physical", TAG_PHYSICAL, 2, "artifact_increase_attack_on_rest")
	_register_weapon("artifact_weapon_reactor_gauntlet", "Dragonfire Gauntlet", "Dragonfire", TAG_REACTOR, 5, "artifact_boss_green")


static func _register_interceptor() -> void:
	# 武器が複数あっても登録は ID 単位で重複しないので、加算は1回だけ
	var interceptor: ActionInterceptorData = ActionInterceptorData.new(INTERCEPTOR_ID)
	interceptor.action_interceptor_priority = 10000 # 筋力と同じく、weaken / vulnerable の乗算より前
	interceptor.action_interceptor_modifies_parent = true
	interceptor.action_interceptor_script_path = Scripts.INTERCEPTOR_TAG_SCALING
	interceptor.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]
	Global.register_rod(interceptor)


## 軸のキーワード (カードのツールチップ) を作り、対象カードにタグとキーワードを付ける
static func _register_axis(tag: String, axis_name: String, card_ids: Array[String]) -> void:
	var keyword: KeywordData = KeywordData.new("keyword_" + tag)
	keyword.keyword_name = axis_name
	keyword.keyword_text_bb_code = "Deals bonus damage with a %s weapon" % axis_name
	Global.register_rod(keyword)

	for card_id: String in card_ids:
		var card_data: CardData = Global.get_card_data(card_id)
		if card_data == null:
			DebugLogger.log_error("BuildContent: No card with id \"%s\"" % card_id)
			continue
		card_data.card_tags.append(tag)
		card_data.card_keyword_object_ids.append(keyword.object_id)


## 武器レリックと、それをラン開始時に選ぶ選択肢を作る
static func _register_weapon(artifact_id: String, weapon_name: String, axis_name: String, tag: String, damage_bonus: int, texture_name: String) -> void:
	var value_name: String = InterceptorTagScaling.TAG_DAMAGE_VALUE_PREFIX + tag
	var description: String = "%s attacks deal +%d damage per hit." % [axis_name, damage_bonus]

	var weapon: ArtifactData = ArtifactData.new(artifact_id)
	weapon.artifact_name = weapon_name
	weapon.artifact_description = description
	weapon.artifact_texture_path = "external/sprites/artifacts/%s.png" % texture_name
	weapon.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	weapon.artifact_appears_in_artifact_packs = false
	weapon.artifact_interceptor_ids = [INTERCEPTOR_ID]
	weapon.artifact_add_actions = [_set_player_value(value_name, damage_bonus)]
	weapon.artifact_remove_actions = [_set_player_value(value_name, 0)]
	Global.register_rod(weapon)

	var option: RunStartOptionData = RunStartOptionData.new("run_start_option_" + artifact_id)
	option.run_start_option_bb_code = "[color=green]Equip %s[/color]: %s" % [weapon_name, description]
	option.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	option.run_start_option_actions = [{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": artifact_id}}]
	option.run_start_option_character_ids = ["character_green"] # 爪と竜炎は Vera 専用の武器
	Global.register_rod(option)


static func _set_player_value(value_name: String, value: int) -> Dictionary:
	return {Scripts.ACTION_UPDATE_PLAYER_VALUE: {"player_value_name": value_name, "new_player_value": value}}
