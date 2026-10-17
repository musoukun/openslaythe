# Provides an overlay to pick and view cards
extends Control

@onready var card_container: GridContainer = $ScrollContainer/MarginContainer/CardContainer
@onready var card_picking_label: Label = $CardPickLabel
@onready var confirm_button: Button = $ConfirmButton
@onready var back_button: Button = $BackButton

var current_card_pick_action: ActionBasePickCards = null	# an action currently requesting cards from the player to select. If null clicking cards plays them

enum CARD_MODES {VIEW, SELECT}
var card_mode: int = CARD_MODES.VIEW	# determines to view or select the card when a card is clicked 

## アップグレードを選ぶときだけ出す「強化後を見る」トグル
var upgrade_toggle: CheckButton
## 表示中の Card が元々どのカードか (強化後の見本を表示していても選ぶのは元のカード)
const SOURCE_CARD_META := &"source_card_data"
const UPGRADE_SUMMARY_NAME := "UpgradeSummary"
const UPGRADE_SUMMARY_COLOR := Color(0.55, 1.0, 0.55)


func _ready():
	Signals.card_pick_requested.connect(_on_card_pick_requested)
	Signals.card_pick_confirmed.connect(_on_card_pick_confirmed)
	
	confirm_button.button_up.connect(_on_confirm_button_up)
	back_button.button_up.connect(_on_back_button_up)
	_setup_upgrade_toggle()
	
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)

func _on_card_pick_requested(card_pick_action: ActionBasePickCards):
	if card_pick_action != null:
		if HandManager.DECK_PICK_TYPES.has(card_pick_action.get_card_pick_type()):
			set_card_mode(CARD_MODES.SELECT)
			current_card_pick_action = card_pick_action
			populate_cards(card_pick_action.get_pickable_cards())
			
			card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.visible = current_card_pick_action.are_enough_cards_picked()
			
			back_button.visible = current_card_pick_action.get_card_pick_can_back_out()
			upgrade_toggle.visible = _is_upgrade_pick(current_card_pick_action)

func _on_card_pick_confirmed():
	visible = false
	current_card_pick_action = null

func populate_cards(cards: Array[CardData]) -> void:
	clear_cards()

	for card_data in cards:
		var card: Card = Scenes.CARD.instantiate()
		card_container.add_child(card)
		card.init(card_data, 0, false, true)
		card.set_meta(SOURCE_CARD_META, card_data)
		
		# bind signals
		card.card_hovered.connect(_on_card_hovered)
		card.card_unhovered.connect(_on_card_unhovered)
		card.card_selected.connect(_on_card_selected)

func clear_cards():
	for child in card_container.get_children():
		child.queue_free()

func _on_card_hovered(_card: Card):
	pass

func _on_card_unhovered(_card: Card):
	pass

func _on_card_selected(card: Card):
	if card_mode == CARD_MODES.SELECT:
		if current_card_pick_action != null:
			var card_data: CardData = card.get_meta(SOURCE_CARD_META, card.card_data)
			# unpick card
			if current_card_pick_action.picked_cards.has(card_data):
				current_card_pick_action.picked_cards.erase(card_data) # remove from picked cards
				card.set_card_glow(false)
			# pick card
			else:
				# card can be picked
				if current_card_pick_action.is_card_pickable(card_data):
					current_card_pick_action.picked_cards.append(card_data)	# add to picked cards
					card.set_card_glow(true)
					
			card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.visible = current_card_pick_action.are_enough_cards_picked()
			
			# quick pick automatically confirms
			if current_card_pick_action.is_quick_pick():
				_on_confirm_button_up()
			
	else:
		pass

func _on_confirm_button_up():
	visible = false
	Signals.card_pick_confirmed.emit()

func _on_back_button_up():
	visible = false
	if current_card_pick_action != null:
		current_card_pick_action.picked_cards = []
		Signals.card_pick_confirmed.emit()
	
### View mode wrappers

func set_card_mode(_card_mode: int) -> void:
	card_mode = _card_mode
	
	visible = true
	card_picking_label.visible = false
	back_button.visible = false
	confirm_button.visible = false
	upgrade_toggle.visible = false
	upgrade_toggle.set_pressed_no_signal(false)
	
	if card_mode == CARD_MODES.VIEW:
		back_button.visible = true
	if card_mode == CARD_MODES.SELECT:
		confirm_button.visible = true
		card_picking_label.visible = true
	

func _setup_upgrade_toggle() -> void:
	upgrade_toggle = CheckButton.new()
	upgrade_toggle.name = "UpgradeToggle"
	upgrade_toggle.text = "Show upgraded"
	upgrade_toggle.anchor_left = 0.5
	upgrade_toggle.anchor_right = 0.5
	upgrade_toggle.anchor_top = 0.5
	upgrade_toggle.anchor_bottom = 0.5
	upgrade_toggle.offset_left = 220.0
	upgrade_toggle.offset_right = 440.0
	upgrade_toggle.offset_top = -312.0
	upgrade_toggle.offset_bottom = -278.0
	upgrade_toggle.visible = false
	upgrade_toggle.toggled.connect(_on_upgrade_toggle_toggled)
	add_child(upgrade_toggle)

## カードを選んだあとにアップグレードする選択か (休憩所の鍛冶・イベント・祝福)
func _is_upgrade_pick(card_pick_action: ActionBasePickCards) -> bool:
	for action_data in card_pick_action.get_action_value("action_data", []):
		if action_data is Dictionary and action_data.has(Scripts.ACTION_UPGRADE_CARDS):
			return true
	return false

## 並んでいるカードを強化後の見本と元のカードで切り替える。カードの下に何が変わるかを出す
func _on_upgrade_toggle_toggled(show_upgraded: bool) -> void:
	for card in card_container.get_children():
		if not card is Card or card.is_queued_for_deletion():
			continue
		var source: CardData = card.get_meta(SOURCE_CARD_META, card.card_data)
		var summary: Label = card.card_visual.get_node_or_null(UPGRADE_SUMMARY_NAME)
		if summary:
			summary.queue_free()
		if show_upgraded and source.can_upgrade():
			card.card_data = source.get_upgraded_preview()
			_add_upgrade_summary(card, source.get_upgrade_summary())
		else:
			card.card_data = source
		card.update_card_display()

func _add_upgrade_summary(card: Card, text: String) -> void:
	var label := Label.new()
	label.name = UPGRADE_SUMMARY_NAME
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", UPGRADE_SUMMARY_COLOR)
	label.add_theme_font_size_override("font_size", 14)
	label.position = Vector2(0, card.card_visual.size.y - 4)
	label.size = Vector2(card.card_visual.size.x, 20)
	card.card_visual.add_child(label)

func view_deck() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(Global.player_data.player_deck)

func view_draw_pile() -> void:
	set_card_mode(CARD_MODES.VIEW)
	# randomize the draw pile so player's can't see next cards
	var randomized_draw: Array[CardData] = HandManager.player_draw.duplicate(false)
	randomized_draw.shuffle() #NOTE: this doesn't need to be deterministic
	populate_cards(randomized_draw)

func view_discard() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(HandManager.player_discard)

func view_exhaust() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(HandManager.player_exhaust)
	
func _on_run_started():
	visible = false
func _on_run_ended():
	visible = false
	current_card_pick_action = null
