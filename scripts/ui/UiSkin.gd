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
const TITLE_HERO := "res://sprites/ui/hero_bust.png"
const TOP_BAR_COLOR := Color(0.03, 0.09, 0.09, 0.78)
const BACKPLATE_COLOR := Color(0.05, 0.13, 0.14, 0.92)
const BACKPLATE_BORDER := Color(0.95, 0.85, 0.62, 0.9)
## 台座を敷く HUD ボタン (アイコン画像を差し替えるものは BUTTON_ICONS に書く)
const BACKPLATE_BUTTONS := [
	"RunScreen/Combat/PauseButton", "RunScreen/Combat/MapButton", "RunScreen/Combat/DeckButton",
	"RunScreen/Combat/DrawPile", "RunScreen/Combat/DiscardPile", "RunScreen/Combat/ExhaustPile",
]


static func apply(root: Node) -> void:
	for node_path in BUTTON_ICONS:
		var button := root.get_node_or_null(node_path) as TextureButton
		var tex := load_if_exists(BUTTON_ICONS[node_path])
		if button and tex:
			button.texture_normal = tex
	for node_path in BACKPLATE_BUTTONS:
		var control := root.get_node_or_null(node_path) as Control
		if control:
			add_backplate(control)
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
		_add_title_hero(title)


## アイコンの背後に暗い丸台座を敷いて背景から浮かせる (何度呼んでも1枚だけ)
static func add_backplate(control: Control, margin: float = 3.0) -> void:
	if control.has_node("Backplate"):
		return
	var style := StyleBoxFlat.new()
	style.bg_color = BACKPLATE_COLOR
	style.border_color = BACKPLATE_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(999)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 4
	var plate := Panel.new()
	plate.name = "Backplate"
	plate.show_behind_parent = true
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override("panel", style)
	plate.set_anchors_preset(Control.PRESET_FULL_RECT)
	plate.offset_left = -margin
	plate.offset_top = -margin
	plate.offset_right = margin
	plate.offset_bottom = margin
	control.add_child(plate)
	control.move_child(plate, 0)


## タイトル画面の右側に主人公のバストアップ (ドット絵) を置く
static func _add_title_hero(title: Control) -> void:
	var tex := load_if_exists(TITLE_HERO)
	if tex == null:
		return
	var hero := TextureRect.new()
	hero.texture = tex
	hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.position = Vector2(640, 120)
	hero.size = Vector2(580, 580)
	title.add_child(hero)
	title.move_child(hero, 1)	# 背景のすぐ上、メニューの下


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
