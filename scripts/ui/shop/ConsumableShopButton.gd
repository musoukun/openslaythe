extends BaseShopButton

@onready var button: TextureButton = $Button

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)

	var consumable_object_id: String = _action_on_click.values.get("consumable_object_id", "")
	var consumable_data: ConsumableData = Global.get_consumable_data(consumable_object_id)
	if consumable_data != null:
		button.texture_normal = FileLoader.load_texture(consumable_data.consumable_texture_path)
		connect_icon_button(button, HandManager.tooltip.display_codex_consumable_tooltip.bind(consumable_data))
