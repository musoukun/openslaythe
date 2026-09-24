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
	if mode == "settings":
		var settings_button := get_tree().root.find_child("SettingsButton", true, false) as BaseButton
		if settings_button:
			settings_button.pressed.emit()
			settings_button.button_up.emit()
		return
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
		"combat", "vfx", "profile":
			for location in Global.get_next_locations():
				if location.location_type == LocationData.LOCATION_TYPES.COMBAT:
					ActionGenerator.generate_visition_location(location.location_id)
					break
			if mode == "vfx":
				await get_tree().create_timer(1.0).timeout
				_preview_vfx()
			if mode == "profile":
				await get_tree().create_timer(1.0).timeout
				_profile()


## 性能計測: 何もしない時 / デッキ一覧を開いた直後 のフレーム時間
func _profile() -> void:
	for phase in ["idle", "mouse_sweep", "open_deck"]:
		var worst := 0.0
		var total := 0.0
		for i in 60:
			var t := Time.get_ticks_usec()
			if phase == "mouse_sweep":
				# 手札 (y=620) と敵 (y=380) の上を往復させる
				var pos := Vector2(200 + (i % 30) * 30, 620 if i < 30 else 380)
				var motion := InputEventMouseMotion.new()
				motion.position = pos
				motion.global_position = pos
				get_viewport().warp_mouse(pos)
				Input.parse_input_event(motion)
			if phase == "open_deck" and i == 0:
				var deck_button := get_tree().root.find_child("DeckButton", true, false) as BaseButton
				deck_button.button_up.emit()
			await get_tree().process_frame
			var ms := (Time.get_ticks_usec() - t) / 1000.0
			worst = max(worst, ms)
			total += ms
		print("PROFILE %s: avg %.1f ms, worst %.1f ms, cards %d" % [phase, total / 60.0, worst, get_tree().get_nodes_in_group("cards").size()])
	get_tree().quit()


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
