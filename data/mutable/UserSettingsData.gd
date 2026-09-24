## Maintains user settings.
## Loaded automatically via FileLoader.load_user_settings() and stored in Global.
## NOTE: None of these settings are actually hooked up to anything. Add more variables depending
## on the needs of your project
extends SerializableData
class_name UserSettingsData

## Language
## 初回は OS の言語 (日本語環境なら ja)
@export var settings_language: String = "ja" if OS.get_locale_language() == "ja" else "en"

## Resolution
@export var settings_window_size: Vector2 = Vector2(1200, 700)

## Volume
@export var settings_audio_master_volume: float = 1.0
@export var settings_audio_music_volume: float = 1.0
@export var settings_audio_effects_volume: float = 1.0

@export var settings_audio_mute_on_window_lose_focus: bool = false

func _get_native_properties() -> Dictionary:
	return {
		"settings_window_size": Vector2()
		}
