# Adds the Blade Twin status charges as extra hits of the Mana Blade card (cards tagged "mana_blade")
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var parent_action: BaseAction = action_interceptor_processor.parent_action
	var parent_combatant: BaseCombatant = parent_action.parent_combatant
	if parent_combatant == null or not parent_combatant.is_alive():
		return ACTION_ACCEPTENCES.CONTINUE
	var card_play_request: CardPlayRequest = parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE
	if not card_play_request.card_data.card_tags.has(HeroBlueContent.TAG_MANA_BLADE):
		return ACTION_ACCEPTENCES.CONTINUE

	var extra_hits: int = parent_combatant.get_status_charges(HeroBlueContent.STATUS_BLADE_TWIN)
	var number_of_attacks: int = action_interceptor_processor.get_shadowed_action_values("number_of_attacks", 1)
	action_interceptor_processor.set_shadowed_action_values("number_of_attacks", number_of_attacks + extra_hits)
	return ACTION_ACCEPTENCES.CONTINUE
