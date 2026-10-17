## 祝福の選択肢1つぶんの縦の柱 (LoL のルーン選択風)。
## 上から: 丸いリングのアイコン / 系統名 / 説明 / 小アイコン / 要約の一行。
## 選んでいない柱は灰色に沈み、カーソルを乗せた柱だけが系統色で光る
## (リングの発光・上から差し込む縦の光・柱ににじむ光。sprites/shaders/rune_*.gdshader)。
## DialogueOption を継ぐので、押したときの流れ・検証・自動操作 (PlaythroughBot / DevAutoPilot) は今までどおり。
extends DialogueOption
class_name BlessingColumn

const COLUMN_GLOW_SHADER := preload("res://sprites/shaders/rune_column_glow.gdshader")
const RING_SHADER := preload("res://sprites/shaders/rune_ring.gdshader")
const ICON_SHADER := preload("res://sprites/shaders/rune_icon.gdshader")

const RING_SIZE := 96.0
const RING_TOP := 20.0	# 柱の上端からリングまで
const SMALL_ICON_SIZE := 34.0
const GRAY := Color(0.5, 0.53, 0.6)
const COST_TINT := Color(1.0, 0.45, 0.4)
const FADE_TIME := 0.22
const SERIF_FONTS: PackedStringArray = ["Yu Mincho", "YuMincho", "Noto Serif JP", "Noto Serif CJK JP", "Hiragino Mincho ProN"]

## 系統: 名前・色・アイコン。祝福の中身 (アクション) から選ぶ
const ICON_DIR := "external/sprites/"
const PATHS := {
	"life": {"name": "Vitality", "color": Color(0.42, 0.88, 0.55), "icon": "consumables/consumable_heal.png"},
	"gold": {"name": "Fortune", "color": Color(1.0, 0.78, 0.32), "icon": "artifacts/artifact_add_money.png"},
	"relic": {"name": "Relic", "color": Color(0.72, 0.52, 1.0), "icon": "res://sprites/ui/chest.png"},
	"potion": {"name": "Elixir", "color": Color(0.35, 0.78, 1.0), "icon": "rest_actions/rest_action_add_random_consumable.png"},
	"upgrade": {"name": "Forge", "color": Color(1.0, 0.55, 0.28), "icon": "rest_actions/rest_action_upgrade_card.png"},
	"remove": {"name": "Purge", "color": Color(0.75, 0.88, 1.0), "icon": "rest_actions/rest_action_remove_cards.png"},
	"transform": {"name": "Change", "color": Color(1.0, 0.45, 0.82), "icon": "rest_actions/rest_action_enchant_cards.png"},
	"draft": {"name": "Insight", "color": Color(0.3, 0.92, 0.82), "icon": "artifacts/artifact_see_top_of_draw_pile.png"},
	"card": {"name": "Card", "color": Color(0.7, 0.7, 0.7), "icon": "cards/green/card_waste.png"},
	"swap": {"name": "Exchange", "color": Color(0.72, 0.52, 1.0), "icon": "res://sprites/ui/chest.png"},
	"equip": {"name": "", "color": Color(1.0, 0.36, 0.32), "icon": ""},	# 名前とアイコンは装備のレリックから
}

var _glow_material: ShaderMaterial
var _ring_material: ShaderMaterial
var _icon_materials: Array[ShaderMaterial] = []
var _icon: TextureRect
var _name_label: Label
var _summary_label: Label
var _small_icons: HBoxContainer
var _glow: ColorRect
var _color: Color = Color.WHITE
var _lit: float = 0.0
var _lit_tween: Tween
var _selected: bool = false


func _init() -> void:
	# DialogueOption は子の $RichTextLabel を使うので先に作っておく (_ready で説明の位置へ移す)
	var label := RichTextLabel.new()
	label.name = "RichTextLabel"
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	add_child(label)


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# 柱の光 (一番奥)
	_glow = ColorRect.new()
	_glow_material = _material(COLUMN_GLOW_SHADER)
	_glow_material.set_shader_parameter("ring_y", RING_TOP + RING_SIZE / 2.0)
	_glow.material = _glow_material
	add_child(_glow)
	move_child(_glow, 0)
	_glow.resized.connect(func(): _glow_material.set_shader_parameter("rect_size", _glow.size))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", int(RING_TOP))
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	# 丸いリングと中のアイコン
	var ring := ColorRect.new()
	ring.custom_minimum_size = Vector2(RING_SIZE, RING_SIZE)
	ring.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_ring_material = _material(RING_SHADER)
	ring.material = _ring_material
	box.add_child(ring)
	_icon = _make_icon(RING_SIZE * 0.66)
	_icon.position = Vector2.ONE * RING_SIZE * 0.17
	ring.add_child(_icon)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_override("font", _serif_font())
	_name_label.add_theme_font_size_override("font_size", 24)
	box.add_child(_name_label)

	# 説明 (選択肢の文)
	remove_child(rich_text_label)
	rich_text_label.add_theme_font_size_override("normal_font_size", 13)
	rich_text_label.add_theme_constant_override("line_separation", 2)
	box.add_child(rich_text_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	_small_icons = HBoxContainer.new()
	_small_icons.alignment = BoxContainer.ALIGNMENT_CENTER
	_small_icons.add_theme_constant_override("separation", 10)
	box.add_child(_small_icons)

	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.add_theme_font_size_override("font_size", 13)
	box.add_child(_summary_label)

	for child in find_children("*", "Control", true, false):
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(func(): _light(1.0 if option_enabled else 0.0))
	mouse_exited.connect(func(): _light(1.0 if _selected else 0.0))
	_apply_lit(0.0)


## 説明は中央に寄せる
func set_dialogue_bb_code(bb_code: String) -> void:
	rich_text_label.parse_bbcode("[center]%s[/center]" % bb_code)


## 祝福の中身 (アクション) から系統・アイコンを決めて柱に出す。summary は最下部の一行
func setup(actions: Array[Dictionary], summary: String) -> void:
	var parts: Array[Dictionary] = parts_of(actions)
	var main: Dictionary = parts[0] if not parts.is_empty() else {"path": "card", "cost": false}
	for part: Dictionary in parts:
		if not part.cost:
			main = part
			break
	var path: Dictionary = PATHS[main.path]
	_color = path.color
	_name_label.text = tr(main.get("name", path.name))
	_icon.texture = _load_icon(main.get("icon", path.icon))
	_glow_material.set_shader_parameter("glow_color", _color)
	_ring_material.set_shader_parameter("ring_color", _color)
	for part: Dictionary in parts:
		var small := _make_icon(SMALL_ICON_SIZE)
		small.custom_minimum_size = Vector2(SMALL_ICON_SIZE, SMALL_ICON_SIZE)
		small.texture = _load_icon(part.get("icon", PATHS[part.path].icon))
		if part.cost:
			(small.material as ShaderMaterial).set_shader_parameter("tint", COST_TINT)
		_small_icons.add_child(small)
	_summary_label.text = summary
	if not option_enabled:
		modulate = Color(1, 1, 1, 0.55)
	_apply_lit(_lit)


## 下から順にふわっと出てくる
func appear(delay: float) -> void:
	modulate.a = 0.0
	var target_alpha: float = 1.0 if option_enabled else 0.55
	create_tween().tween_property(self, "modulate:a", target_alpha, 0.35).set_delay(delay)


## 押された柱: 光ったままにして、一瞬強く光らせる
func select() -> void:
	_selected = true
	if _lit_tween:
		_lit_tween.kill()
	_lit_tween = create_tween()
	_lit_tween.tween_method(_apply_lit, _lit, 1.5, 0.12)
	_lit_tween.tween_method(_apply_lit, 1.5, 1.0, 0.5)


## 選ばれなかった柱: 暗く沈める
func dim() -> void:
	_light(0.0)
	create_tween().tween_property(self, "modulate:a", 0.25, 0.3)


func _light(target: float) -> void:
	if _lit_tween:
		_lit_tween.kill()
	_lit_tween = create_tween()
	_lit_tween.tween_method(_apply_lit, _lit, target, FADE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## lit 0: 灰色に沈む / 1: 系統色で光る (1 を超えると押した瞬間の強い光)
func _apply_lit(lit: float) -> void:
	_lit = lit
	var t: float = clamp(lit, 0.0, 1.0)
	_glow_material.set_shader_parameter("intensity", lit)
	_ring_material.set_shader_parameter("intensity", lit)
	for icon_material: ShaderMaterial in _icon_materials:
		icon_material.set_shader_parameter("saturation", t)
		icon_material.set_shader_parameter("brightness", lerp(0.45, 1.0, t) + max(lit - 1.0, 0.0))
	_name_label.add_theme_color_override("font_color", GRAY.lerp(_color.lightened(0.15), t))
	rich_text_label.modulate = Color(0.5, 0.52, 0.58).lerp(Color.WHITE, t)
	_summary_label.add_theme_color_override("font_color", Color(0.4, 0.42, 0.48).lerp(_color, t))


## 祝福のアクションを、小アイコン1つずつの「部品」に分ける。
## {path: PATHS のキー, cost: 代償か, (装備なら name / icon)}
static func parts_of(actions: Array[Dictionary]) -> Array[Dictionary]:
	var parts: Array[Dictionary] = []
	for action: Dictionary in actions:
		for script_path: String in action.keys():
			var values: Dictionary = action[script_path]
			var part: Dictionary = {}
			match script_path:
				Scripts.ACTION_ADD_HEALTH:
					part = {"path": "life", "cost": values.get("health_max_amount", values.get("health_amount", 0)) < 0}
				Scripts.ACTION_ADD_MONEY:
					part = {"path": "gold", "cost": values.get("money_amount", 0) < 0}
				Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL:
					part = {"path": "relic", "cost": false}
				Scripts.ACTION_ADD_CONSUMABLE:
					part = {"path": "potion", "cost": false}
				Scripts.ACTION_SWAP_BOSS_ARTIFACT:
					part = {"path": "swap", "cost": false}
				Scripts.ACTION_CREATE_CARDS:
					part = {"path": "card", "cost": true}	# 呪いのようなカードを足される
				Scripts.ACTION_ADD_ARTIFACT:
					var artifact: ArtifactData = Global.get_artifact_data(values.get("artifact_id", ""))
					part = {"path": "equip", "cost": false}
					if artifact:
						part.name = artifact.artifact_name
						part.icon = artifact.artifact_texture_path
				Scripts.ACTION_PICK_CARDS:
					part = {"path": _card_path(values), "cost": false}
			if not part.is_empty():
				parts.append(part)
	return parts


## カードを選ぶ祝福が、選んだカードをどうするか (強化・削除・変化・加える)
static func _card_path(values: Dictionary) -> String:
	var paths := {
		Scripts.ACTION_UPGRADE_CARDS: "upgrade",
		Scripts.ACTION_REMOVE_CARDS_FROM_DECK: "remove",
		Scripts.ACTION_TRANSFORM_CARDS: "transform",
		Scripts.ACTION_ADD_CARDS_TO_DECK: "draft",
	}
	for action: Dictionary in values.get("action_data", []):
		for script_path: String in action.keys():
			if paths.has(script_path):
				return paths[script_path]
	return "draft"


func _make_icon(icon_size: float) -> TextureRect:
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size = Vector2(icon_size, icon_size)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_material := _material(ICON_SHADER)
	icon.material = icon_material
	_icon_materials.append(icon_material)
	return icon


func _material(shader: Shader) -> ShaderMaterial:
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	return shader_material


## 系統名は明朝 (PC に無ければゲームの字体)
func _serif_font() -> Font:
	var font := SystemFont.new()
	font.font_names = SERIF_FONTS
	font.font_weight = 600
	font.fallbacks = [get_theme_default_font()]
	return font


## アイコンを読む: res:// はゲーム内の素材、external/ から始まるものはそのまま、ほかは external/sprites/ の下
func _load_icon(path: String) -> Texture2D:
	if path.begins_with("res://"):
		return load(path)
	return FileLoader.load_texture(path if path.begins_with("external/") else ICON_DIR + path)
