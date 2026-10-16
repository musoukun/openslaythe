extends BaseShopButton

@onready var button: TextureButton = $Button

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)

	var artifact_id: String = _action_on_click.values.get("artifact_id", "")
	var artifact_data: ArtifactData = Global.get_artifact_data(artifact_id)
	if artifact_data != null:
		button.texture_normal = FileLoader.load_texture(artifact_data.artifact_texture_path)
		connect_icon_button(button, HandManager.tooltip.display_codex_artifact_tooltip.bind(artifact_data))
