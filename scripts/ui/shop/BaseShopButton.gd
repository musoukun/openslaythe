# provides a general interface for a button like object in a shop
# given a PurchaseItemAction which it populates data from
extends Control
class_name BaseShopButton

@onready var price_label: Label = %PriceLabel

var action_on_click: BaseAction = null

const HOVER_SCALE: float = 1.15

func init(_action_on_click: BaseAction) -> void:
	action_on_click = _action_on_click

	var price: int = action_on_click.get_action_value("money_amount", 0)
	set_price(price)

func set_price(price: int) -> void:
	price_label.text = str(price)
	if price > Global.player_data.player_money:
		price_label.modulate = Color(1.0, 0.35, 0.3)

func _on_button_up():
	if action_on_click != null:
		ActionHandler.add_action(action_on_click)

## Icon buttons (relics, potions, card removal): grow on hover and show the item's tooltip
func connect_icon_button(button: BaseButton, show_tooltip: Callable) -> void:
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(func():
		create_tween().tween_property(button, "scale", Vector2.ONE * HOVER_SCALE, 0.1)
		show_tooltip.call())
	button.mouse_exited.connect(func():
		create_tween().tween_property(button, "scale", Vector2.ONE, 0.1)
		HandManager.tooltip.hide_tooltip())
	# the button is freed when the shop repopulates after a purchase; don't leave its tooltip behind
	tree_exiting.connect(HandManager.tooltip.hide_tooltip)
