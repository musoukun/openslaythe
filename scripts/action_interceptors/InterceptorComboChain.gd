# 昇り竜の型 (ComboContent): 同じターンに、前に出したカード以上のコストのカードを出すとチェーンが続く。
# チェーンの n 枚目は、そのカードのダメージとブロックが +10%×(n-1) (端数は切り捨て)。上限は無い。
# コストが下がると 1 から数え直す。
# チェーンの状態は ArtifactComboChain がカードを出し始めたとき (card_play_started) に進め、
# そのカードが何枚目だったかをここに覚えておく (攻撃が後から遅れて解決されても、出した時点の倍率を使うため)。
extends BaseActionInterceptor
class_name InterceptorComboChain

const CHAIN_VALUE: String = "combo_chain" # PlayerData.player_values: 今のチェーンの長さ
const LAST_COST_VALUE: String = "combo_last_cost" # 直前に出したカードのコスト
const BONUS_PER_LINK: float = 0.1
const SCALED_VALUES: Array[String] = ["damage", "block"]

## 出したカード (CardPlayRequest の instance id) → 何枚目だったか。ターンの始めと終わりに消す
static var _request_links: Dictionary = {}


## このカードを今出したら、チェーンの何枚目になるか
static func get_next_link(card_data: CardData) -> int:
	var chain: int = int(Global.player_data.player_values.get(CHAIN_VALUE, 0))
	var last_cost: int = int(Global.player_data.player_values.get(LAST_COST_VALUE, -1))
	if chain > 0 and card_data.get_card_energy_cost(true, true) >= last_cost:
		return chain + 1
	return 1


## チェーンの link 枚目で、値 value に足す量 (端数は切り捨て)
static func get_bonus(value: int, link: int) -> int:
	return floori(value * BONUS_PER_LINK * (link - 1))


## カードを出し始めたときに呼ぶ。チェーンを進め、そのカードの枚目を覚える
static func advance(card_play_request: CardPlayRequest) -> int:
	var link: int = get_next_link(card_play_request.card_data)
	_request_links[card_play_request.get_instance_id()] = link
	Global.player_data.player_values[CHAIN_VALUE] = link
	Global.player_data.player_values[LAST_COST_VALUE] = card_play_request.card_data.get_card_energy_cost(true, true)
	return link


static func reset() -> void:
	_request_links.clear()
	Global.player_data.player_values[CHAIN_VALUE] = 0
	Global.player_data.player_values[LAST_COST_VALUE] = -1


func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var parent_action: BaseAction = action_interceptor_processor.parent_action
	if not parent_action.parent_combatant is Player:
		return ACTION_ACCEPTENCES.CONTINUE
	var card_play_request: CardPlayRequest = parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE

	# 出している最中のカードは出した時点の枚目、手札の説明 (プレビュー) は「今出したら何枚目か」
	var link: int = _request_links.get(card_play_request.get_instance_id(), get_next_link(card_play_request.card_data))
	if link <= 1:
		return ACTION_ACCEPTENCES.CONTINUE
	for value_name: String in SCALED_VALUES:
		var value: int = action_interceptor_processor.get_shadowed_action_values(value_name, 0)
		if value > 0:
			action_interceptor_processor.set_shadowed_action_values(value_name, value + get_bonus(value, link))

	return ACTION_ACCEPTENCES.CONTINUE
