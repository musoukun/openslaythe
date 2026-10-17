class_name HeroGreenContent
## Vera (character_green) の報酬カードを 3 つの軸に絞る: 竜血の熱 / 攻撃力上昇・多段 / わざと傷つく＋回復。
## トゲトゲ・燃えさし・オーバーシールドの軸のカードは報酬に出さない (カードの定義は残す)。
## 元のカードは GlobalProdDataGenerator.add_cards() で作られ、ここで報酬から外す・作り直す・足す。
## GlobalProdDataGenerator から add_cards() の後、BuildContent.register() の前に register_cards() が呼ばれる。

const COLOR := "green"
const HEAT := "status_effect_overheat" # 竜血の熱。10 を超えた分ごとに、自分も含む全員へ 10 ダメージ
const STRENGTH := "status_effect_damage_increase" # 攻撃力上昇。1 回の攻撃ごとに上乗せ

## 報酬に出さなくなるカード (トゲトゲ・燃えさし・オーバーシールドの軸)
const CARDS_OUT_OF_POOL: Array[String] = [
	"card_thorns", "card_bud", # トゲトゲ
	"card_fusion_cannon", "card_containment", # 燃えさし
	"card_growth", "card_moss", "card_lotus", "card_symbiosis", "card_datum", # オーバーシールド・鱗
]

## キーストーン (ラン開始時に選ぶ武器・型) で初期デッキに加わる専用カード。仕組みを見せるだけの弱さで、報酬には出ない。
## 足すのは BuildContent (武器) と ComboContent (昇り竜の型) の選択肢
const KEYSTONE_CARD_PHYSICAL := "card_green_twin_rake" # 研ぎ澄ました爪
const KEYSTONE_CARD_REACTOR := "card_green_ember_breath" # 竜炎の籠手
const KEYSTONE_CARD_COMBO := "card_green_rising_step" # 昇り竜の型
const KEYSTONE_CARD_COUNT := 2


static func register_cards() -> void:
	for card_id: String in CARDS_OUT_OF_POOL:
		var card_data: CardData = Global.get_card_data(card_id)
		if card_data == null:
			DebugLogger.log_error("HeroGreenContent: No card with id \"%s\"" % card_id)
			continue
		card_data.card_appears_in_card_packs = false
	_rework_cards()
	_add_cards()
	_add_keystone_cards()
	_rename_basics()
	_rework_starting_deck()


## キーストーンで選んだ専用カードを初期デッキに足すアクション (選択肢の柱では「もらえるカード」として出す)
static func keystone_card_actions(card_id: String) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	actions.assign(EventContent._add_card(card_id, KEYSTONE_CARD_COUNT, false))
	return actions


## 初期デッキは基本カード 8 枚だけ。残りの 2 枚はキーストーンで決まる (方向だけ渡し、完成品は渡さない)。
## 元の初期カード (逆鱗の爪・竜心をくべる・沸き立つ血 など) は報酬に出るので、引いたときの当たりになる。
## 設計の理由: reports/デッキ構築の法則とこのゲームへの取り入れ方.md の法則9
static func _rework_starting_deck() -> void:
	var vera: CharacterData = Global.get_character_data("character_green")
	vera.character_starting_card_object_ids.assign([
		"card_basic_attack_green", "card_basic_attack_green", "card_basic_attack_green", "card_basic_attack_green",
		"card_basic_block_green", "card_basic_block_green", "card_basic_block_green", "card_basic_block_green",
	])


## 基本カードを Vera の名前にする (Strike / Defend に寄せない。攻撃は爪、防御はブロック)
static func _rename_basics() -> void:
	Global.get_card_data("card_basic_attack_green").card_name = "Claw Swipe"
	Global.get_card_data("card_basic_block_green").card_name = "Block"


## キーストーンの専用カード。それぞれの軸の仕組みを 1 回見せるだけの数値にする (払い出しは報酬から)
static func _add_keystone_cards() -> void:
	# 研ぎ澄ました爪: 多段。武器の「1 ヒットごと +2」が 2 回乗るのを見せる
	var rake: CardData = _card(KEYSTONE_CARD_PHYSICAL, "Twin Rake", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.BASIC, 1,
		"Deal [damage] damage [number_of_attacks] times.", {"damage": 4, "number_of_attacks": 2}, {"damage": 2}, "card_thorns")
	rake.card_play_actions = [_attack()]
	_register_keystone_card(rake)

	# 竜炎の籠手: 一撃＋竜血の熱。籠手の「1 ヒットごと +5」と、熱が溜まる様子を見せる
	var breath: CardData = _card(KEYSTONE_CARD_REACTOR, "Ember Breath", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.BASIC, 1,
		"Deal [damage] damage. Gain [status_charge_amount] Blood Heat.", {"damage": 5, "number_of_attacks": 1, "status_charge_amount": 5}, {"damage": 3}, "card_fusion_cannon")
	breath.card_play_actions = [_attack(), _gain_heat()]
	_register_keystone_card(breath)

	# 昇り竜の型: 0 コストでチェーンの 1 枚目になる
	var step: CardData = _card(KEYSTONE_CARD_COMBO, "Rising Step", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.BASIC, 0,
		"Deal [damage] damage. Gain [block] block.", {"damage": 3, "number_of_attacks": 1, "block": 3}, {"damage": 2, "block": 2}, "card_blossom")
	step.card_play_actions = [_attack(), _block()]
	_register_keystone_card(step)


static func _register_keystone_card(card: CardData) -> void:
	card.card_appears_in_card_packs = false
	Global.register_rod(card)


## 外した軸に頼っていたカードを、残す軸に合わせて作り直す
static func _rework_cards() -> void:
	# 竜心をくべる (初期デッキ): 燃えさしを捨て札に入れる代わりに HP を払う (わざと傷つく軸)。1 戦闘に 1 回ずつ (廃棄)
	var stoke: CardData = Global.get_card_data("card_particle_accelerator")
	stoke.card_description = "Gain [energy_amount] Energy. Lose [self_damage] HP."
	stoke.card_values = {"energy_amount": 3, "self_damage": 3, "time_delay": 0.0}
	stoke.card_play_destination = HandManager.EXHAUST_PILE
	stoke.card_play_actions = [_lose_hp(), {Scripts.ACTION_ADD_ENERGY: {"time_delay": 0.1, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]

	# 喰らう: オーバーシールドを得る代わりに、ブロックされなかったダメージ分 HP を回復する (回復の軸)
	var devour: CardData = Global.get_card_data("card_reap")
	devour.card_description = "Deal [damage] damage. Heal HP equal to the unblocked damage."
	devour.card_play_destination = HandManager.EXHAUST_PILE # 説明どおり 1 戦闘に 1 回
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

	# --- 攻撃力上昇・多段: 攻撃力上昇を重ね、1 回ずつ上乗せされる多段攻撃で伸ばす ---
	var frenzy: CardData = _card("card_green_frenzied_claws", "Frenzied Claws", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.COMMON, 1,
		"Deal [damage] damage [number_of_attacks] times.", {"damage": 3, "number_of_attacks": 4}, {"damage": 1}, "card_lotus")
	frenzy.card_play_actions = [_attack()]
	Global.register_rod(frenzy)

	var sharpen: CardData = _card("card_green_sharpen_claws", "Sharpen Claws", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 1,
		"Gain [status_charge_amount] Attack Up.", {"status_charge_amount": 2}, {"status_charge_amount": 1}, "card_growth")
	sharpen.card_play_destination = HandManager.EXHAUST_PILE
	sharpen.card_play_actions = [_gain_strength()]
	_register_skill(sharpen)

	var flurry: CardData = _card("card_green_claw_flurry", "Dragon Claw Flurry", CardData.CARD_TYPES.ATTACK, CardData.CARD_RARITIES.UNCOMMON, 2,
		"Deal [damage] damage [number_of_attacks] times. Gain [status_charge_amount] Attack Up.", {"damage": 5, "number_of_attacks": 3, "status_charge_amount": 1}, {"damage": 2}, "card_datum")
	flurry.card_play_actions = [_attack(), _gain_strength()]
	Global.register_rod(flurry)

	# --- わざと傷つく＋回復: HP を払って得をし、回復で取り戻す ---
	var blood_pact: CardData = _card("card_green_blood_pact", "Blood Pact", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.COMMON, 0,
		"Lose [self_damage] HP. Draw [draw_count] cards.", {"self_damage": 3, "draw_count": 2}, {"draw_count": 1}, "card_bud")
	blood_pact.card_play_actions = [_lose_hp(), {Scripts.ACTION_DRAW_GENERATOR: {}}]
	_register_skill(blood_pact)

	var cauterize: CardData = _card("card_green_cauterize", "Cauterize", CardData.CARD_TYPES.SKILL, CardData.CARD_RARITIES.UNCOMMON, 1,
		"Heal [health_amount] HP. Gain [status_charge_amount] Blood Heat.", {"health_amount": 6, "status_charge_amount": 5}, {"health_amount": 3}, "card_symbiosis")
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
