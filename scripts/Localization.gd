class_name Localization
## 言語切り替え. 翻訳は localization/strings.csv (keys,en,ja) を Godot の TranslationServer で使う。
## 固定 UI 文字列は Control の自動翻訳、データ由来の文字列は表示箇所で tr() する。

const LANGUAGES := [
	["en", "English"],
	["ja", "日本語"],
]


static func apply_saved() -> void:
	TranslationServer.set_locale(Global.user_settings_data.settings_language)


static func set_language(locale: String) -> void:
	Global.user_settings_data.settings_language = locale
	TranslationServer.set_locale(locale)
	FileLoader.save_user_settings()
	# コードで設定したテキストを持つカードを描き直す
	Global.get_tree().call_group("cards", "update_card_display")


static func get_language_index() -> int:
	for i in LANGUAGES.size():
		if LANGUAGES[i][0] == TranslationServer.get_locale().left(2):
			return i
	return 0
