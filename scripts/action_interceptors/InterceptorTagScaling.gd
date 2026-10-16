# Adds flat damage to attacks from cards by their tags (AD / AP style scaling axes)
# Bonus per tag is read from PlayerData.player_values["tag_damage_<tag>"], set by weapon artifacts
extends BaseActionInterceptor
class_name InterceptorTagScaling

const TAG_DAMAGE_VALUE_PREFIX: String = "tag_damage_"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var parent_action: BaseAction = action_interceptor_processor.parent_action
	if not parent_action.parent_combatant is Player:
		return ACTION_ACCEPTENCES.CONTINUE
	# only card attacks scale. enemy and artifact attacks have no card data
	var card_play_request: CardPlayRequest = parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE

	var bonus: int = 0
	for card_tag: String in card_play_request.card_data.card_tags:
		bonus += int(Global.player_data.player_values.get(TAG_DAMAGE_VALUE_PREFIX + card_tag, 0))
	if bonus == 0:
		return ACTION_ACCEPTENCES.CONTINUE

	var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
	action_interceptor_processor.set_shadowed_action_values("damage", damage + bonus)

	return ACTION_ACCEPTENCES.CONTINUE
