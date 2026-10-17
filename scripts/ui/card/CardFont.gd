class_name CardFont
## カード専用のフォント (MSDF)
## カードは Node2D の scale でホバー拡大するが、普通のフォントは scale を考えずに小さいまま
## ラスタライズされるので、拡大すると文字がにじむ (Godot 4.6 の Control.scale の注記)。
## MSDF にすると、どの倍率でもくっきり描ける。プロジェクト共通のフォントを複製して使う。

const SOURCE_FONT_PATH := "res://fonts/MPLUSRounded1c-Bold.ttf"
## 縁取りの太さの2倍以上にする (カードの縁取りは最大 4px)
const MSDF_PIXEL_RANGE := 8

static var _theme: Theme = null


## カードの見た目の根本 (CardVisual) に付けるテーマ。子のラベルすべてに MSDF フォントが行き渡る
static func get_theme() -> Theme:
	if _theme == null:
		var font: FontFile = (load(SOURCE_FONT_PATH) as FontFile).duplicate()
		font.multichannel_signed_distance_field = true
		font.msdf_pixel_range = MSDF_PIXEL_RANGE
		_theme = Theme.new()
		_theme.default_font = font
	return _theme
