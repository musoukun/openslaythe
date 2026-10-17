# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Slay the Spire 風のデッキ構築ローグライク。Godot 4.6 (GDScript)。土台は [DesirePathGames/Slay-The-Robot](https://github.com/DesirePathGames/Slay-The-Robot)（MIT）。
コードとデータは Claude Code が書き、絵（キャラ・敵・カード絵・アイコン・背景）は Codex CLI の画像生成に任せる。
ユーザーへの返答・ドキュメント・コード内コメントは日本語。

## 作業を始める前に

**作業を始めるときは、必ず最新の main を今のブランチに取り込んでから手を付ける。** 古い main の上で作業すると、他のブランチで入った変更と衝突したり、直したはずの不具合を作り直したりする。

```powershell
git fetch origin
git merge origin/main      # 衝突したら解消してから作業に入る
```

**コミットと PR は気軽にしてよい。** 区切りのいいところで確認を取らずにコミットし、push して PR を作ってかまわない（main への直接 push とマージはしない）。

## よく使うコマンド（PowerShell）

`godot` は PATH にある（WinGet）。ビルドやリントの手順はない。テストはゲームを起動して自動操作する方式。

```powershell
godot --headless --path . --quit-after 60                 # 起動してスクリプトエラーだけ確認
.\tools\shot.ps1 combat                                   # 画面を自動で開いて撮影 (map / map_mid / combat / settings / new_run / 空=タイトル)。最後のPNGのパスを出す
.\tools\shot.ps1 combat -fullscreen                       # 全画面の実寸で撮る
godot --headless --path . -- --auto=playthrough --seed=101   # クリックだけで最終ボスまで通しプレイ (ボット)
godot --headless --path . -- --auto=mana_check --hero=character_blue
```

- `--auto=<mode>` の一覧と引数は `autoload/DevAutoPilot.gd` 冒頭のコメントが正本（shop / rest / death / blessing / click_test / weapon など、画面ごとの確認モードがある）。新しい画面を作ったら、ここに確認用モードを足すのが流儀。
- 通しプレイ (`scripts/dev/PlaythroughBot.gd`) は `PLAY ...` / `STUCK` / `BLOCKED` / `RESULT` と、計測用の `CSVCOMBAT` / `CSVRUN` を出す。`--god`（毎ターン全回復）`--draft=first|attack|random|none` `--combo` `--hero=` `--shots=<フォルダ>`。
- **ボットは 1 条件 5 ラン程度（シード 101〜105）まで。** 大量のランはユーザーが嫌う。勝率比較などで増やすなら先に聞く。
- 翻訳: `tools/i18n/ja.json`（英語 → 日本語）を編集して `python tools/i18n/build_csv.py` で `localization/strings.csv` を作る。ゲーム内文字列は英語で書き、日本語は ja.json に足す。

## アーキテクチャ

### データはコードで作る
- コンテンツ（カード・敵・状態異常・レリック・イベント・幕・キャラ）は JSON ではなく GDScript で登録する。入口は `autoload/GlobalProdDataGenerator.gd` の `generate_production_data()`（`Global.gd` から呼ばれる。`GlobalTestDataGenerator` は土台の見本で未使用）。
- 新しい仕組みは `scripts/content/*Content.gd` に `register()` を持つクラスとして切り出し、`generate_production_data()` から呼ぶ（BuildContent / ComboContent / BlessingContent / EventContent / HeroBlueContent）。1000行級の生成器にさらに足さない。
- データ型: `data/prototype/`（カード・敵などの原型）、`data/readonly/`（幕・色・キーワード等）、`data/mutable/`（ラン中に変わる状態・プロフィール・設定）。

### 効果は Action と Interceptor
- カードやレリックの効果は `scripts/actions/` の Action を `autoload/ActionGenerator.gd` で組み立て、`autoload/ActionHandler.gd` のキューで実行する。
- 数値の補正は `scripts/action_interceptors/` の Interceptor で Action を書き換える。**加算（筋力・武器・タグ補正, priority 10000）→ コンボ倍率 (9600) → 弱体/脆弱の乗算 (9500/9000)** の順。新しい補正もこの順序に合わせて priority を決める。
- 軸ごとの補正は「カードに `card_tags` を付け、Interceptor がタグを見て加算」する形（`BuildContent.gd` / `InterceptorTagScaling`）。主人公専用の効果もこの形で閉じ込める。
- 使える条件は `scripts/validators/`、状態異常は `scripts/status_effects/`、レリックは `scripts/artifacts/`。

### 絵の自動割り当て
- 画像は命名規約どおりの場所に置けば自動で差し替わる（`scripts/ArtOverrides.gd` 冒頭に一覧。例: `external/sprites/cards/<color>/<card_id>.png`, `external/sprites/enemies/<enemy_id>.png`）。UI 画像は `scripts/ui/UiSkin.gd`。
- 戦闘演出は `autoload/Vfx.gd` が `sprites/vfx/vfx.json` を読んで再生する。敵の表示名は `sprites/enemy_names.json`。

### 共通の世界と主人公専用の絵（StS2 と同じ分け方）
- 敵・「?」イベント・祝福のキャラ・汎用の状態異常/レリック/ポーション・HUD・VFX は**全主人公で共通**。竜の鱗・爪・炎など特定の主人公を連想させる要素や人物を描かない（`tools/codex_art/assets.json` / `event_assets.json` / `world_assets.json` の共通スタイル）。
- 主人公専用は、その色のカード絵・その主人公だけが付ける状態異常・エネルギー玉・専用レリック。主人公ごとの manifest（`hero_*_assets.json`）に入れる。詳細は `docs/character_design.md`「共通の世界と主人公専用の分け方」。
- 画面（休憩所・ショップ・死亡・祝福）は StS2 のように**描かれた場面**にする（背景＋主人公の絵＋アイコン中心の選択肢、効果はホバーのツールチップ）。文字やボタンだけが前面に並ぶ画面は不可。世界観は LoL 風のハイファンタジー（休憩所 =「本拠地へのリコール」）。

## ゲームデザイン

### 参考作品
- **Slay the Spire 2** — 画面構成・マップ・幕構成・共通の世界の分け方（調査: `docs/sts2_research.md`）
- **Dominion** — デッキ構築の参考
- **Vampire Crawlers**（poncle） — マナ順コンボ（→「昇り竜の型」）
- **League of Legends** — AD / AP のように「同じキャラでも何を太らせるかでビルドが分かれる」考え方、世界観の味付け

### ビルド
- **Vera Emberscale**（`character_green`, 半竜の戦士）
  - 物理（爪・尾, タグ `physical`）: 手数で伸びる。開始武器「Honed Claws」
  - 竜炎（タグ `reactor`）: 枚数は少ないが1発が大きい。開始武器「Dragonfire Gauntlet」
  - 昇り竜の型（`ComboContent.gd`, 試作）: 同じターンに前のカード以上のコストを出すとチェーン継続、n 枚目はダメージとブロック +10%×(n-1)（上限なし）
  - 竜血の熱（`status_effect_overheat`）: 10 を超えた分ごとに自分も含む全員へ 10 ダメージ
- **Luca Azurine**（`character_blue`, 青の魔法剣士, `HeroBlueContent.gd`）
  - マナ（ターンをまたいで繰り越す第2の資源、上限10）と専用カード「蒼刃」
  - ヘイスト（マナで呪文を連打）／蒼刃（マナを注いで刃を育てる）の2軸がマナを取り合う。未実装分は `docs/hero_blue_design.md`「実装メモ」

### StS2 との違い
- **開始時にもらうのはルーンで、レリックではない**（ユーザーの設計方針）。※現状のコードは、ラン開始の選択肢が開始武器レリック2択＋レリック交換＋昇り竜の型（`scripts/ui/RunStartOptions.gd`）で、幕の開始地点で祝福のキャラ（StS2 の Ancient にあたる, `BlessingContent.gd`）から祝福をもらう。ルーンへの置き換えはまだ。
- 差別化は「難易度を下げる」ことではなく、**1枚・1軸を育てて壊れる楽しさ（StS2 が抑えた方向）を主役にする**こと。ビルドの幅は「ラン開始時の1つの選択で、同じカードの価値が変わるか」で作る（`reports/ビルド多様性 デッキ構築設計.md`）。

### 調査資料
| 資料 | 内容 |
|---|---|
| `reports/ビルド多様性 デッキ構築設計.md` | 二本のスケール軸でビルドを割る設計の結論（出典つき） |
| `research_notes/ビルド多様性 デッキ構築設計/` | StS2 の難易度と「壊れる自由」、LoL のアイテム設計、デッキ構築の型、装備スケーリング、現状コードの調査 |
| `reports/AIゲームアセット制作の最新手法.md` | Codex / 画像AI でアセットを作る手法のまとめ |
| `research_notes/AIゲームアセット制作の最新手法/` | Codex・GPT Image の手順、現行パイプライン、ドット絵の OSS など |
| `docs/sts2_research.md` | StS2 のマップ・幕構成 |
| `docs/events.md` | StS2 のイベント調査と、このゲームのイベントの型 |
| `docs/ui_readability.md` | 文字の読みやすさの決まり（WCAG のコントラスト値） |
| `docs/character_design.md` / `docs/hero_blue_design.md` | 主人公・敵・祝福キャラ・世界観の設計 |
| `docs/art_direction.md` | アートディレクション（旧テーマ。今の正本は manifest の `style`） |

## Codex で絵を作る（使用回数の上限に注意）

`tools/codex_art/generate.py` が manifest（`tools/codex_art/*_assets.json`）を読み、`codex exec` + `$imagegen` で raw (`tools/codex_art/raw/<id>.png`) を作り、透過トリム・リサイズして `out` に書き出す。

```powershell
python tools/codex_art/generate.py --manifest tools/codex_art/hero_blue_ui_assets.json --grid --workers 4
python tools/codex_art/generate.py --only card_bud --force    # id 前方一致で作り直し
python tools/codex_art/generate.py --post-only                 # Codex を呼ばずに後処理だけやり直す
```

**Codex には使用回数の上限がある。** 1枚ずつ何十回も呼ぶと上限に当たり、絵がまったく作れなくなる（以前 95 回連続で呼んで問題になった）。呼び出し回数を最小にすることを最優先にする。

| 種類 | 1回の呼び出しで描く数 |
|---|---|
| キャラクター（主人公・敵・祝福キャラ・立ち絵・アニメのコマ） | 解像度が要るので **1〜2体、多くても4体まで** |
| アイコン（状態異常・レリック・ポーション・インテント・HUD・マップのマス） | **10〜30個を1枚に並べて描き、分割して使う** |
| カード絵 | 2x2（4枚）で実績あり |
| 背景・イベント絵 | 1枚ずつ |

- 今の `--grid` は 2x2（4個/回）固定（`generate_grid` / `QUADRANTS`）。アイコンをまとめて10〜30個描くときは、まず `generate_grid` を N×M のマスに拡張し（例: 4x4=16, 5x6=30）、`clean_quadrant` の隣マスのはみ出し除去と `alpha_ok` の透過判定が効くことを1回試してから残りを流す。
- 大きな生成の前に、**何回 Codex を呼ぶ予定かをユーザーに伝える**。まず1回だけ試して、品質を見てから残りを実行する。
- 自動の再試行を重ねない。`make_raw` は失敗時に1回だけ再試行し、透過に失敗したら緑背景で1回描き直す — これ以上のループを足さない。
- 後処理だけの修正は `--post-only` で済ませ、Codex を呼ばない。別アセットと同じ絵は manifest の `reuse_raw` で流用する。
- キャラの見た目は `tools/codex_art/refs/` の正本画像を `refs` で添付してそろえる（`refs` 付きは grid にできない）。アニメは `sheet: <コマ数>` で横一列に描かせて分割する。
- manifest の主なキー: `size`, `transparent`, `fit: stretch`, `chroma_key`, `anchor: bottom`, `sheet`, `keep_frames`, `refs`, `pixel`, `greenscreen`, `reuse_raw`, `category`（`card_art` なら不透明のまま grid 可）。
