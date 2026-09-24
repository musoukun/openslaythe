extends Control

@onready var scroll_container = $ScrollContainer
@onready var location_container = $ScrollContainer/LocationContainer
@onready var back_button: Button = $BackButton

@onready var map_button = %MapButton

var can_travel: bool = false	# if clicking on a location brings you to the next location

## Adds a margin to the bottom of the map display
const MAP_Y_MARGIN: float = 150
## Codex 生成のマップ背景
const BACKGROUND_PATH := "res://sprites/ui/map_background.png"

func _ready():
	_setup_background()
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
	if not ResourceLoader.exists(BACKGROUND_PATH):
		return
	var bg := TextureRect.new()
	bg.texture = load(BACKGROUND_PATH)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	move_child(bg, 0)
	# 画像背景に置き換えるので元の単色背景は隠す
	for node_name in ["Background", "Background2"]:
		var node := get_node_or_null(node_name)
		if node:
			node.visible = false

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
