class_name BlessingContent
## 幕の開始地点で祝福をくれるキャラ (StS の Neow / StS2 の Ancient にあたる役)。
## 敵や「?」イベントと同じく共通の世界の住人で、どの主人公にも同じキャラが出る (docs/character_design.md)。
## キャラごとに DialogueData を1つ作る (EventContent の組み方を流用):
##   開始状態 "greet" … 名前・あいさつ・絵と「小さな祝福」の候補 (代償なし)
##   状態 "gift"     … 祝福を渡すときの一言と「大きな祝福」の候補 (代償つき)
## 画面と演出は scripts/ui/RunStartOptions.gd と scripts/ui/BlessingGiver.gd。

const ART := "external/sprites/blessings/%s.png"
const GIVER_IDS: Array[String] = ["blessing_goddess", "blessing_merchant", "blessing_spirit"]
const SMALL_COUNT := 2	# 小さな祝福をいくつ出すか
const BIG_COUNT := 1	# 大きな祝福をいくつ出すか


static func register() -> void:
	_goddess()
	_merchant()
	_spirit()


## 今の幕で祝福をくれるキャラを返す。シードからキャラの並び順を決め、幕ごとに違うキャラが来る
static func get_giver_for_act(act: int) -> DialogueData:
	var order: Array = GIVER_IDS.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = Global.player_data.player_run_seed
	Random.shuffle_array(rng, order)
	return Global.get_dialogue_data("dialogue_" + order[(act - 1) % order.size()])


## キャラの候補から今回出す祝福を選ぶ (小さな祝福 SMALL_COUNT 個 + 大きな祝福 BIG_COUNT 個)
static func pick_blessings(giver: DialogueData, rng: RandomNumberGenerator) -> Array[DialogueOptionData]:
	var picked: Array[DialogueOptionData] = []
	picked.append_array(_pick_options(giver, get_greet_state(giver), SMALL_COUNT, rng))
	picked.append_array(_pick_options(giver, get_gift_state(giver), BIG_COUNT, rng))
	return picked


static func get_greet_state(giver: DialogueData) -> DialogueStateData:
	return giver.get_dialogue_state(giver.dialogue_initial_dialogue_state_object_id)


static func get_gift_state(giver: DialogueData) -> DialogueStateData:
	return giver.get_dialogue_state(giver.object_id + "_gift")


static func _pick_options(giver: DialogueData, state: DialogueStateData, count: int, rng: RandomNumberGenerator) -> Array[DialogueOptionData]:
	var ids: Array = state.dialogue_state_dialogue_option_object_ids.duplicate()
	Random.shuffle_array(rng, ids)
	var options: Array[DialogueOptionData] = []
	for option_id: String in ids.slice(0, count):
		options.append(giver.get_dialogue_option(option_id))
	return options


#region Givers

## 苔むした女神の石像: 命と守り
static func _goddess() -> void:
	EventContent._event("blessing_goddess", "Mossy Goddess", [
		_greet("The moss-covered statue opens its glowing eyes. \"Traveler. The forest remembers kindness. Choose a gift.\"", "blessing_goddess", [
			EventContent._option("[color=green]Gain 8 Max HP[/color].", [EventContent._max_hp(8)]),
			EventContent._option("[color=green]Upgrade a card[/color].", [_upgrade()], [{Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: {}}], "No upgradable cards"),
			EventContent._option("[color=green]Obtain a random potion[/color].", [EventContent._potion(1)]),
		]),
		_gift("\"Go gently. The forest walks with you.\"", [
			EventContent._option("[color=red]Take 10 damage[/color]. [color=green]Gain 20 Max HP[/color].", [EventContent._lose_hp(10), EventContent._max_hp(20)], [EventContent._need_hp(11)], "Not enough HP"),
			EventContent._option("[color=red]Lose 8 Max HP[/color]. [color=green]Obtain a random rare relic[/color].", [EventContent._max_hp(-8), EventContent._relic([ArtifactData.ARTIFACT_RARITIES.RARE])], [EventContent._need_hp(9)], "Not enough HP"),
		]),
	])


## 旅の商人ゴーレム: お金と道具
static func _merchant() -> void:
	EventContent._event("blessing_merchant", "Wandering Trader", [
		_greet("A little bronze golem sets down its enormous pack. \"FIRST CUSTOMER OF THE DAY! A FREE GIFT, NO RECEIPT.\"", "blessing_merchant", [
			EventContent._option("[color=green]Gain 100 Gold[/color].", [EventContent._gold(100)]),
			EventContent._option("[color=green]Obtain 2 random potions[/color].", [EventContent._potion(2)]),
			EventContent._option("[color=green]Obtain a random common relic[/color].", [EventContent._relic([ArtifactData.ARTIFACT_RARITIES.COMMON])]),
		]),
		_gift("\"PLEASURE DOING BUSINESS! TELL YOUR FRIENDS!\"", [
			EventContent._option("[color=red]Lose all your Gold[/color]. [color=green]Obtain a random rare relic[/color].", [EventContent._gold(-9999), EventContent._relic([ArtifactData.ARTIFACT_RARITIES.RARE])]),
			EventContent._option("[color=red]Lose 8 Max HP[/color]. [color=green]Gain 250 Gold[/color].", [EventContent._max_hp(-8), EventContent._gold(250)], [EventContent._need_hp(9)], "Not enough HP"),
		]),
	])


## 光る森の精霊 (角の鹿): デッキを整える
static func _spirit() -> void:
	var has_removable := [{Scripts.VALIDATOR_DECK_HAS_REMOVABLE_CARD: {}}]
	EventContent._event("blessing_spirit", "Antlered Spirit", [
		_greet("A stag of soft teal light steps out of the mist. Its antlers are living branches. It waits for you to choose.", "blessing_spirit", [
			EventContent._option("[color=green]Remove a card[/color].", [_remove(1)], has_removable, "No removable cards"),
			EventContent._option("[color=green]Transform a card[/color].", [_transform()], has_removable, "No cards"),
			EventContent._option("[color=green]Draft a card[/color].", [_draft([])]),
		]),
		_gift("The spirit bows its head. Its light lingers on you.", [
			EventContent._option("[color=red]Lose 8 Max HP[/color]. [color=green]Remove 2 cards[/color].", [EventContent._max_hp(-8), _remove(2)], [EventContent._need_hp(9)] + has_removable, "Not enough HP"),
			EventContent._option("[color=red]Add 1 Cinder to your deck[/color]. [color=green]Draft a rare card[/color].", [_draft([CardData.CARD_RARITIES.RARE]), EventContent._add_card(EventContent.WASTE_CARD_ID, 1)]),
		]),
	])

#endregion

#region Builders

## EventContent._state は絵を events/ から探すので、絵の場所だけ blessings/ に差し替える
static func _greet(prompt: String, art: String, options: Array) -> DialogueStateData:
	var state := EventContent._state("greet", prompt, art, options)
	state.dialogue_state_dialogue_texture_path = ART % art
	return state


static func _gift(line: String, options: Array) -> DialogueStateData:
	var state := EventContent._state("gift", line, "", options)
	state.dialogue_state_dialogue_texture_path = ""
	return state


static func _upgrade() -> Dictionary:
	return EventContent._pick_deck_card([{Scripts.ACTION_UPGRADE_CARDS: {}}], [{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}], "Choose a card to upgrade.")


static func _remove(count: int) -> Dictionary:
	return EventContent._pick_deck_card([{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}], [], "Choose {0} card(s) to remove. {1} cards selected", count)


static func _transform() -> Dictionary:
	var transform := {Scripts.ACTION_TRANSFORM_CARDS: {"transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE]}}
	return EventContent._pick_deck_card([transform], [], "Choose a card to transform.")


## プレイヤーのカードの中から3枚を見せて1枚選ぶ。rarities を空にするとレアリティを問わない
## (GlobalProdDataGenerator の run_start_option_draft_common_card と同じ組み方)
static func _draft(rarities: Array) -> Dictionary:
	var validators: Array[Dictionary] = [{Scripts.VALIDATOR_CARD_DRAFTABLE: {}}]
	if not rarities.is_empty():
		validators.append({Scripts.VALIDATOR_CARD_RARITY: {"card_rarities": rarities}})
	return {Scripts.ACTION_PICK_CARDS: {
		"card_pick_type": ActionBasePickCards.PICK_DRAFT,
		"pick_draft_cards": false,
		"draft_from_card_pool": true,
		"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
		"validator_data": validators,
		"rng_name": "rng_card_drafting",
		"draft_use_player_draft": false,
		"draft_is_weighted": false,
		"draft_use_pity_system": false,
	}}

#endregion
