extends BaseShopButton

@onready var card: Card = $Card

## カードの下に値札の段を空ける高さ
const PRICE_ROW_HEIGHT: float = 32.0

func _ready():
	# カードは Card.CARD_SCALE で拡大されるので、枠もそれに合わせる
	custom_minimum_size = card.custom_minimum_size + Vector2(0, PRICE_ROW_HEIGHT)
	card.card_selected.connect(_on_card_selected)

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)
	
	var card_data: CardData = _action_on_click.values.get("card_data", null)
	if card_data != null:
		card.init(card_data, 0, false)

func _on_card_selected(_card: Card):
	_on_button_up()
