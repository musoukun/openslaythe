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
}
const TITLE_BACKGROUND := "res://sprites/ui/title_background.png"
const TITLE_HERO := "res://sprites/ui/hero_bust.png"
const NEW_RUN_HERO := "res://sprites/ui/hero_standing.png"
const NEW_RUN_HERO_NODE := "NewRunHero"
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
		var bust := _add_title_hero(title)
		_add_new_run_hero(title, bust)


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


## タイトル画面の右側に主人公のバストアップ (手描き) を置く。
## 絵は胸の下で切れているので、切れ目が常に画面の下端に来るよう右下に固定する
## (固定座標だと縦に広い画面で切れ目が画面の途中に浮き、胴体が消えて見える)。
static func _add_title_hero(title: Control) -> TextureRect:
	var tex := load_if_exists(TITLE_HERO)
	if tex == null:
		return null
	const SIZE := 580.0
	# 画像の下にある透明な余白の分だけ画面の外へ下げる
	var used := tex.get_image().get_used_rect()
	var bottom_padding := (tex.get_height() - used.end.y) * SIZE / tex.get_height()
	var hero := TextureRect.new()
	hero.texture = tex
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	hero.offset_left = -SIZE + 20.0
	hero.offset_right = 20.0
	hero.offset_top = -SIZE + bottom_padding
	hero.offset_bottom = bottom_padding
	title.add_child(hero)
	title.move_child(hero, 1)	# 背景のすぐ上、メニューの下
	return hero


## 新しいラン画面の中央 (左の説明パネルと右のボタン列のあいだ) に全身の立ち絵を置く。
## パネルを絵に重ねないよう、この画面ではタイトル用のバストアップを隠す。
static func _add_new_run_hero(title: Control, bust: TextureRect) -> void:
	var menu := title.get_node_or_null("NewRunMenu") as Control
	var tex := load_if_exists(NEW_RUN_HERO)
	if menu == null or tex == null:
		return
	var hero := TextureRect.new()
	hero.name = NEW_RUN_HERO_NODE	# NewRunMenu が選んだキャラの立ち絵に差し替える
	hero.texture = tex
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.anchor_left = 0.5
	hero.anchor_right = 0.5
	hero.anchor_bottom = 1.0
	hero.offset_left = -250.0
	hero.offset_right = 250.0
	hero.offset_top = 72.0	# 「新しいラン」の見出しの下から
	hero.offset_bottom = -4.0
	menu.add_child(hero)
	menu.move_child(hero, 0)	# パネルやボタンより奥
	if bust:
		menu.visibility_changed.connect(func() -> void: bust.visible = not menu.visible)


## キャラごとの全身の立ち絵。sprites/ui/hero_standing_<色>.png があればそれ、無ければ最初の主人公の絵
static func hero_standing_texture(character_data: CharacterData) -> Texture2D:
	var color := character_data.character_color_id.trim_prefix("color_")
	var tex := load_if_exists(NEW_RUN_HERO.replace(".png", "_%s.png" % color))
	return tex if tex else load_if_exists(NEW_RUN_HERO)


static func load_if_exists(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


## parent の最背面に全面画像を敷き、hide_nodes (単色背景など) を隠す
static func add_background(parent: Control, path: String, hide_nodes: Array = []) -> TextureRect:
	var tex := load_if_exists(path)
	if tex == null:
		return null
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
	return bg
