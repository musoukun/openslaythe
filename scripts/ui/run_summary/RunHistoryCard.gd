## Displays a card in the player's deck in the RunHistoryMenu
extends Control
class_name RunHistoryCard

@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichLabelAutoSizer = $RichTextLabel

const INVALID_CARD_TEXT: String = "Card Error"

func init(card_id: String, card_level: int, card_count: int) -> void:
	var card_data: CardData = Global.get_card_data(card_id)
	if card_data == null:
		rich_text_label.set_bbcode(tr(INVALID_CARD_TEXT))
		texture_rect.texture = FileLoader.MISSING_TEXTURE
		return # 削除したカードが過去のランの履歴に残っていても落ちないようにする

	var card_bbcode: String = ""
	if card_count > 1:
		card_bbcode += "x{0} ".format([card_count])
	
	card_bbcode += tr(card_data.card_name)
	if card_level > 0:
		card_bbcode += "+"
		if card_level > 1:
			card_bbcode += str(card_level)
		card_bbcode = "[color=green]{0}[/color]".format([card_bbcode])
	
	rich_text_label.set_bbcode(card_bbcode)
	
	texture_rect.texture = FileLoader.load_texture(card_data.card_texture_path)
