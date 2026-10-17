class_name HeroBlueContent
## 2人目の主人公「青の少年魔法剣士」(設計: docs/hero_blue_design.md)。
## マナ (繰り越せる2つ目の資源) を溜め、呪文を連打する (ヘイスト) か、固有技「蒼刃」を強化して振る。
## マナと蒼刃の強化は状態異常の charges で持つ。支払いは同じ状態異常を負の charges で付けて減らし、
## 足りるかどうかは ValidatorStatusCharges で判定する。
## GlobalProdDataGenerator から register_character() (add_characters の中) と register_cards() (add_cards の後) が呼ばれる。

const COLOR := "blue"
const CHARACTER_ID := "character_blue"

const STATUS_MANA := "status_effect_mana"
const STATUS_BLADE_EDGE := "status_effect_blade_edge"
const STATUS_BLADE_TWIN := "status_effect_blade_twin"
const STATUS_MANA_SPRING := "status_effect_mana_spring"
const TAG_MANA_BLADE := "mana_blade"
const TAG_BLADE_SUPPORT := "blade_support" # 蒼刃を強化するカード (「刃の呼び声」で山札から探せる)
const MANA_MAX := 10

const STATUS_ART := "external/sprites/status_effects/status_effect_blue.png"
const CARD_ART := "external/sprites/cards/blue/card_blue.png"


#region Character

static func register_character() -> void:
	_register_statuses()
	_register_interceptors()
	_register_starter_relic()

	var character: CharacterData = CharacterData.new(CHARACTER_ID)
	character.character_player_id = "player_" + COLOR
	character.character_name = "Luca Azurine"
	character.character_description = "A quiet young spellblade from the cliffside kingdom. He gathers floating mana orbs and pours them into a blade of blue light, or spends them to cast spell after spell in a single breath."
	character.character_color_id = "color_" + COLOR
	character.character_starting_health = 68
	character.character_death_style = "dissolve" # 光の粒になって消える
	character.character_starting_card_draft_card_pack_ids = ["card_pack_" + COLOR]
	character.character_starting_artifact_ids = ["artifact_blue_earring"]
	character.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_" + COLOR]
	character.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_" + COLOR]
	character.character_starting_card_object_ids = [
		"card_basic_attack_blue", "card_basic_attack_blue", "card_basic_attack_blue", "card_basic_attack_blue",
		"card_basic_block_blue", "card_basic_block_blue", "card_basic_block_blue", "card_basic_block_blue",
		"card_blue_mana_blade", "card_blue_gather_mana", "card_blue_flash",
	]

	# アニメは ArtOverrides が external/sprites/characters/character_blue/hero_*_N.png から差し替える
	var animation: AnimationData = AnimationData.new("animation_" + CHARACTER_ID)
	character.character_animation_id = animation.object_id
	var placeholder: Array[String] = ["external/sprites/characters/%s/%s.png" % [CHARACTER_ID, CHARACTER_ID]]
	animation.add_combatant_animations(placeholder, placeholder, placeholder)
	Global.register_rod(animation)

	Global.register_rod(character)


static func _register_statuses() -> void:
	var mana: StatusEffectData = _status(STATUS_MANA, "Mana")
	mana.status_effect_charge_upper_bound = MANA_MAX
	Global.register_rod(mana)

	var edge: StatusEffectData = _status(STATUS_BLADE_EDGE, "Blade Edge")
	edge.status_effect_interceptor_ids = ["interceptor_mana_blade_edge"]
	Global.register_rod(edge)

	var twin: StatusEffectData = _status(STATUS_BLADE_TWIN, "Blade Twin")
	twin.status_effect_interceptor_ids = ["interceptor_mana_blade_twin"]
	Global.register_rod(twin)

	# 毎ターンのはじめに、charges の数だけマナを得る
	var spring: StatusEffectData = _status(STATUS_MANA_SPRING, "Mana Spring")
	spring.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN]
	spring.status_effect_player_process_actions = [{Scripts.ACTION_APPLY_STATUS: {
		"status_effect_object_id": STATUS_MANA,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
		"custom_key_names": {"status_charge_amount": "invoking_status_effect_charges"},
	}}]
	Global.register_rod(spring)


## 戦闘のあいだ減らない (自然減少しない) 主人公用の強化状態
static func _status(id: String, status_name: String) -> StatusEffectData:
	var status: StatusEffectData = StatusEffectData.new(id)
	status.status_effect_name = status_name
	status.status_effect_texture_path = STATUS_ART
	status.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status.status_effect_decay_rate = 0
	status.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status.status_effect_action_process_times = []
	return status


static func _register_interceptors() -> void:
	# 蒼刃のダメージ (ActionAttack を書き換えるので、手札の数値プレビューにも出る)
	var edge: ActionInterceptorData = ActionInterceptorData.new("interceptor_mana_blade_edge")
	edge.action_interceptor_priority = 10000 # 筋力と同じく、weaken / vulnerable の乗算より前
	edge.action_interceptor_modifies_parent = true
	edge.action_interceptor_script_path = Scripts.INTERCEPTOR_MANA_BLADE_EDGE
	edge.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]
	Global.register_rod(edge)

	# 蒼刃の攻撃回数 (攻撃を生成する側で回数を増やす)
	var twin: ActionInterceptorData = ActionInterceptorData.new("interceptor_mana_blade_twin")
	twin.action_interceptor_priority = 10000
	twin.action_interceptor_modifies_parent = true
	twin.action_interceptor_script_path = Scripts.INTERCEPTOR_MANA_BLADE_TWIN
	twin.action_intercepted_action_paths = [Scripts.ACTION_ATTACK_GENERATOR]
	Global.register_rod(twin)


static func _register_starter_relic() -> void:
	var earring: ArtifactData = ArtifactData.new("artifact_blue_earring")
	earring.artifact_name = "Azure Crystal Earring"
	earring.artifact_description = "At the start of your turn, gain 1 Mana."
	earring.artifact_texture_path = "external/sprites/artifacts/artifact_blue.png"
	earring.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	earring.artifact_color_id = "color_" + COLOR
	earring.artifact_appears_in_artifact_packs = false
	earring.artifact_turn_start_actions = [_gain_mana_fixed(1)]
	Global.register_rod(earring)

#endregion


#region Cards

static func register_cards() -> void:
	var keyword: KeywordData = KeywordData.new("keyword_mana")
	keyword.keyword_name = "Mana"
	keyword.keyword_text_bb_code = "Carries over between turns (up to 10). Spend it on spells or on your Mana Blade."
	Global.register_rod(keyword)

	# 固有技「蒼刃」: 保留。使うと山札の一番上に戻り、次のターンにまた引ける (毎ターン1回振れる)
	var blade: CardData = _card("card_blue_mana_blade", "Mana Blade", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.BASIC, 1,
		"Deal [damage] damage. Retain. Returns to the top of your draw pile.",
		{"damage": 10, "number_of_attacks": 1}, {"damage": 3})
	blade.card_appears_in_card_packs = false
	blade.card_is_retained = true
	blade.card_first_shuffle_priority = 1
	blade.card_play_destination = HandManager.DRAW_PILE
	blade.card_tags = [TAG_MANA_BLADE]
	blade.card_keyword_object_ids = ["keyword_retain"]
	blade.card_play_actions = [_attack()]
	Global.register_rod(blade)

	# --- マナを生む ---
	var gather: CardData = _card("card_blue_gather_mana", "Gather Mana", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.BASIC, 1,
		"Gain [mana_gain] Mana. Gain [block] block.", {"mana_gain": 2, "block": 4}, {"mana_gain": 1})
	gather.card_appears_in_card_packs = false
	gather.card_play_actions = [_gain_mana(), _block()]
	_register_skill(gather)

	var meditate: CardData = _card("card_blue_meditate", "Meditate", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Gain [mana_gain] Mana. Draw [draw_count] card.", {"mana_gain": 3, "draw_count": 1}, {"mana_gain": 1})
	meditate.card_play_actions = [_gain_mana(), _draw()]
	_register_skill(meditate)

	var quickcast: CardData = _card("card_blue_quickcast", "Quickcast", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Draw [draw_count] cards. Gain [mana_gain] Mana.", {"draw_count": 2, "mana_gain": 1}, {"draw_count": 1})
	quickcast.card_play_actions = [_draw(), _gain_mana()]
	_register_skill(quickcast)

	var edge_strike: CardData = _card("card_blue_arcane_edge", "Arcane Edge", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage. Gain [mana_gain] Mana.", {"damage": 7, "number_of_attacks": 1, "mana_gain": 1}, {"damage": 3})
	edge_strike.card_play_actions = [_attack(), _gain_mana()]
	Global.register_rod(edge_strike)

	var spring: CardData = _card("card_blue_mana_spring", "Mana Spring", CardData.CARD_TYPES.POWER, CardData.CARD_RARITIES.UNCOMMON, 1,
		"At the start of your turn, gain [status_charge_amount] Mana.", {"status_charge_amount": 1}, {"status_charge_amount": 1})
	spring.card_play_actions = [_apply_to_player(STATUS_MANA_SPRING)]
	_register_skill(spring)

	# --- ヘイスト: エネルギーの代わりにマナで払う呪文 ---
	var flash: CardData = _mana_card("card_blue_flash", "Blue Flash", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.BASIC, 1,
		"Deal [damage] damage.", {"damage": 6, "number_of_attacks": 1}, {"damage": 3})
	flash.card_appears_in_card_packs = false
	flash.card_play_actions = [_spend_mana(), _attack()]
	Global.register_rod(flash)

	var shards: CardData = _mana_card("card_blue_mana_shards", "Mana Shards", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage [number_of_attacks] times.", {"damage": 3, "number_of_attacks": 2}, {"damage": 1})
	shards.card_play_actions = [_spend_mana(), _attack()]
	Global.register_rod(shards)

	var ward: CardData = _mana_card("card_blue_frost_ward", "Frost Ward", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 2,
		"Gain [block] block.", {"block": 9}, {"block": 3})
	ward.card_play_actions = [_spend_mana(), _block()]
	_register_skill(ward)

	var torrent: CardData = _mana_card("card_blue_torrent", "Azure Torrent", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.RARE, 3,
		"Deal [damage] damage to ALL enemies [number_of_attacks] times.", {"damage": 4, "number_of_attacks": 3}, {"damage": 2})
	torrent.card_requires_target = false
	torrent.card_play_actions = [_spend_mana(), _attack(BaseAction.TARGET_OVERRIDES.ALL_ENEMIES)]
	Global.register_rod(torrent)

	# --- 蒼刃: マナを注いで固有技を強化する (戦闘の終わりまで残る) ---
	var extend: CardData = _mana_card("card_blue_extend_blade", "Extend Blade", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 2,
		"Your Mana Blade deals [status_charge_amount] more damage this combat.", {"status_charge_amount": 6}, {"status_charge_amount": 3})
	extend.card_tags = [TAG_BLADE_SUPPORT]
	extend.card_play_actions = [_spend_mana(), _apply_to_player(STATUS_BLADE_EDGE)]
	_register_skill(extend)

	var twin: CardData = _mana_card("card_blue_twin_blade", "Twin Blade", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.RARE, 4,
		"Your Mana Blade hits [status_charge_amount] more time this combat.", {"status_charge_amount": 1}, {"mana_cost": -1, "mana_spend": 1})
	twin.card_energy_cost = 1
	twin.card_tags = [TAG_BLADE_SUPPORT]
	twin.card_play_actions = [_spend_mana(), _apply_to_player(STATUS_BLADE_TWIN)]
	_register_skill(twin)

	_register_more_cards()


## 2 回目の追加: エネルギー 0・マナだけで使うカード、山札から探すカード、デッキを圧縮するカード
static func _register_more_cards() -> void:
	# --- エネルギー 0、マナだけで使う ---
	var bolt: CardData = _mana_card("card_blue_azure_bolt", "Azure Bolt", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage.", {"damage": 6, "number_of_attacks": 1}, {"damage": 3})
	bolt.card_play_actions = [_spend_mana(), _attack()]
	Global.register_rod(bolt)

	var veil: CardData = _mana_card("card_blue_azure_veil", "Azure Veil", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Gain [block] block.", {"block": 6}, {"block": 3})
	veil.card_play_actions = [_spend_mana(), _block()]
	_register_skill(veil)

	var drop: CardData = _mana_card("card_blue_mana_drop", "Mana Drop", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 2,
		"Draw [draw_count] cards.", {"draw_count": 2}, {"draw_count": 1})
	drop.card_play_actions = [_spend_mana(), _draw()]
	_register_skill(drop)

	var starfall: CardData = _mana_card("card_blue_starfall", "Starfall", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.RARE, 5,
		"Deal [damage] damage to ALL enemies.", {"damage": 14, "number_of_attacks": 1}, {"damage": 5})
	starfall.card_requires_target = false
	starfall.card_play_actions = [_spend_mana(), _attack(BaseAction.TARGET_OVERRIDES.ALL_ENEMIES)]
	Global.register_rod(starfall)

	# --- 山札から探す ---
	var minds_eye: CardData = _card("card_blue_minds_eye", "Mind's Eye", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 1,
		"Choose a card in your draw pile and put it into your hand. Exhaust.", {}, {})
	minds_eye.card_play_destination = HandManager.EXHAUST_PILE
	minds_eye.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	minds_eye.card_play_actions = [_pick_one(HandManager.DRAW_PILE, "Choose a card to put into your hand.", [{Scripts.ACTION_ADD_CARDS_TO_HAND: {}}])]
	_register_skill(minds_eye)

	var blade_call: CardData = _mana_card("card_blue_blade_call", "Call of the Blade", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Put an Extend Blade or Twin Blade from your draw pile into your hand. Draw [draw_count] card.", {"draw_count": 1}, {"draw_count": 1})
	blade_call.card_play_actions = [_spend_mana(),
		_pick_one(HandManager.DRAW_PILE, "Choose a blade card to put into your hand.", [{Scripts.ACTION_ADD_CARDS_TO_HAND: {}}],
			[{Scripts.VALIDATOR_CARD_TAG: {"card_tags": [TAG_BLADE_SUPPORT]}}]),
		_draw()]
	_register_skill(blade_call)

	# --- デッキを圧縮する (廃棄して、残りのカードを何度も引けるようにする) ---
	var clear_mind: CardData = _card("card_blue_clear_mind", "Clear Mind", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Exhaust a card in your hand. Gain [mana_gain] Mana.", {"mana_gain": 2}, {"mana_gain": 1})
	clear_mind.card_play_actions = [_pick_one(HandManager.HAND_PILE, "Choose a card to Exhaust.", [{Scripts.ACTION_EXHAUST_CARDS: {}}]), _gain_mana()]
	_register_skill(clear_mind)

	var stillness: CardData = _mana_card("card_blue_stillness", "Stillness", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 1,
		"Exhaust a card in your discard pile. Draw [draw_count] cards.", {"draw_count": 2}, {"draw_count": 1})
	stillness.card_play_actions = [_spend_mana(),
		_pick_one(HandManager.DISCARD_PILE, "Choose a card to Exhaust.", [{Scripts.ACTION_EXHAUST_CARDS: {}}]), _draw()]
	_register_skill(stillness)


static func _card(id: String, card_name: String, type: int, rarity: int, energy: int, description: String, values: Dictionary, upgrades: Dictionary) -> CardData:
	var card: CardData = CardData.new(id)
	card.card_name = card_name
	card.card_color_id = "color_" + COLOR
	card.card_texture_path = CARD_ART
	card.card_type = type
	card.card_rarity = rarity
	card.card_energy_cost = energy
	card.card_description = description
	card.card_values = values
	card.card_upgrade_value_improvements.assign(upgrades) # 型つき辞書 (Dictionary[String, int])
	card.card_keyword_object_ids = ["keyword_mana"]
	return card


## エネルギー0、マナで払うカード。マナが足りないと使えない (光らない)
static func _mana_card(id: String, card_name: String, type: int, rarity: int, mana_cost: int, description: String, values: Dictionary, upgrades: Dictionary) -> CardData:
	var card: CardData = _card(id, card_name, type, rarity, 0, "Costs [mana_cost] Mana. " + description, values, upgrades)
	card.card_values["mana_cost"] = mana_cost
	card.card_values["mana_spend"] = -mana_cost # _spend_mana() が負の charges として付ける
	card.card_play_validators = [{Scripts.VALIDATOR_STATUS_CHARGES: {
		"status_effect_object_id": STATUS_MANA, "operator": ">=", "card_value_key": "mana_cost"}}]
	return card


## 対象を取らないカード (スキル・パワー) を登録する
static func _register_skill(card: CardData) -> void:
	card.card_requires_target = false
	Global.register_rod(card)


static func _attack(target_override: int = BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS) -> Dictionary:
	return {Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.15, "target_override": target_override, "actions_on_lethal": []}}


## 指定した山 (山札・手札・捨て札) からカードを 1 枚選んで action_data を行う。選べるカードが無ければ何もしない
static func _pick_one(pile: String, pick_text: String, action_data: Array[Dictionary], validators: Array[Dictionary] = []) -> Dictionary:
	return {Scripts.ACTION_PICK_CARDS: {"card_pick_type": pile, "min_card_amount": 1, "max_card_amount": 1,
		"min_cards_are_required_for_action": true, "card_pick_text": pick_text, "action_data": action_data, "validator_data": validators}}


static func _block() -> Dictionary:
	return {Scripts.ACTION_BLOCK: {"time_delay": 0.2, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}


static func _draw() -> Dictionary:
	return {Scripts.ACTION_DRAW_GENERATOR: {}}


static func _apply_to_player(status_id: String) -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": status_id, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}


## カードの mana_gain だけマナを得る
static func _gain_mana() -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": STATUS_MANA, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		"custom_key_names": {"status_charge_amount": "mana_gain"}}}


static func _gain_mana_fixed(amount: int) -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": STATUS_MANA, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		"status_charge_amount": amount}}


## カードの mana_cost だけマナを払う (負の charges を付けて減らす)
static func _spend_mana() -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": STATUS_MANA, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		"custom_key_names": {"status_charge_amount": "mana_spend"}}}

#endregion
