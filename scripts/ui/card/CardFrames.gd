class_name CardFrames
## カード色 x タイプ別のフレーム画像 (Codex 生成)
##   sprites/ui/card_frame_<color>_<type>.png  (例: card_frame_green_attack.png)
##   STATUS / CURSE は sprites/ui/card_frame_status.png

const FRAME_PATH := "res://sprites/ui/card_frame_%s.png"
const FALLBACK_COLOR := "white"

static var _cache: Dictionary = {}


static func get_frame(card_type: int, card_color_id: String) -> Texture2D:
	var type_name: String
	match card_type:
		CardData.CARD_TYPES.ATTACK: type_name = "attack"
		CardData.CARD_TYPES.SKILL: type_name = "skill"
		CardData.CARD_TYPES.POWER: type_name = "power"
		_: return _load("status")
	var color := card_color_id.trim_prefix("color_")
	var frame := _load("%s_%s" % [color, type_name])
	return frame if frame else _load("%s_%s" % [FALLBACK_COLOR, type_name])


static func _load(key: String) -> Texture2D:
	if not _cache.has(key):
		var path := FRAME_PATH % key
		_cache[key] = load(path) if ResourceLoader.exists(path) else null
	return _cache[key]
