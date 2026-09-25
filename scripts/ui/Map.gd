extends Control

@onready var scroll_container = $ScrollContainer
@onready var location_container = $ScrollContainer/LocationContainer
@onready var back_button: Button = $BackButton

@onready var map_button = %MapButton

var can_travel: bool = false	# if clicking on a location brings you to the next location

## Adds a margin to the bottom of the map display
const MAP_Y_MARGIN: float = 150
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

func _ready():
	_setup_background()
	_setup_legend()
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
	var max_y: float = 0.0 # the highest location position, used to determine container size
	
	var current_map_location: MapLocation = null

	var parchment := _add_parchment()
	var map_paths := MapPaths.new()
	location_container.add_child(map_paths)
	var id_to_map_location: Dictionary = {}

	for location_data in locations:
		if location_data.location_type == LocationData.LOCATION_TYPES.STARTING:
			continue	# starting area not displayed

		var map_location: MapLocation = Scenes.MAP_LOCATION.instantiate()
		location_container.add_child(map_location)
		map_location.init(location_data)
		id_to_map_location[location_data.location_id] = map_location

		map_location.map_location_button_up.connect(_on_map_location_button_up)
		
		max_y = max(max_y, location_data.location_position.y)
		
		# flash the locations the player can travel to
		if can_travel:
			if next_locations.has(location_data):
				map_location.flash_location()
				current_map_location = map_location
		
		#if location_data == Global.get_player_location_data():
			#current_map_location = map_location
	
	map_paths.set_segments(_build_path_segments(id_to_map_location))

	# set the size of the container to make scrolling posible
	location_container.custom_minimum_size.y = max_y + MAP_Y_MARGIN
	location_container.size.y = max_y + MAP_Y_MARGIN
	if parchment:
		parchment.size = Vector2(scroll_container.size.x, max_y + MAP_Y_MARGIN)
	
	# wait a frame to ensure container is properly resized
	await Global.get_tree().process_frame
	# set the scroll
	if current_map_location != null:
		current_map_location.grab_focus()
	else:
		# presumably the invisible starting location, set to bottom
		scroll_container.scroll_vertical = max_y
	

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
	panel.position = Vector2(1052, 110)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = "Legend"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", LEGEND_TEXT)
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
		label.add_theme_color_override("font_color", LEGEND_TEXT)
		label.add_theme_font_size_override("font_size", 16)
		row.add_child(label)
		box.add_child(row)
	add_child(panel)

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
			# visit the location
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
