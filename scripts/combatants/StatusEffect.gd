# UI element for a status effect
extends TextureRect
class_name StatusEffect

var status_effect_script: BaseStatusEffect

@onready var status_charge_label: Label = $StatusChargeLabel
@onready var status_secondary_charge_label = $StatusSecondaryChargeLabel

func _ready() -> void:
	# カーソルを当てると、このキャラのステータスの説明を並べて出す (Tooltips.display_status_tooltips)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	HandManager.tooltip.display_status_tooltips(status_effect_script.parent_combatant, self)

func _on_mouse_exited() -> void:
	HandManager.tooltip.hide_tooltip()

func update_status_charge_display() -> void:
	visible = status_effect_script.status_effect_data.status_effect_is_visible
	
	var status_effect_data: StatusEffectData = status_effect_script.status_effect_data
	var status_effect_charge_upper_bound: int = status_effect_data.status_effect_charge_upper_bound
	
	if status_effect_script.status_charges == 1 and status_effect_charge_upper_bound > 1:
		status_charge_label.text = ""
	else:
		status_charge_label.text = str(status_effect_script.status_charges)
	
	if status_effect_script.status_secondary_charges == 0:
		status_secondary_charge_label.text = ""
	else:
		status_secondary_charge_label.text = str(status_effect_script.status_secondary_charges)
	
	
	# texture
	var status_effect_texture_path: String = status_effect_data.get_status_effect_texture_path(status_effect_script.status_charges)
	texture = FileLoader.load_texture(status_effect_texture_path)
