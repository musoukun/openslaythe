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
	if mode == "dump_strings":
		StringDumper.dump()
		get_tree().quit()
		return
	await get_tree().create_timer(0.3).timeout
	Global.start_run(CHARACTER_ID, 12345)
	await get_tree().create_timer(0.5).timeout
	match mode:
		"map":
			var map := get_tree().root.find_child("Map", true, false)
			if map:
				map.show_map()
		"deck":
			var deck_button := get_tree().root.find_child("DeckButton", true, false) as BaseButton
			if deck_button:
				deck_button.button_up.emit()
		"combat", "vfx":
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break
			if mode == "vfx":
				await get_tree().create_timer(1.0).timeout
				_preview_vfx()


## 全トリガーを順番に再生する (VFX 確認用)
func _preview_vfx() -> void:
	var enemy := get_tree().get_first_node_in_group("enemies")
	var player := get_tree().get_first_node_in_group("players")
	for trigger in Vfx.triggers.keys():
		var on_player: bool = trigger in ["enemy_attack", "block_gain", "heal", "status_buff", "overheat", "energy_gain", "card_play_power"]
		print("VFX trigger: ", trigger)
		Vfx.play_trigger(trigger, player if on_player else enemy, 12)
		await get_tree().create_timer(0.8, true, false, true).timeout

func _get_mode() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--auto="):
			return arg.trim_prefix("--auto=")
	return ""
