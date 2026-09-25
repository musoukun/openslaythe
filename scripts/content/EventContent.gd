class_name EventContent
## 「?」マスの非戦闘イベント (設計: docs/events.md)。
## StS2 のイベント調査から抽象化した「型」ごとに、このゲーム独自のイベントを定義する。
## GlobalProdDataGenerator.add_events() から register() が呼ばれ、act 1〜3 の dialogue プールに入る。

const ART := "external/sprites/events/%s.png"
const WASTE_CARD_ID := "card_waste"
const PROMPT_COLOR := "[color=#F3E8CF]%s[/color]"


## すべてのイベントを登録し、プールに入れる EventData の配列を返す
static func register() -> Array[EventData]:
	var events: Array[EventData] = []
	events.append(_leaking_sprinkler())
	events.append(_radioactive_bloom())
	events.append(_vending_machine())
	events.append(_compost_jackpot())
	events.append(_scarecrow_bot())
	events.append(_greenhouse_spa())
	events.append(_pruning_barber())
	events.append(_mutation_pod())
	events.append(_fortune_sprout())
	events.append(_root_graft())
	return events


#region Events

## 型1: HPで永続の力を買う
static func _leaking_sprinkler() -> EventData:
	return _event("event_sprinkler", "Leaking Sprinkler", [
		_state("start", "A cracked reactor sprinkler hisses warm, glowing mist. The puddle below is sprouting.", "event_sprinkler", [
			_option("[color=red]Lose 10 HP[/color]. [color=green]Obtain a random relic[/color].", [_lose_hp(10), _relic()], [_need_hp(11)], "Not enough HP"),
			_option("[color=green]Obtain a random potion[/color].", [_potion(1)]),
		]),
	])


## 型2: 呪い (放射性廃棄物) を背負って大金
static func _radioactive_bloom() -> EventData:
	return _event("event_bloom", "Radioactive Bloom", [
		_state("start", "A gorgeous flower blooms from a leaking waste barrel. Its roots are tangled in coins.", "event_bloom", [
			_option("Pick it. [color=green]Gain 250 Gold[/color]. [color=red]Add 2 Radioactive Waste to your deck[/color].", [_gold(250), _add_card(WASTE_CARD_ID, 2)]),
			_option("Admire it. [color=green]Heal 10 HP[/color].", [_heal(10)]),
		]),
	])


## 型3: お金の段階的な使い道
static func _vending_machine() -> EventData:
	return _event("event_vending", "Seed Vault Vending Machine", [
		_state("start", "\"WELCOME, VALUED GARDENER.\" The machine rattles hopefully.", "event_vending", [
			_option("[color=red]Pay 40 Gold[/color]. [color=green]Obtain 2 random potions[/color].", [_gold(-40), _potion(2)], [_need_gold(40)], "Not enough Gold"),
			_option("[color=red]Pay 120 Gold[/color]. [color=green]Obtain a random relic[/color].", [_gold(-120), _relic()], [_need_gold(120)], "Not enough Gold"),
			_option("[color=red]Pay 220 Gold[/color]. [color=green]Obtain a random rare relic[/color].", [_gold(-220), _relic([ArtifactData.ARTIFACT_RARITIES.RARE])], [_need_gold(220)], "Not enough Gold"),
			_leave(),
		]),
	])


## 型4: もう1回だけ (欲張るほどコストが上がる)
static func _compost_jackpot() -> EventData:
	return _event("event_compost", "Compost Jackpot", [
		_state("start", "A steaming compost heap glitters with coins. Something glows deep inside.", "event_compost", [
			_option("Dig. [color=red]Lose 4 HP[/color]. [color=green]Gain 30 Gold[/color].", [_lose_hp(4), _gold(30)], [_need_hp(5)], "Not enough HP", "dig_2"),
			_leave(),
		]),
		_state("dig_2", "The heap is warmer here. The glow is closer.", "event_compost", [
			_option("Dig deeper. [color=red]Lose 6 HP[/color]. [color=green]Gain 60 Gold[/color].", [_lose_hp(6), _gold(60)], [_need_hp(7)], "Not enough HP", "dig_3"),
			_leave(),
		]),
		_state("dig_3", "Your gloves are smoking. The glowing thing is right there.", "event_compost", [
			_option("Dig to the bottom. [color=red]Lose 8 HP[/color]. [color=green]Obtain a random relic[/color].", [_lose_hp(8), _relic()], [_need_hp(9)], "Not enough HP"),
			_leave(),
		]),
	])


## 型5: 自分から戦闘を選ぶ
static func _scarecrow_bot() -> EventData:
	return _event("event_scarecrow", "Scarecrow Training Bot", [
		_state("start", "A patched-up training bot raises its broom arms. \"SPAR? REWARDS INCLUDED.\"", "event_scarecrow", [
			_option("[color=orange]Fight[/color] for combat rewards.", [{Scripts.ACTION_START_COMBAT: {"event_object_id": "event_act_1_easy_combat_2"}}]),
			_leave(),
		]),
	])


## 型6: 回復か強化か (今 ⇔ 長期)
static func _greenhouse_spa() -> EventData:
	return _event("event_spa", "Greenhouse Spa", [
		_state("start", "A warm mint-green pool bubbles beside a little tool bench.", "event_spa", [
			_option("Soak. [color=green]Heal 30% of your Max HP[/color].", [{Scripts.ACTION_HEAL_PERCENT: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 0.3}}]),
			_option("Tend your gear. [color=green]Upgrade a card[/color].", [_pick_deck_card([{Scripts.ACTION_UPGRADE_CARDS: {}}], [{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}], "Choose a card to upgrade.")], [{Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: {}}], "No upgradable cards"),
			_option("Water yourself. [color=green]Gain 6 Max HP[/color].", [_max_hp(6)]),
		]),
	])


## 型7: デッキ圧縮に代償
static func _pruning_barber() -> EventData:
	var remove := [_pick_deck_card([{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}], [], "Choose {0} card(s) to remove. {1} cards selected")]
	var has_removable := [{Scripts.VALIDATOR_DECK_HAS_REMOVABLE_CARD: {}}]
	return _event("event_barber", "Pruning Barber", [
		_state("start", "A dapper pruning robot snaps its scissor hands. \"A little off the top?\"", "event_barber", [
			_option("[color=red]Pay 75 Gold[/color]. [color=green]Remove a card[/color].", [_gold(-75)] + remove, [_need_gold(75)] + has_removable, "Not enough Gold"),
			_option("Free trim. [color=green]Remove a card[/color]. [color=red]Add 1 Radioactive Waste[/color].", remove + [_add_card(WASTE_CARD_ID, 1)], has_removable, "No removable cards"),
			_leave(),
		]),
	])


## 型8: ランダム性を受け入れる (変化)
static func _mutation_pod() -> EventData:
	var transform := {Scripts.ACTION_TRANSFORM_CARDS: {"transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE]}}
	var has_removable := [{Scripts.VALIDATOR_DECK_HAS_REMOVABLE_CARD: {}}]
	return _event("event_pod", "Mutation Pod", [
		_state("start", "A seed swirls in bubbling cyan fluid. The pod door hisses open.", "event_pod", [
			_option("[color=green]Transform a card[/color].", [_pick_deck_card([transform], [], "Choose a card to transform.")], has_removable, "No cards"),
			_option("[color=red]Lose 5 HP[/color]. [color=green]Transform 2 cards[/color].", [_lose_hp(5), _pick_deck_card([transform], [], "Choose 2 cards to transform.", 2)], [_need_hp(6)] + has_removable, "Not enough HP"),
			_leave(),
		]),
	])


## 型9: ルーレット
static func _fortune_sprout() -> EventData:
	var spin := {Scripts.ACTION_RANDOM_SELECTION: {
		"rng_name": "rng_events",
		"weights": {"gold": 3, "relic": 2, "heal": 2, "hurt": 2, "waste": 1},
		"weighted_action_data": {
			"gold": [_gold(100)],
			"relic": [_relic()],
			"heal": [{Scripts.ACTION_HEAL_PERCENT: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 1.0}}],
			"hurt": [_lose_hp(10)],
			"waste": [_add_card(WASTE_CARD_ID, 1)],
		},
	}}
	return _event("event_fortune", "Fortune Sprout", [
		_state("start", "A sprout has grown through an old prize wheel. It wiggles at you invitingly.", "event_fortune", [
			_option("[color=orange]Spin[/color]: Gold, a relic, a full heal... or something worse.", [spin], [_need_hp(11)], "Not enough HP"),
			_leave(),
		]),
	])


## 型10: 最大HPを削って力
static func _root_graft() -> EventData:
	return _event("event_graft", "Root Graft", [
		_state("start", "Ancient roots cradle a glowing crystal. The grafting tools are already sterilized.", "event_graft", [
			_option("Graft. [color=red]Lose 8 Max HP[/color]. [color=green]Obtain a random rare relic[/color].", [_max_hp(-8), _relic([ArtifactData.ARTIFACT_RARITIES.RARE])], [_need_hp(9)], "Not enough HP"),
			_option("Decline. [color=green]Gain 30 Gold[/color].", [_gold(30)]),
		]),
	])

#endregion

#region Builders

## イベント (EventData + DialogueData) を作って登録する。states の最初が開始状態。
static func _event(event_id: String, title: String, states: Array) -> EventData:
	var dialogue := DialogueData.new("dialogue_" + event_id)
	dialogue.dialogue_name_bbcode = "[color=#FFD178]%s[/color]" % title
	Global.register_rod(dialogue)
	for i in states.size():
		var state: DialogueStateData = states[i]
		state.object_id = "%s_%s" % [dialogue.object_id, state.object_id]
		for option: DialogueOptionData in state.get_meta("options"):
			var next_state: String = option.dialogue_option_next_dialogue_state_id
			if next_state != "":
				option.dialogue_option_next_dialogue_state_id = "%s_%s" % [dialogue.object_id, next_state]
			option.object_id = "%s_option_%d_%d" % [dialogue.object_id, i, state.dialogue_state_dialogue_option_object_ids.size()]
			dialogue._assign_option(option)
			state.dialogue_state_dialogue_option_object_ids.append(option.object_id)
		dialogue._assign_state(state)
		if i == 0:
			dialogue._assign_initial_state(state)
	var event := EventData.new(event_id)
	event.event_dialogue_object_id = dialogue.object_id
	Global.register_rod(event)
	return event


static func _state(state_id: String, prompt: String, art: String, options: Array) -> DialogueStateData:
	var state := DialogueStateData.new(state_id)
	state.dialogue_state_prompt_bbcode = prompt
	state.dialogue_state_dialogue_texture_path = ART % art
	state.set_meta("options", options)
	return state


static func _option(text: String, actions: Array = [], validators: Array = [], locked_reason: String = "", next_state: String = "") -> DialogueOptionData:
	var option := DialogueOptionData.new("")
	option.dialogue_option_bbcode = text
	option.dialogue_option_actions.assign(_flatten(actions))
	option.dialogue_option_validators.assign(validators)
	if locked_reason != "":
		option.dialogue_option_failed_validator_bbcode = "[color=grey][Locked]: %s[/color]" % locked_reason
	option.dialogue_option_next_dialogue_state_id = next_state
	return option


## [action, [action, action], ...] -> [action, action, action]
static func _flatten(items: Array) -> Array:
	var out := []
	for item in items:
		if item is Array:
			out.append_array(item)
		else:
			out.append(item)
	return out


static func _leave() -> DialogueOptionData:
	return _option("[color=grey]Leave.[/color]")

#endregion

#region Action helpers

static func _gold(amount: int) -> Dictionary:
	return {Scripts.ACTION_ADD_MONEY: {"money_amount": amount}}

static func _lose_hp(amount: int) -> Dictionary:
	return {Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -amount}}

static func _heal(amount: int) -> Dictionary:
	return {Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": amount}}

static func _max_hp(amount: int) -> Dictionary:
	return {Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": max(amount, 0), "health_max_amount": amount}}

static func _relic(rarities: Array = ArtifactData.STANDARD_ARTIFACT_RARITIES) -> Dictionary:
	return {Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": rarities}}

static func _potion(count: int) -> Dictionary:
	return {Scripts.ACTION_ADD_CONSUMABLE: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "slot_count": count, "random_consumable": true}}

## カードを生成してデッキに加える。2つのアクションの組なので配列で返す (_option で平坦化される)。
## 並び順はフレームワークの例 (GlobalTestDataGenerator の Quest Card) に合わせている。
static func _add_card(card_id: String, count: int) -> Array:
	return [
		{Scripts.ACTION_ADD_CARDS_TO_DECK: {"custom_key_names": {"picked_cards": "generated_cards"}}},
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": card_id, "number_of_cards": count}},
	]

## デッキからカードを選んで actions を適用する
static func _pick_deck_card(actions: Array, card_validators: Array, pick_text: String, count: int = 1) -> Dictionary:
	return {Scripts.ACTION_PICK_CARDS: {
		"card_pick_type": HandManager.DECK,
		"min_card_amount": count,
		"max_card_amount": count,
		"min_cards_are_required_for_action": true,
		"random_selection": false,
		"card_pick_text": pick_text,
		"validator_data": card_validators,
		"action_data": actions,
	}}

static func _need_gold(amount: int) -> Dictionary:
	return {Scripts.VALIDATOR_MONEY: {"money_amount": amount}}

static func _need_hp(amount: int) -> Dictionary:
	return {Scripts.VALIDATOR_PLAYER_HEALTH: {"health_amount": amount}}

#endregion
