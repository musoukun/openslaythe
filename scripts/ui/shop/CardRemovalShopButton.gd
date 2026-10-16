## The shop's card removal service (a gold coin). Greyed out once used at this shop.
extends BaseShopButton

@onready var button: TextureButton = $Button

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)

	var shop_data: ShopData = Global.get_shop_at_player_location()
	var used: bool = shop_data != null and shop_data.shop_card_removal_used
	if used:
		button.disabled = true
		button.modulate = Color(0.45, 0.45, 0.45)
		price_label.text = tr("Sold Out")
	connect_icon_button(button, _show_tooltip.bind(used))

func _show_tooltip(used: bool) -> void:
	var text: String = tr("[color=orange]Card Removal[/color]\nRemove a card from your deck.")
	if used:
		text += "\n" + tr("[color=grey]Only once per shop.[/color]")
	HandManager.tooltip.display_tooltip(text, true)
