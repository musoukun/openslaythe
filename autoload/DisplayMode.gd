extends Node
## 全画面 / ウィンドウの切り替え。F11 か Alt+Enter で切り替え、選んだ方を設定に保存して次回の起動でも使う。
## 拡大のしかたは project.godot の display/window/stretch (canvas_items + expand) に任せる。

signal fullscreen_changed(fullscreen: bool)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 起動引数 (--fullscreen など) で project 設定と違うモードで始まったときはそちらを優先する
	if DisplayServer.window_get_mode() != ProjectSettings.get_setting("display/window/size/mode"):
		return
	# Global._ready() で設定を読んだ後に呼ばれる (autoload は上から順に _ready される)
	_apply(Global.user_settings_data.settings_fullscreen)


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_F11 or (key.alt_pressed and key.keycode in [KEY_ENTER, KEY_KP_ENTER]):
		set_fullscreen(not is_fullscreen())
		get_viewport().set_input_as_handled()


func is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func set_fullscreen(fullscreen: bool) -> void:
	_apply(fullscreen)
	Global.user_settings_data.settings_fullscreen = fullscreen
	FileLoader.save_user_settings()
	fullscreen_changed.emit(fullscreen)


func _apply(fullscreen: bool) -> void:
	if fullscreen == is_fullscreen():
		return
	# ゲーム向けの全画面は exclusive が推奨 (通常の FULLSCREEN は下端に1pxの隙間が出る)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
