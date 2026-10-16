# UI の読みやすさ

背景は情報量の多い手描きの絵なので、文字の後ろに何が来ても読めるようにする。
共通の見た目は `themes/ui_theme.tres`（`Root` に付ける）にまとめ、画面ごとに色や縁取りを足さない。

## 調べたこと

| 項目 | 目安 | 出典 |
|---|---|---|
| 文字と背景のコントラスト比 | 通常の文字 4.5:1 以上、大きい文字（PC で 1080p のとき 36px 以上）3:1 以上、押せない項目 3:1 以上 | Xbox Accessibility Guidelines 102 |
| 背景が一色でないとき | 一番コントラストが低い部分で測る（平均で測らない） | XAG 102 |
| 下敷きと縁取り | 文字の後ろに不透明か半透明の下敷きを敷くのが一番確実。できないところは、はっきりした縁取りと影で背景から離す | XAG 102、Game Accessibility Guidelines |
| 縁取りの色 | 文字と反対の明るさにする（明るい文字には暗い縁取り）。明るい背景でも暗い背景でも読める | Game Accessibility Guidelines |
| 文字の大きさ | PC で 1080p のとき、文字の高さ 18px 以上。このゲームの 1200×700 では約 12px にあたる | XAG 101 |
| 長い文章 | 和文は1行40字まで。文章は中央揃えにせず左揃えにする | XAG 101 |
| 色だけに頼らない | 赤と緑の組み合わせは色覚によって見分けにくい | XAG 102 |
| Godot の機能 | `outline_size` と `font_outline_color` は大半の Control で使える。影（`font_shadow_color`）は Label と RichTextLabel だけ。LabelSettings を付けたラベルはテーマより LabelSettings が優先される | Godot 4.6 ドキュメント「Using Fonts」 |

Slay the Spire 2 の UI について、文字の縁取りやパネルの作り方を説明した公式の資料は見つからなかった。そのため、ここに書いた決まりは上の一般的な指針から作っている。

## このゲームでの決まり

- 色は次の4つだけにする。
  - 文字はクリーム色 `#F7F0DB`
  - 強調とリンクは金色 `#FFDB8C`
  - 縁取りはほぼ黒の青緑 `#0A1212`
  - 下敷きは暗い青緑。不透明度は 88%
- 絵の上にじかに置く文字（Label / RichTextLabel / LinkButton / CheckBox）には、テーマで暗い縁取りを付ける。Label にはさらに影も付ける。
- 文章が2行以上続くところや、主人公の絵に重なるところには `BackPanel`（暗い半透明の角丸パネル）を敷く。
- ボタンは全部同じ形にする。ふだんは暗い青緑に緑の枠、マウスを乗せると明るい茶色に金の枠。
- 本文は 16px 以上にする。小さな数字（山札の枚数など）も 18px 以上にし、縁取りを付ける。
- 名前などの長い文字は、決まった幅からはみ出さないようにする（はみ出すと、中身に合わせて広がる親の箱が左右に広がり、画面の外で切れる）。

## 測った値（WCAG の計算式）

| 組み合わせ | 比 |
|---|---|
| クリーム色の文字を夕焼け空（`#FFD999`）にじかに置く | 1.18:1（読めない） |
| クリーム色の文字を溶岩色（`#FF8C33`）にじかに置く | 2.03:1（読めない） |
| 同じ文字を、不透明度 88% の下敷きの上に置く（下敷きの後ろが白、空、溶岩のどれでも） | 11.1〜13.1:1 |
| 金色の文字を、不透明度 88% の下敷きの上に置く | 9.5〜11.3:1 |
| クリーム色の文字と縁取り | 16.6:1 |

## カードとの関係

カードの文字は `Card(Control) → Pivot(Node2D) → 各ラベル` の下にある。Node2D のところでテーマが子に伝わらなくなるので、`Root` に付けた `ui_theme.tres` はカードの見た目を変えない。カードの大きさと枠の色は issue #3 で扱う。

## 出典

- [Xbox Accessibility Guideline 101: Text display](https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display.md)
- [Xbox Accessibility Guideline 102: Contrast](https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-102-contrast.md)
- [Game Accessibility Guidelines: If any subtitles / captions are used, present them in a clear, easy to read way](https://gameaccessibilityguidelines.com/if-any-subtitles-captions-are-used-present-them-in-a-clear-easy-to-read-way/)
- [Godot 4.6: Using Fonts (Font outlines and shadows)](https://docs.godotengine.org/en/4.6/tutorials/ui/gui_using_fonts.html)
