extends Control

@onready var scroll_container = $ScrollContainer
@onready var location_container = $ScrollContainer/LocationContainer
@onready var back_button: Button = $BackButton

@onready var map_button = %MapButton
@onready var card_selection_overlay = %CardSelectionOverlay

var can_travel: bool = false	# if clicking on a location brings you to the next location

## Adds a margin to the bottom of the map display
const MAP_Y_MARGIN: float = 150
## 現在地を画面の上から何割の高さに置くか
const CURRENT_SCROLL_RATIO: float = 0.7
## Codex 生成のマップ背景 (外側は暗く落とし、中央に羊皮紙を敷く)
const BACKGROUND_PATH := "res://sprites/ui/map_background.png"
const BACKGROUND_DIM := Color(0.28, 0.33, 0.33)
const PARCHMENT_PATH := "res://sprites/map/parchment_tile.png"
const BOSS_EMBLEM_PATH := "res://sprites/map/boss_emblem.png"
const BOSS_EMBLEM_TINT := Color(0.85, 0.78, 0.6, 0.9)
const ICON_PATH := "res://sprites/map/location_%s.png"
## 凡例: [アイコン名, 表示名]
const LEGEND_TEXT := Color(0.18, 0.2, 0.22)
const LEGEND := [["event", "Unknown"], ["shop", "Merchant"], ["treasure", "Treasure"], ["rest_site", "Rest"], ["combat", "Enemy"], ["miniboss", "Elite"]]
## マップ上のデッキボタン (戦闘画面の上部バーにある DeckButton と同じ位置・絵)
const DECK_ICON_PATH := "res://sprites/ui/icon_deck.png"
const DECK_BUTTON_RECT := Rect2(128, 8, 50, 50)

## デッキ一覧を見ている間はマップを隠し、閉じたらマップに戻す
var _reopen_after_deck: bool = false

func _ready():
	_setup_background()
	_setup_legend()
	_setup_deck_button()
	card_selection_overlay.visibility_changed.connect(_on_card_selection_overlay_visibility_changed)
	map_button.button_up.connect(_on_map_button_up)
	back_button.button_up.connect(_on_back_button_up)
	
	Signals.combat_started.connect(_on_combat_started)
	Signals.combat_ended.connect(_on_combat_ended)
	
	Signals.player_killed.connect(_on_player_killed)
	Signals.dialogue_ended.connect(_on_dialogue_ended)
	
	Signals.chest_opened.connect(_on_chest_opened)
	Signals.shop_opened.connect(_on_shop_opened)
	
	Signals.map_location_selected.connect(_on_map_location_selected)
	
func populate_locations(locations: Array[LocationData] = Global.get_all_act_locations()):
	clear_locations()
	
	var next_locations: Array[LocationData] = Global.get_next_locations()
	var player_location: LocationData = Global.get_player_location_data()
	var max_y: float = 0.0 # the highest location position, used to determine container size

	var current_map_location: MapLocation = null

	var parchment := _add_parchment()
	var map_paths := MapPaths.new()
	location_container.add_child(map_paths)
	var id_to_map_location: Dictionary = {}

	for location_data in locations:
		var map_location: MapLocation = Scenes.MAP_LOCATION.instantiate()
		location_container.add_child(map_location)
		map_location.init(location_data)
		id_to_map_location[location_data.location_id] = map_location

		map_location.map_location_button_up.connect(_on_map_location_button_up)
		
		max_y = max(max_y, location_data.location_position.y)
		
		# 現在地は常に印を付け、移動できるときは行き先を光らせる
		if location_data == player_location:
			map_location.mark_current()
			current_map_location = map_location
		elif can_travel and next_locations.has(location_data):
			map_location.mark_reachable()

	map_paths.set_segments(_build_path_segments(id_to_map_location))

	# set the size of the container to make scrolling posible
	location_container.custom_minimum_size.y = max_y + MAP_Y_MARGIN
	location_container.size.y = max_y + MAP_Y_MARGIN
	if parchment:
		parchment.size = Vector2(scroll_container.size.x, max_y + MAP_Y_MARGIN)
	
	# wait a frame to ensure container is properly resized
	await Global.get_tree().process_frame
	# 現在地が画面の下寄りに来るようにスクロールする (上に行き先が見える)
	if current_map_location != null:
		scroll_container.scroll_vertical = int(current_map_location.get_center().y - scroll_container.size.y * CURRENT_SCROLL_RATIO)
	else:
		scroll_container.scroll_vertical = int(max_y)


## ロケーション間の接続を [from, to, visited] の配列にする
func _build_path_segments(id_to_map_location: Dictionary) -> Array:
	var segments: Array = []
	for map_location: MapLocation in id_to_map_location.values():
		var data := map_location.location_data
		for next_id in data.location_next_location_ids:
			var next_location: MapLocation = id_to_map_location.get(next_id)
			if next_location == null:
				continue
			var visited := data.location_visited and next_location.location_data.location_visited
			segments.append([map_location.get_center(), next_location.get_center(), visited])
	return segments

func _setup_background() -> void:
	# 画像背景に置き換えるので元の単色背景は隠す
	var bg := UiSkin.add_background(self, BACKGROUND_PATH, ["Background", "Background2"])
	if bg:
		bg.modulate = BACKGROUND_DIM

## 羊皮紙 (縦にタイル) とボスのエンブレムをマップの一番奥に敷く
func _add_parchment() -> TextureRect:
	var tex := UiSkin.load_if_exists(PARCHMENT_PATH)
	if tex == null:
		return null
	var parchment := TextureRect.new()
	parchment.texture = tex
	parchment.stretch_mode = TextureRect.STRETCH_TILE
	parchment.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	parchment.mouse_filter = Control.MOUSE_FILTER_IGNORE
	location_container.add_child(parchment)
	var emblem_tex := UiSkin.load_if_exists(BOSS_EMBLEM_PATH)
	if emblem_tex:
		var emblem := TextureRect.new()
		emblem.texture = emblem_tex
		emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		emblem.modulate = BOSS_EMBLEM_TINT
		emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		emblem.position = Vector2(scroll_container.size.x / 2.0 - 110.0, 0.0)
		emblem.size = Vector2(220, 220)
		location_container.add_child(emblem)
	return parchment

## 右側の凡例 (StS2 風)
func _setup_legend() -> void:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.72, 0.8, 0.84, 0.95)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	panel.add_theme_stylebox_override("panel", style)
	# 羊皮紙と同じく画面中央を基準に置く (横長の画面でも地図の右隣に付いてくる)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = 452.0
	panel.offset_right = 452.0
	panel.offset_top = -240.0
	panel.offset_bottom = -240.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = "Legend"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_set_legend_text_style(title)
	box.add_child(title)
	for entry in LEGEND:
		var row := HBoxContainer.new()
		var icon := TextureRect.new()
		icon.texture = UiSkin.load_if_exists(ICON_PATH % entry[0])
		icon.custom_minimum_size = Vector2(26, 26)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var label := Label.new()
		label.text = entry[1]
		label.add_theme_font_size_override("font_size", 16)
		_set_legend_text_style(label)
		row.add_child(label)
		box.add_child(row)
	add_child(panel)

## マップを見ながらでもデッキを確認できるボタン。
## マップは上部バーより手前 (z 100) に描かれて HUD のデッキボタンを覆うので、マップ側にも同じボタンを置く
func _setup_deck_button() -> void:
	var button := TextureButton.new()
	button.name = "MapDeckButton"
	button.texture_normal = UiSkin.load_if_exists(DECK_ICON_PATH)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.position = DECK_BUTTON_RECT.position
	button.size = DECK_BUTTON_RECT.size
	button.tooltip_text = "Deck"
	UiSkin.add_backplate(button)
	button.button_up.connect(_on_deck_button_up)
	add_child(button)

func _on_deck_button_up() -> void:
	_reopen_after_deck = true
	hide_map()
	card_selection_overlay.view_deck()

func _on_card_selection_overlay_visibility_changed() -> void:
	if _reopen_after_deck and not card_selection_overlay.visible:
		_reopen_after_deck = false
		show_map()

## 凡例は明るい板に濃い文字なので、共通テーマの暗い縁取りと影を外す
func _set_legend_text_style(label: Label) -> void:
	label.add_theme_color_override("font_color", LEGEND_TEXT)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)

func clear_locations() -> void:
	for child in location_container.get_children():
		child.queue_free()

func show_map():
	populate_locations()
	visible = true

func hide_map():
	visible = false

func _on_map_button_up():
	show_map()

func _on_map_location_button_up(map_location: MapLocation):
	# map must be in travel mode
	if can_travel:
		# must be adjacent to player location
		if Global.get_next_locations().has(map_location.location_data):
			# visit the location (行けない部屋を押しても訪問済みにしない)
			map_location.location_data.location_visited = true
			ActionGenerator.generate_visition_location(map_location.location_data.location_id)
	
func _on_map_location_selected(location_data: LocationData):
	# disable travel mode
	can_travel = false
	hide_map()

func _on_combat_started(_event_id: String):
	can_travel = false

func _on_combat_ended():
	can_travel = true

func _on_player_killed(_player: Player) -> void:
	hide_map()
	clear_locations()

func _on_chest_opened():
	can_travel = true

func _on_shop_opened():
	can_travel = true

func _on_dialogue_ended():
	var player: Player = Global.get_player()
	if player.is_alive():
		can_travel = true
		show_map()
	else:
		hide_map()

func _on_back_button_up():
	hide_map()
	get_combined_minimum_size()
