extends Node
## 開発用: 画面キャプチャ検証のため、起動引数で自動的にランを進める。
## 例: godot --path . --write-movie shots/x.png --fixed-fps 10 --quit-after 60 -- --auto=combat
## --auto=map    : ラン開始してマップを表示
## --auto=combat : ラン開始して最初の戦闘に入る
## 引数が無い場合は何もしない。

const CHARACTER_ID := "character_green"

func _ready() -> void:
	var mode := _get_mode()
	if mode == "":
		return
	await get_tree().create_timer(0.3).timeout
	Global.start_run(CHARACTER_ID, 12345)
	await get_tree().create_timer(0.5).timeout
	match mode:
		"map":
			var map := get_tree().root.find_child("Map", true, false)
			if map:
				map.show_map()
		"combat":
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break

func _get_mode() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--auto="):
			return arg.trim_prefix("--auto=")
	return ""
