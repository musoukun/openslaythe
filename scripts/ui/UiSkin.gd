class_name UiSkin
## Codex 生成の UI 画像を既存シーンに当てる。画像が無ければ何もしない (元のプレースホルダのまま)。

## Root からの相対ノードパス -> 画像
const BUTTON_ICONS := {
	"RunScreen/Combat/PauseButton": "res://sprites/ui/icon_pause.png",
	"RunScreen/Combat/MapButton": "res://sprites/ui/icon_map.png",
	"RunScreen/Combat/DeckButton": "res://sprites/ui/icon_deck.png",
	"RunScreen/Combat/DrawPile": "res://sprites/ui/icon_draw_pile.png",
	"RunScreen/Combat/DiscardPile": "res://sprites/ui/icon_discard_pile.png",
	"RunScreen/Combat/ExhaustPile": "res://sprites/ui/icon_exhaust_pile.png",
	"RunScreen/Combat/Chest": "res://sprites/ui/chest.png",
	"RunScreen/Combat/Shop": "res://sprites/ui/shop.png",
}
const TITLE_BACKGROUND := "res://sprites/ui/title_background.png"
const TOP_BAR_COLOR := Color(0.03, 0.09, 0.09, 0.78)


static func apply(root: Node) -> void:
	for node_path in BUTTON_ICONS:
		var button := root.get_node_or_null(node_path) as TextureButton
		var tex := load_if_exists(BUTTON_ICONS[node_path])
		if button and tex:
			button.texture_normal = tex
	# 戦闘背景画像の上に上部バーを半透明で重ねて HUD を読みやすくする
	var top_bar := root.get_node_or_null("RunScreen/Combat/Background2") as ColorRect
	var bg_button := root.get_node_or_null("RunScreen/Combat/BackgroundButton")
	if top_bar and bg_button:
		top_bar.get_parent().move_child(top_bar, bg_button.get_index())
		top_bar.color = TOP_BAR_COLOR
		top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title := root.get_node_or_null("TitleScreen")
	if title:
		add_background(title, TITLE_BACKGROUND, ["Background"])


static func load_if_exists(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


## parent の最背面に全面画像を敷き、hide_nodes (単色背景など) を隠す
static func add_background(parent: Control, path: String, hide_nodes: Array = []) -> void:
	var tex := load_if_exists(path)
	if tex == null:
		return
	var bg := TextureRect.new()
	bg.texture = tex
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	parent.move_child(bg, 0)
	for node_name in hide_nodes:
		var node := parent.get_node_or_null(node_name) as CanvasItem
		if node:
			node.visible = false
