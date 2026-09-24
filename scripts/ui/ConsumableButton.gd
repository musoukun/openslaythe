# represents a consumable slot
# can be empty
extends TextureButton
class_name ConsumableButton

var consumable_slot_index: int = 0	# which consumable slot this button corresponds to

signal consumable_slot_button_up(slot_index: int)

func _ready():
	UiSkin.add_backplate(self)
	button_up.connect(_on_button_up)

func init(_consumable_slot_index: int):
	consumable_slot_index = _consumable_slot_index
	
	var consumable_data: ConsumableData = Global.get_player_consumable_in_slot_index(consumable_slot_index)
	if consumable_data != null:
		# set tooltip
		tooltip_text = tr(consumable_data.consumable_name)
		if tr(consumable_data.consumable_description) != "":
			tooltip_text += "\n" + tr(consumable_data.consumable_description)
		# texture
		texture_normal = FileLoader.load_texture(consumable_data.consumable_texture_path)
		self_modulate.a = 1.0
	else:
		# empty consumable slot (台座だけ表示)
		texture_normal = null
		tooltip_text = ""
	


func _on_button_up():
	consumable_slot_button_up.emit(consumable_slot_index)
