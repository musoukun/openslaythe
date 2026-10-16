# Validator for checking the player's charges of a status effect (e.g. enough Mana to pay a card)
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var player: Player = Global.get_player()
	if player == null:
		return false
	var status_effect_object_id: String = values.get("status_effect_object_id", "")
	var operator: String = values.get("operator", ">=")
	var comparison_value: int = _get_validator_value("comparison_value", values, _action, 1)
	# a card's own value (e.g. its Mana cost) can be named instead of a fixed number
	var card_value_key: String = values.get("card_value_key", "")
	if card_value_key != "" and _card_data != null:
		comparison_value = _card_data.card_values.get(card_value_key, comparison_value)
	return _compare(player.get_status_charges(status_effect_object_id), comparison_value, operator)
