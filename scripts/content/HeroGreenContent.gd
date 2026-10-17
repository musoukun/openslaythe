class_name HeroGreenContent
## Vera (character_green) の報酬カードを 3 つの軸に絞る: 竜血の熱 / 筋力・多段 / わざと傷つく＋回復。
## トゲトゲ・燃えさし・オーバーシールドの軸のカードは報酬に出さない (カードの定義は残す)。
## 元のカードは GlobalProdDataGenerator.add_cards() で作られ、ここで報酬から外す・作り直す・足す。
## GlobalProdDataGenerator から add_cards() の後、BuildContent.register() の前に register_cards() が呼ばれる。

const COLOR := "green"
const HEAT := "status_effect_overheat" # 竜血の熱。10 を超えた分ごとに、自分も含む全員へ 10 ダメージ
const STRENGTH := "status_effect_damage_increase" # 筋力。1 回の攻撃ごとに上乗せ

## 報酬に出さなくなるカード (トゲトゲ・燃えさし・オーバーシールドの軸)
const CARDS_OUT_OF_POOL: Array[String] = [
	"card_thorns", "card_bud", # トゲトゲ
	"card_fusion_cannon", "card_containment", # 燃えさし
	"card_growth", "card_moss", "card_lotus", "card_symbiosis", "card_datum", # オーバーシールド・鱗
]


static func register_cards() -> void:
	for card_id: String in CARDS_OUT_OF_POOL:
		var card_data: CardData = Global.get_card_data(card_id)
		if card_data == null:
			DebugLogger.log_error("HeroGreenContent: No card with id \"%s\"" % card_id)
			continue
		card_data.card_appears_in_card_packs = false
	_rework_cards()
	_add_cards()


## 外した軸に頼っていたカードを、残す軸に合わせて作り直す
static func _rework_cards() -> void:
	# 竜心をくべる (初期デッキ): 燃えさしを捨て札に入れる代わりに HP を払う (わざと傷つく軸)。1 戦闘に 1 回ずつ (廃棄)
	var stoke: CardData = Global.get_card_data("card_particle_accelerator")
	stoke.card_description = "Gain [energy_amount] Energy. Lose [self_damage] HP. Exhaust."
	stoke.card_values = {"energy_amount": 3, "self_damage": 3, "time_delay": 0.0}
	stoke.card_play_destination = HandManager.EXHAUST_PILE
	stoke.card_play_actions = [_lose_hp(), {Scripts.ACTION_ADD_ENERGY: {"time_delay": 0.1, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]

	# 喰らう: オーバーシールドを得る代わりに、ブロックされなかったダメージ分 HP を回復する (回復の軸)
	var devour: CardData = Global.get_card_data("card_reap")
	devour.card_description = "Deal [damage] damage. Heal HP equal to the unblocked damage. Exhaust."
	devour.card_play_actions = [
		{Scripts.ACTION_ADD_HEALTH: {"custom_key_names": {"health_amount": "unblocked_damage_capped"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_ATTACK_GENERATOR: {"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS, "time_delay": 0.3}},
	]


static func _add_cards() -> void:
	# --- 竜血の熱: 熱から自分を守る・熱を足しながら殴る ---
	var heat_scales: CardData = _card("card_green_heat_scales", "Heatproof Scales", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Gain [block] block. Gain [status_charge_amount] Blood Heat.", {"block": 7, "status_charge_amount": 5}, {"block": 3}, "card_containment")
	heat_scales.card_play_actions = [_block(), _gain_heat()]
	_register_skill(heat_scales)

	var searing_claw: CardData = _card("card_green_searing_claw", "Searing Claw", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage. Gain [status_charge_amount] Blood Heat.", {"damage": 6, "number_of_attacks": 1, "status_charge_amount": 5}, {"damage": 3}, "card_moss")
	searing_claw.card_play_actions = [_attack(), _gain_heat()]
	Global.register_rod(searing_claw)

	# --- 筋力・多段: 筋力を上げ、1 回ずつ上乗せされる多段攻撃で伸ばす ---
	var frenzy: CardData = _card("card_green_frenzied_claws", "Frenzied Claws", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage [number_of_attacks] times.", {"damage": 3, "number_of_attacks": 4}, {"damage": 1}, "card_lotus")
	frenzy.card_play_actions = [_attack()]
	Global.register_rod(frenzy)

	var sharpen: CardData = _card("card_green_sharpen_claws", "Sharpen Claws", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Gain [status_charge_amount] Strength. Exhaust.", {"status_charge_amount": 2}, {"status_charge_amount": 1}, "card_growth")
	sharpen.card_play_destination = HandManager.EXHAUST_PILE
	sharpen.card_play_actions = [_gain_strength()]
	_register_skill(sharpen)

	var flurry: CardData = _card("card_green_claw_flurry", "Dragon Claw Flurry", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.UNCOMMON, 2,
		"Deal [damage] damage [number_of_attacks] times. Gain [status_charge_amount] Strength.", {"damage": 5, "number_of_attacks": 3, "status_charge_amount": 1}, {"damage": 2}, "card_datum")
	flurry.card_play_actions = [_attack(), _gain_strength()]
	Global.register_rod(flurry)

	# --- わざと傷つく＋回復: HP を払って得をし、回復で取り戻す ---
	var blood_pact: CardData = _card("card_green_blood_pact", "Blood Pact", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 0,
		"Lose [self_damage] HP. Draw [draw_count] cards.", {"self_damage": 3, "draw_count": 2}, {"draw_count": 1}, "card_bud")
	blood_pact.card_play_actions = [_lose_hp(), {Scripts.ACTION_DRAW_GENERATOR: {}}]
	_register_skill(blood_pact)

	var cauterize: CardData = _card("card_green_cauterize", "Cauterize", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 1,
		"Heal [health_amount] HP. Gain [status_charge_amount] Blood Heat. Exhaust.", {"health_amount": 6, "status_charge_amount": 5}, {"health_amount": 3}, "card_symbiosis")
	cauterize.card_play_destination = HandManager.EXHAUST_PILE
	cauterize.card_play_actions = [{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}}, _gain_heat()]
	_register_skill(cauterize)


## art_id: 絵を借りるカード (報酬から外したカードの絵を流用する)
static func _card(id: String, card_name: String, type: int, rarity: int, energy: int, description: String, values: Dictionary, upgrades: Dictionary, art_id: String) -> CardData:
	var card: CardData = CardData.new(id)
	card.card_name = card_name
	card.card_color_id = "color_" + COLOR
	card.card_texture_path = "external/sprites/cards/%s/%s.png" % [COLOR, art_id]
	card.card_type = type
	card.card_rarity = rarity
	card.card_energy_cost = energy
	card.card_description = description
	card.card_values = values
	card.card_upgrade_value_improvements.assign(upgrades) # 型つき辞書 (Dictionary[String, int])
	return card


static func _register_skill(card: CardData) -> void:
	card.card_requires_target = false
	Global.register_rod(card)


static func _attack() -> Dictionary:
	return {Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.15, "target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS}}


static func _block() -> Dictionary:
	return {Scripts.ACTION_BLOCK: {"time_delay": 0.2, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}


static func _gain_heat() -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": HEAT, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}


static func _gain_strength() -> Dictionary:
	return {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": STRENGTH, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.3}}


## カードの self_damage だけ HP を失う (ブロックでは防げない)
static func _lose_hp() -> Dictionary:
	return {Scripts.ACTION_DIRECT_DAMAGE: {"custom_key_names": {"damage": "self_damage"}, "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "bypass_block": true}}
