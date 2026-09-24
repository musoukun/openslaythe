class_name CardFrames
## カードタイプ別のフレーム画像 (Codex 生成: sprites/ui/card_frame_<type>.png)

const FRAME_PATH := "res://sprites/ui/card_frame_%s.png"

static var _cache: Dictionary = {}


static func get_frame(card_type: int) -> Texture2D:
	var type_name: String = "status"
	match card_type:
		CardData.CARD_TYPES.ATTACK: type_name = "attack"
		CardData.CARD_TYPES.SKILL: type_name = "skill"
		CardData.CARD_TYPES.POWER: type_name = "power"
	if not _cache.has(type_name):
		var path := FRAME_PATH % type_name
		_cache[type_name] = load(path) if ResourceLoader.exists(path) else null
	return _cache[type_name]
