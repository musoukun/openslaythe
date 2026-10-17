# Validator for checking if the player has at least 1 upgradable card in their deck
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	for card: CardData in Global.player_data.player_deck:
		if card.can_upgrade():
			return true
	return false
