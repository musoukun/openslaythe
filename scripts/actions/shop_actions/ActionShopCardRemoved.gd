## Finishes a shop card removal after the player picked the card: pays for it and uses up
## the shop's removal service. Runs as a child action of the card pick, so it only fires when a card
## was actually removed (backing out of the pick costs nothing).
## See: ActionShopPurchaseItems ("card_removal")
extends BaseAction

func perform_action():
	var shop_data: ShopData = Global.get_shop_at_player_location()
	if shop_data == null:
		return
	var money_amount: int = get_action_value("money_amount", 0)
	ActionHandler.add_actions(ActionGenerator.create_actions(Global.get_player(), null, [], [{Scripts.ACTION_ADD_MONEY: {"money_amount": -money_amount}}], null))
	shop_data.shop_card_removal_used = true
	Global.player_data.player_shop_card_removal_count += 1
	Signals.shop_card_removal_purchased.emit()
