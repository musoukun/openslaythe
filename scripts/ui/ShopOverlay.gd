# Overlay for a shop: the merchant's tent (ShopScene). Clicking the merchant opens the counter
# with the wares (ShopCounter). Both are built in code; see their scripts for the layout.
extends Control

@onready var map = $%Map

var scene: ShopScene
var counter: ShopCounter

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE	# keep the top bar (deck / map) clickable
	scene = ShopScene.new()
	add_child(scene)
	counter = ShopCounter.new()
	add_child(counter)
	scene.merchant_clicked.connect(open_counter)
	scene.next_pressed.connect(_on_continue_button_up)
	counter.back_pressed.connect(close_counter)

	Signals.combat_started.connect(_on_combat_started)

	Signals.map_location_selected.connect(_on_map_location_selected)
	Signals.shop_opened.connect(_on_shop_opened)

	Signals.player_killed.connect(_on_player_killed)

	Signals.card_purchased.connect(_on_card_purchased)
	Signals.artifact_purchased.connect(_on_artifact_purchased)
	Signals.consumable_purchased.connect(_on_consumable_purchased)
	Signals.shop_card_removal_purchased.connect(_repopulate_shop_after_actions_ended)

func open_counter() -> void:
	scene.hide_speech()
	counter.open()

func close_counter() -> void:
	counter.close()

## The wares on the counter (cards, then relics, potions and card removal)
func get_shop_items() -> Array[Control]:
	return counter.get_items()

func populate_shop() -> void:
	counter.clear_items()

	var shop_data: ShopData = Global.get_shop_at_player_location()
	if shop_data == null:
		shop_data = Global.generate_shop_at_player_location()

	if shop_data != null:
		shop_data.visit_shop()	# ensure the shop is populated

		### populate shop cards
		for card_data in shop_data.shop_cards:
			var card_price: int = shop_data.get_shop_card_price(card_data)
			counter.add_card(_make_button(Scenes.CARD_SHOP_BUTTON, {"card_data": card_data, "money_amount": card_price}))

		### populate shop artifacts
		for artifact_data in shop_data.get_shop_artifact_options():
			var artifact_id: String = artifact_data.object_id
			var artifact_price: int = shop_data.get_shop_artifact_price(artifact_id)
			counter.add_ware(_make_button(Scenes.ARTIFACT_SHOP_BUTTON, {"artifact_id": artifact_id, "money_amount": artifact_price}))
		counter.add_ware_gap(40)

		### populate shop consumables
		for consumable_slot_index in shop_data.shop_consumable_slot_to_consumable_object_id.keys():
			var consumable_object_id: String = shop_data.shop_consumable_slot_to_consumable_object_id[consumable_slot_index]
			var consumable_price: int = shop_data.get_shop_consumable_price(consumable_slot_index)
			counter.add_ware(_make_button(Scenes.CONSUMABLE_SHOP_BUTTON, {
				"consumable_object_id": consumable_object_id,
				"consumable_slot_index": consumable_slot_index,
				"money_amount": consumable_price,
				}))
		counter.add_ware_gap(0, true)

		### card removal service
		var removal_button: BaseShopButton = _make_button(Scenes.CARD_REMOVAL_SHOP_BUTTON, {"card_removal": true, "money_amount": shop_data.get_card_removal_price()})
		removal_button.name = "CardRemovalButton"
		counter.add_ware(removal_button)

## Creates a shop button whose click performs a purchase action with the given values
func _make_button(button_scene: PackedScene, purchase_values: Dictionary) -> BaseShopButton:
	var button: BaseShopButton = button_scene.instantiate()
	var purchase_action_data: Array[Dictionary] = [{Scripts.ACTION_SHOP_PURCHASE_ITEMS: purchase_values}]
	var purchase_action: BaseAction = ActionGenerator.create_actions(null, null, [], purchase_action_data, null)[0]
	# init needs the button's child nodes, which exist once it enters the tree
	button.ready.connect(button.init.bind(purchase_action), CONNECT_ONE_SHOT)
	return button

func clear_shop():
	counter.clear_items()

func _on_combat_started(_event_id: String):
	visible = false
	clear_shop()

func _on_shop_opened():
	visible = true
	counter.visible = false
	populate_shop()
	scene.enter()

func _on_card_purchased(_card_data: CardData):
	_repopulate_shop_after_actions_ended()

func _on_artifact_purchased(_artifact_data: ArtifactData):
	_repopulate_shop_after_actions_ended()

func _on_consumable_purchased(_consumable_object_id: String):
	_repopulate_shop_after_actions_ended()

func _repopulate_shop_after_actions_ended() -> void:
	if ActionHandler.actions_being_performed:
		await ActionHandler.actions_ended
	populate_shop()

func _on_continue_button_up():
	# increment the act and potentially generate a new one
	if Global.is_end_of_act():
		if not Global.is_end_of_run():
			# 次の幕の開始地点で祝福のキャラが出て、選び終わるとマップが開く (RunStartOptions)
			visible = false
			ActionGenerator.generate_next_act()
			return

	if not Global.is_end_of_run():
		map.show_map()
	else:
		visible = false
		Signals.run_victory.emit()

func _on_map_location_selected(_location_data: LocationData):
	visible = false

func _on_player_killed(_player: Player):
	clear_shop()
	visible = false
