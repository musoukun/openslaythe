# Claude Code 用 2D ゲームアセット制作ツール（Skills / Plugins / MCP）調査ノート

調査日: 2026-10-16。GitHub の数値（★・作成日・最終 push 日）は `gh api` で 2026-10-16 に取得した値。「最終 push」はリポジトリの pushed_at で、README の主張とは別に保守状況の目安として使う。
前提環境: Windows 11 / Godot 4.6 / RTX 5070 Ti 16GB / 画像生成は `tools/codex_art/generate.py`（`codex exec` + `$imagegen` → Pillow 後処理）。

凡例: 【新】= 2026-09-01 以降に作成、または 2026-09〜10 に大きなリリースがあったもの。【旧】= それ以前。未検証 = 一次情報で確認できなかったもの。

---

## Q1. Claude Code 向けの skill / plugin で、ゲームアート・ドット絵・スプライトシート・画像生成を扱うもの

### Takeaway
Anthropic 公式の `anthropics/skills` にゲームアート用スキルはない。実用レベルなのはコミュニティ製の **0x0funky/agent-sprite-forge**（★4,467、v0.4.0 が 2026-10-06）と **aldegad/sprite-gen**（★2,833、v2.44.0 が 2026-10-09）の2つ。どちらも Codex CLI を画像生成の経路に使え、agent-sprite-forge は Godot の SpriteFrames `.tres` と TileMapLayer を直接書き出せる。

### Cited Findings
**公式**
- 【旧】`anthropics/skills`（★181,400、作成 2025-09-22、最終 push 2026-10-09）の `skills/` にあるのは academy-guide, algorithmic-art, brand-guidelines, canvas-design, claude-api, discernment-nudge, doc-coauthoring, docx, frontend-design, internal-comms, mcp-builder, pdf, pptx, skill-creator, slack-gif-creator, theme-factory, web-artifacts-builder, webapp-testing, xlsx。スプライト、ドット絵、ゲームアセット用のスキルはない（gh api で一覧を取得）— [anthropics/skills](https://github.com/anthropics/skills)
- 【旧・参考】OpenAI 公式の `openai/skills`（★28,093、最終 push 2026-09-08）には `skills/.system/imagegen`（SKILL.md、references/cli.md、image-api.md、prompting.md、codex-network.md）がある。Codex 側の `$imagegen` の中身にあたる — [openai/skills](https://github.com/openai/skills)

**スプライト生成スキル（主力）**
- 【新】**0x0funky/agent-sprite-forge** — ★4,467、作成 2026-04-23、最終 push 2026-10-06、v0.4.0 リリース 2026-10-06。Claude Code（plugin）、Codex、Grok に対応 — [GitHub](https://github.com/0x0funky/agent-sprite-forge)
  - v0.4 の流れ: 承認した1枚の立ち絵（master still）から、アクションごとに image-to-video のクリップを作る。そこから決まった手順の Python ツールで、キーイング、位置合わせ、ループ検出、リタイム、仕上げ、パッケージ化を行う。
  - 画像の経路は `route_media.py` にまとまっている。API キー（OpenAI / Gemini / xAI / BytePlus / fal.ai）を設定していればそれを使い、なければサインイン済みの Codex か Grok の CLI を使う。デモの master still は「ローカルの Codex CLI（`image_gen`）」で生成されている。
  - ドット絵の仕上げ処理の数値（48x64 の狐、8フレーム）: 1フレームあたりの色数 594–709 → 16–19、alpha の段階数 199 → 2（2値）。
  - Godot への書き出し: `export_engine.py --target godot-spriteframes` で SpriteFrames `.tres` と AnimatedSprite2D `.tscn` を、`godot-sprite3d` で Sprite3D 用を出す。マップは Godot 4.3+ の TileMapLayer シーン、Tiled 1.10、LDtk 1.5.3 に対応。Aseprite JSON も出せる。
  - 注意（README の自己申告）: "Editor imports are not verified yet"。書き出しは構文レベルの往復確認だけで、0.4.0 の Godot / LDtk / Aseprite の出力をエディタで開いた人はまだいない。
  - `generate2dmap` スキルで、レイヤー分けしたマップ、タイル、オートタイル、横スクロールのステージを作れる。Godot のタワーディフェンスと RPG の TileMap がショーケースにある。
- 【新】**aldegad/sprite-gen** — ★2,833、作成 2026-05-12、最終 push 2026-10-15、v2.42〜v2.44 を 2026-10-08〜09 に連続リリース。「Codex/Claude skill and a Python CLI」 — [GitHub](https://github.com/aldegad/sprite-gen)
  - パイプライン A（atlas rows）は `prepare → gen-set --provider codex → extract → compose-atlas`。出力は `sprite-sheet-alpha.png` と、フレームの矩形・fps・ループ指定を持つ `manifest.json.frame_layout`。
  - パイプライン B（video → loop）は Grok Imagine の動画から透過ループを切り出す。ffmpeg、img2webp、grok ログインか `XAI_API_KEY` が必要。
  - ユーティリティ: `cutout` / `slice-sheet` / `unpack-atlas` / `recolor` / `background-tile`。Aseprite / Phaser / Flame へ書き出せるが、README に Godot 専用の書き出しの記載はない（grep で該当なし）。
  - 「Backbone Lattice」で被写体全体に1つのグリッドを測り、ドット絵がグリッドからずれないようにする。
- 【旧】**Clad3815/character-sprite-maker** — ★23、作成・最終 push とも 2026-05-02（以後更新なし）。Codex / Claude / Cursor 向け。行・フレーム数・セルサイズの指定、クロマキー除去、アトラスの検証ができる — [GitHub](https://github.com/Clad3815/character-sprite-maker)
- 【旧】**gididaf/sprite-forge** — ★2、最終 push 2026-06-11。Claude が SVG を書き、それを変換してスプライトシートやタイル用テクスチャにする方式 — [GitHub](https://github.com/gididaf/sprite-forge)
- 【旧】**adamlyttleapps/claude-skill-game-assets-enhancer** — ★53、作成 2026-07-16、最終 push 2026-07-17。既存ゲームの絵を fal.ai でスプライト単位に描き直す — [GitHub](https://github.com/adamlyttleapps/claude-skill-game-assets-enhancer)
- 【旧】**jwynia/agent-skills** の `godot-asset-generator` — リポジトリ ★172、最終 push 2026-02-24。Godot 4.x 向けのスプライトシート、タイルセット、インポート設定を、DALL-E / Replicate / fal の API で準備するスキル（中身は `pixel-art-templates.json` やスタイルガイドのテンプレートなど） — [GitHub tree](https://github.com/jwynia/agent-skills/tree/main/skills/tech/game-development/godot/godot-asset-generator), [Skillselion](https://skillselion.com/skills/jwynia/agent-skills/godot-asset-generator)
- 【新】**JadeYui07/pikatang-pixel-art-skill** — ★43、作成 2026-10-08。Codex スキル。Pikatang 風のちびキャラ、ペット、部屋のドット絵を作る。生成は環境にある画像ツールか同梱の Gemini API スクリプトで行い、SpriteCook も使える。後処理（グリッド検出・再サンプリング）は「Perfect Pixel adapter」、仕上げは Aseprite への手渡し手順として文書化されている — [GitHub](https://github.com/JadeYui07/pikatang-pixel-art-skill)

**ゲーム開発スキル集（Godot の知識）**
- 【新・継続更新】**gamedev-skills/awesome-gamedev-agent-skills** — ★1,538、作成 2026-06-24、最終 push 2026-10-09。10エンジン向けに74スキルと router を持ち、`claude plugin install godot@awesome-gamedev-agent-skills` で入る。Godot 用は16スキル（`godot-tilemap`、`godot-animation`、`godot-resources` ほか）で、ベースラインは「Godot 4.7」。discipline 系の `create-game-assets` は、スプライト、タイル、UI アートの「アートディレクションと制作パイプライン」を扱う — [GitHub](https://github.com/gamedev-skills/awesome-gamedev-agent-skills)
- 【新】**Qb-Lab/godot-agent-skills** — ★0、作成 2026-08-30、最終 push 2026-09-17。`.tscn` / `.tres` を UID を壊さずに編集すること、Godot 3 の API（`yield`、`.instance()`、`export var`）の混入を防ぐこと、実行して検証すること、の3点を Claude Code の hooks で強制する — [GitHub](https://github.com/Qb-Lab/godot-agent-skills)

**Aseprite 連携 plugin**
- 【旧・停滞】**willibrandon/pixel-plugin** — ★364、作成 2025-10-17、最終 push 2025-10-19。Claude Code plugin で、裏で動く MCP は **willibrandon/pixel-mcp**（★152、最終 push 2025-10-18）。自然言語でドット絵を描き、アニメーション、ディザ、パレットを扱う。約1年更新がない — [pixel-plugin](https://github.com/willibrandon/pixel-plugin), [pixel-mcp](https://github.com/willibrandon/pixel-mcp)

**商用（README やリポジトリは未確認）**
- SpriteCook: Claude Code / Desktop 用に、アセットの生成とアニメーションの MCP ツールを出している（詳細は未検証）— [spritecook.ai/claude](https://www.spritecook.ai/claude)
- AutoSprite: Claude Code / Codex から MCP で呼べ、透過 PNG のシートと JSON アトラスを出す（詳細は未検証）— [autosprite.io/claude](https://www.autosprite.io/claude)

### Inferences
- いまの `generate.py`（Codex `$imagegen` → Pillow 後処理）にいちばん近いのは sprite-gen の A パイプラインと agent-sprite-forge の master still 工程。agent-sprite-forge は Godot の SpriteFrames 書き出しまで持っているので、「キャラのアニメーション」が必要になったときの第一候補になる。ただしエディタでの読み込みは作者も未確認なので、自分のプロジェクトで最初に確かめる必要がある。
- 2026-04 から 10 にかけて「1枚の立ち絵 → image-to-video → フレームを抽出して透過ループにする」流れが主流になった（agent-sprite-forge と sprite-gen が両方そうなっている）。画像モデルに直接スプライトシートを描かせる方式は、キャラの同一性が保てないことが両 README で問題として挙げられている。
- 静止画中心のカードゲーム（OpenSlay）では、動画の工程はやりすぎの可能性が高い。`slice-sheet` や `cutout`、ドット絵のグリッド補正などのユーティリティだけ参考にするのも手。

### Gaps
- SpriteCook / AutoSprite の料金、MCP のツール一覧、開始日（未検証）。
- agent-sprite-forge が書き出す `.tres` を Godot 4.6 で開けるか（作者も未確認）。
- `anthropics/claude-plugins-official` などの公式 marketplace にゲームアート用の plugin があるかは未調査。

---

## Q2. 用途別の MCP サーバーと、2026-10 時点の保守状況

### Takeaway
Godot・Aseprite・ComfyUI は MCP の選択肢が多い。画像生成は Gemini（Nano Banana）向けが充実しているが、OpenAI 画像向けは小規模なものばかり。ピクセルアート SaaS では PixelLab が公式 MCP を出している。気をつける点は2つ。Godot 4.7（2026-06-18 リリース）を前提にしたサーバーが増えていて、4.6 の環境では動作要件の確認が要る。Blender MCP は `ahujasid/mcp-for-blender` に改名されている。

### Cited Findings
**Godot エディタ制御**（参考: Godot 4.7-stable は 2026-06-18、4.7.2 は 2026-08-18、4.6.3 は 2026-05-20 にリリース — [godotengine/godot releases](https://github.com/godotengine/godot/releases)）
- 【旧・定番】**Coding-Solo/godot-mcp** — ★6,106、作成 2025-02-26、最終 push 2026-04-16（半年更新なし）。エディタの起動、プロジェクトの実行、デバッグ出力の取得などができる — [GitHub](https://github.com/Coding-Solo/godot-mcp)
- 【継続更新】**tugcantopaloglu/godot-mcp** — ★488、作成 2026-02-08、最終 push 2026-10-09、MIT。Coding-Solo 版のフォークで、20ツールから157ツールに増やしている。v3.0 で C#、`validate_script`、ランタイムで任意の GDScript を実行する `game_eval`、`game_screenshot` などが入った — [GitHub](https://github.com/tugcantopaloglu/godot-mcp)
- 【継続更新】**youichi-uda/godot-mcp-pro** — ★625、作成 2026-02-24、最終 push 2026-09-24。187ツール。WebSocket（ポート 6505）でエディタのプラグインとつなぐ。**公開リポジトリには Godot アドオンしか入っておらず、MCP サーバー本体は買い切りの有料版（itch.io / Buy Me a Coffee）**。`get_editor_screenshot` / `get_game_screenshot` / `compare_screenshots` があり、一部のツールは Godot 4.7+ が必要 — [GitHub](https://github.com/youichi-uda/godot-mcp-pro)
- 【旧】**tomyud1/godot-mcp** — ★435、最終 push 2026-08-24、MIT。75ツールで undo/redo に対応。AssetLib から「Godot AI Assistant tools MCP」として入れ、`npx -y godot-mcp-server` で動かす — [GitHub](https://github.com/tomyud1/godot-mcp)
- 【旧】yurineko73/Godot-MCP-Native（★851、最終 push 2026-08-03）と DaxianLee/godot-mcp（★548、最終 push 2026-01-14）は中国語圏のプラグイン型 — [Godot-MCP-Native](https://github.com/yurineko73/Godot-MCP-Native), [DaxianLee](https://github.com/DaxianLee/godot-mcp)
- 【旧・停滞】ee0pdt/Godot-MCP（★620、最終 push 2025-03-19）、bradypp/godot-mcp（★90、最終 push 2025-05-31） — [ee0pdt](https://github.com/ee0pdt/Godot-MCP), [bradypp](https://github.com/bradypp/godot-mcp)
- 【新】**leftos/godot-mcp** — 作成 2026-09-26、最終 push 2026-10-13、★2。ゲームを動かして、見て、操作することに特化している。画面外・入力無効で起動でき、スクリーンショット（アニメーションの指定時刻で連写できる）、ビジュアル回帰用のベースライン、動画の録画、入力の再生などがある。必要環境は「Godot 4.7.2 の console 実行ファイル」 — [GitHub](https://github.com/leftos/godot-mcp)
- 【新】**bebabinlarsson-blip/Godot-MCP** — 作成 2026-09-17、★24。説明文に「Official Plugin for the Godot Engine」とあるが、Godot 公式の組織のリポジトリではない。README は v5.0.39 を名乗り、「81 tool families / 1,820+ operations」、tileset 操作、Kenney の CC0 素材検索を備え、**Godot 4.7 以降が必須**。公開トンネル機能もある — [GitHub](https://github.com/bebabinlarsson-blip/Godot-MCP)
- 【新】そのほか 2026-09 以降に作成されたもの: gurolayanlar/godot-mcp-flash（★14）、SrDarkoll/godot-mcp（★3）、Tann2019/godot-mcp-server「Godot Forge」（★1）、grinry/godot-mcp（★1、Coding-Solo 系）。いずれも★が少なく、評価は定まっていない（gh search で取得）。
- 比較記事の注意: Summer Engine の「Best Godot MCP Server 2026」は、自社の MCP を売っている会社が書いた比較 — [summerengine.com](https://www.summerengine.com/blog/best-godot-mcp-server.md)

**Aseprite**
- 【旧・最多★】**diivi/aseprite-mcp** — ★701、作成 2025-04-05、最終 push 2026-07-29。Python 製で、Aseprite API を操作する — [GitHub](https://github.com/diivi/aseprite-mcp)
- 【継続更新】**MalloyTheDev/aseprite-mcp** — ★20、作成 2026-06-12、最終 push 2026-10-11。156ツール。Lua スクリプトを作って `aseprite -b --script` のバッチモードで実行し、`.aseprite` ファイルを編集・保存したままにする。描いた結果を計測する機能がある — [GitHub](https://github.com/MalloyTheDev/aseprite-mcp)
- 【旧】youichi-uda/aseprite-mcp-pro（★34、121ツール、最終 push 2026-07-20）、ZhangDongyang800/Aseprite_MCP（★13、最終 push 2026-09-21。描いたキャンバスを見て直す「目」を持つ）、giangdvdotdev/aseprite-mcp（★8、開いているエディタでライブに描く）、rkdfx/aseprite-mcp（★12、最終 push 2026-04-17）、ayigityol/aseprite-mcp（★7、43ツール、2026-03-07 以後更新なし） — [aseprite-mcp-pro](https://github.com/youichi-uda/aseprite-mcp-pro), [ZhangDongyang800](https://github.com/ZhangDongyang800/Aseprite_MCP), [rkdfx](https://github.com/rkdfx/aseprite-mcp)
- 【新】logiksecurity/ase-mcp（作成 2026-07-18、最終 push 2026-09-20、★2）は開いている Aseprite のセッションに接続する。Windows ホストと Aseprite 1.3+ が対象で、Apache 2.0 — [GitHub](https://github.com/logiksecurity/ase-mcp)
- 【新】sloplink/aseprite-mcp（2026-09-16、★7）、ParthMmm/aseprite-mcp（2026-10-14、★0。「code mode」でツールは1つ、処理ごとに undo 1回）ほか、2026-09〜10 に★0〜1 の aseprite-mcp が8件以上作られている（gh search）。

**ピクセルアート SaaS**
- 【旧】**PixelLab 公式 MCP** — `pixellab-code/pixellab-mcp`（★42）。リポジトリ自体は 2025-08-10 が最後のコミットで、設定は https://www.pixellab.ai/vibe-coding に案内している。4方向・8方向のキャラ生成（`create_character`）、`animate_character`、`create_tileset`、`create_isometric_tile` が使え、Claude Code にも対応。PixelLab の API トークンが必要 — [GitHub](https://github.com/pixellab-code/pixellab-mcp), [mcpservers.org](https://mcpservers.org/servers/pixellab-code/pixellab-mcp)
- 【新・小規模】rabbitcannon/pixellab-forge-mcp（★1、最終 push 2026-09-13、「API access to V2+」） — [GitHub](https://github.com/rabbitcannon/pixellab-forge-mcp)
- DasDarki/PixelLabRat は検索結果に出てきたが、GitHub API では 404 だった（非公開か削除。**未検証**）。

**画像生成**
- Gemini: **zhongweili/nanobanana-mcp-server** — ★400、最終 push 2026-10-07。モデルの自動選択と 4K 出力 — [GitHub](https://github.com/zhongweili/nanobanana-mcp-server)。ConechoAI/Nano-Banana-MCP（★234）は最終 push 2025-11-04 で停滞 — [GitHub](https://github.com/ConechoAI/Nano-Banana-MCP)
- OpenAI gpt-image: 2026-09〜10 に作られたものは zK0G0w/gpt-image-mcp、youbotapi/gpt-image-mcp（GPT Image 2.5）、swissmarley/gpt-image-mcp（Cloudflare Tunnel を使うリモート MCP）、meet244/ChatGPT-Images-MCP など。どれも★0〜1。古いものでは jerryzhao173985/openai-image-gen-mcp（★5、2025-05 で停止）がある（gh search）。
- Replicate: GongRzhe/Image-Generation-MCP-Server（★51、Flux、最終 push 2025-04-15 で停滞） — [GitHub](https://github.com/GongRzhe/Image-Generation-MCP-Server)
- fal.ai / Replicate の公式 MCP: `fal-ai/fal-mcp` と `replicate/replicate-mcp-server` は GitHub に存在しなかった（404）。fal.ai の MCP がある、という情報はディレクトリサイト経由のものだけ（**未検証**）。

**ComfyUI（ローカル GPU で使う場合）**
- 【公式・新しい】**Comfy-Org/comfy-mcp** — ★281、作成 2026-07-01、最終 push 2026-10-16、v0.10.0（2026-08-10）。`comfy-cli` を土台にした公式のローカル MCP で、Claude Code から自分の ComfyUI を操作できる。公式 MCP Registry に `io.github.Comfy-Org/comfy-mcp` として登録されている。**ライセンスは AGPL-3.0-or-later または商用ライセンス**。クラウド版は Comfy-Org/comfy-cloud-mcp（★22） — [comfy-mcp](https://github.com/Comfy-Org/comfy-mcp), [comfy-cloud-mcp](https://github.com/Comfy-Org/comfy-cloud-mcp)
- **artokun/comfyui-mcp** — ★828、最終 push 2026-10-14。README には「Limited maintenance has resumed」とあり、重大な修正だけを出し、機能追加の予定はない。Comfy 公式のローカルパネルが公開されたら、サポートを見直すとしている — [GitHub](https://github.com/artokun/comfyui-mcp)
- joenorton/comfyui-mcp-server（★410、最終 push 2026-02-17）、ATH-MaaS/Pixelle-MCP（★1,128、最終 push 2025-12-17） — [joenorton](https://github.com/joenorton/comfyui-mcp-server), [Pixelle-MCP](https://github.com/ATH-MaaS/Pixelle-MCP)
- 【新】jjhpka/comfyui-mcp-docker（2026-10-02）は「official comfy-mcp」と ComfyUI を1つのコンテナにまとめ、**CUDA 13 / Blackwell 対応**をうたう（★1、内容は未検証）。RTX 5070 Ti（Blackwell）で関係がありうる。

**Blender（2D レンダー用）**
- **ahujasid/mcp-for-blender**（旧名 `ahujasid/blender-mcp`、API でリダイレクトされた）— ★30,971、作成 2025-03-07、最終 push 2026-10-06。説明文は「Community plugin…Not affiliated with the official Blender Foundation」 — [GitHub](https://github.com/ahujasid/mcp-for-blender)

### Inferences
- Godot 4.6 で使うなら、4.7 前提ではない Coding-Solo 系（tugcantopaloglu）か tomyud1 が無難。leftos と bebabinlarsson は 4.7 前提なので、4.6 で動くかは自分で確かめる必要がある。
- 2D アセットの取り込みで MCP がいちばん役に立つのは、スクリーンショットで見た目を確認する工程（godot-mcp-pro、tugcantopaloglu、leftos）。SpriteFrames や TileSet の `.tres` 自体は、スクリプト（agent-sprite-forge の `export_engine.py` や自作の GDScript ツール）で作るほうが単純で、再現もしやすい。
- ローカルの ComfyUI を使うなら Comfy-Org/comfy-mcp が今いちばん安心できる選択肢（公式で、毎日 push されている）。ただし AGPL なので、配布物に組み込まない運用にすること。

### Gaps
- 各 Godot MCP の Godot 4.6 での実際の動作（README からは判断できない）。
- PixelLab の現在の料金、MCP のエンドポイントがリモートかどうか（vibe-coding のページは WebFetch でリダイレクトになり取得できなかった）。
- fal.ai / Replicate の公式 MCP の有無と URL。

---

## Q3. 2026-09〜10 の注目リリース・投稿

### Takeaway
この期間の大きな出来事は3つ。**OpenAI の GPT Images 2.5（2026-09-08、Codex でも使える）**、**agent-sprite-forge v0.4.0（2026-10-06、動画からスプライトを作る方式へ移行）**、**sprite-gen v2.4x 系の連続リリース**。Godot MCP と Aseprite MCP は新しいリポジトリが大量に作られているが、どれも★が少なく、評価は定まっていない。

### Cited Findings
- **GPT Images 2.5**: OpenAI Community のお知らせは 2026-09-08 19:12 UTC。API のモデル名は `gpt-image-2.5-flare` と `gpt-image-2.5-sunburst`（Sunburst は生成に時間がかかる代わりに精密）。うたっている改善点は、生成の高速化、忠実度、複数回の編集でも細部が一貫すること、コメントで指示する部分編集。関連するコミットには `opaque` の背景オプションと、品質の `xhigh` / `max` がある。スレッド内では透過背景についての明記は確認できなかった — [OpenAI Community](https://community.openai.com/t/introducing-gpt-images-2-5-in-the-api-and-chatgpt/1395897)
  - Codex で使えることについては、OpenAI の Images 2.5 の発表に Codex が含まれているとする記述がある — [oakplank/gpt-image-bridge README](https://github.com/oakplank/gpt-image-bridge)、[ai-orchestra.ai（日本語）](https://www.ai-orchestra.ai/codex-training/columns/codex-gazo-seisei)。OpenAI 本体の発表ページは 403 で直接は確認できなかった。
  - 「Codex ではまだ gpt-image 2.0 の画像が出る」というユーザーの報告もある（検索結果の要約によるもので、**未検証**）。
- **agent-sprite-forge v0.4.0**（2026-10-06）: 1枚の立ち絵から image-to-video を経て全アクションを作る方式に変わった。ソフトマットのキーヤーで紫のにじみが 0.704 → 0、ワンショットのリタイムで攻撃モーションが 4.1 秒 → 0.7 秒、HD のカラーロック — [GitHub](https://github.com/0x0funky/agent-sprite-forge)
- **sprite-gen v2.42–v2.44**（2026-10-08〜09）— [releases](https://github.com/aldegad/sprite-gen/releases)
- **awesome-gamedev-agent-skills** が Godot 4.7 をベースラインにして更新（最終 push 2026-10-09） — [GitHub](https://github.com/gamedev-skills/awesome-gamedev-agent-skills)
- **Codex を画像生成に使う Claude Code スキル（9〜10月に作成・更新）**: mishagavura/claude-code-image-generation（2026-09-30）、almeidasrenato/codex-image-skills（2026-09-25）、Attija/chatgpt-image-skill（2026-10-10）、oakplank/gpt-image-bridge（最終 push 2026-09-29、GPT Image 2.5 に言及）（詳細は Q4）
- **Godot MCP の新規作成（9〜10月）**: leftos/godot-mcp（2026-09-26）、bebabinlarsson-blip/Godot-MCP（2026-09-17）、SrDarkoll / Tann2019 / grinry / gurolayanlar ほか（Q2 参照）
- **Godot 用インポーターの新規作成（9〜10月、gh search）**: DRS90/dot-aseprite-importer（2026-09-17。3x3 の向きグリッドの `.aseprite` を SpriteFrames として取り込む）、spritesheetbuilder/sprite-atlas-importer（2026-09-26。TexturePacker / Phaser JSON や Sparrow XML のアトラスを Godot 4 に取り込む）、tamara-rifqi/2dfactory-godot-plugin（2026-09-08）、MakabakaGuo/video-frame-animator（2026-10-04。動画からフレームを抜き、AI で切り抜いて Godot 4 の SpriteFrames に書き出す）。いずれも★0〜1 — [dot-aseprite-importer](https://github.com/DRS90/dot-aseprite-importer), [sprite-atlas-importer](https://github.com/spritesheetbuilder/sprite-atlas-importer)
- **Comfy-Org/comfy-mcp** は 2026-07 に作成され、2026-10-16 時点でも毎日更新されている — [GitHub](https://github.com/Comfy-Org/comfy-mcp)

### Inferences
- 2026-09〜10 の主な流れは「Codex（ChatGPT のサブスク）で画像を作り、Claude Code で全体を操る」というブリッジの量産と、「image-to-video でスプライトを作る」方式への移行。このプロジェクトの `generate.py` はすでに前者の型に沿っている。
- Images 2.5 のモデルが Codex の `$imagegen` で実際に使われているかは、出力を見比べないと分からない。

### Gaps
- OpenAI 本体の発表ページの全文（403 で取得できなかった）。
- X / Reddit（r/aigamedev、r/godot）の個別の投稿は、検索ツールでは十分に拾えなかった。Zenn に Claude Code ×ドット絵の記事は見つからなかった。

---

## Q4. Claude Code（コードと全体の操作）と Codex / ChatGPT（画像生成）を1つのパイプラインでつなぐ方法

### Takeaway
定番の方法は「Claude Code のスキルやシェルから `codex exec` を呼び、Codex 組み込みの画像生成ツール（`$imagegen` / `image_generation`）に描かせ、PNG を指定のパスにコピーする」というもの。ChatGPT のサブスクで課金されるので API キーは要らない。このプロジェクトの `generate.py` は同じ方式をすでに Python で実装している。

### Cited Findings
- **oakplank/gpt-image-bridge** — ★62、作成 2026-04-23、最終 push 2026-09-29。単体の bash スクリプトで、`codex exec` の `image_generation` ツールを ChatGPT の認証で呼ぶ。Codex はサンドボックスで自分の作業ディレクトリにしか書けないので、**専用の一時ディレクトリに出力させてからラッパーがコピーする**。こうすると任意のパスや Windows のパスにも対応できる。モデルは「Codex が提供するものを使い、選択も検証もしない」 — [GitHub](https://github.com/oakplank/gpt-image-bridge)
- **Sateezg/codex-bridge** — ★246、作成 2026-08-09、最終 push 2026-08-10。Claude Code の plugin。gpt-image-2 で画像を作り、さらに review / debug / 大量実装 / 画像の4つの Codex サブエージェントを持つ。前に作った画像を `--ref` で渡してスタイルを揃える。Claude は生成結果を見て、外れていれば作り直す — [GitHub](https://github.com/Sateezg/codex-bridge)
- **wjb127/codex-image** — ★64、最終 push 2026-07-24。Codex CLI の OAuth を使う画像生成スキル（韓国語・英語） — [GitHub](https://github.com/wjb127/codex-image)
- 【新】mishagavura/claude-code-image-generation（★5、2026-09-30）、almeidasrenato/codex-image-skills（★0、2026-09-25。Codex CLI か chatgpt.com の経路）、Attija/chatgpt-image-skill（★0、2026-10-10、オランダ語）、colin-automates/Codex-ImageGen--Claude-Code（★3、2026-04-27） — [mishagavura](https://github.com/mishagavura/claude-code-image-generation), [almeidasrenato](https://github.com/almeidasrenato/codex-image-skills), [colin-automates](https://github.com/colin-automates/Codex-ImageGen--Claude-Code)
- **しらたま「Claude Code から Codex CLI でサブスク画像生成」**（note、2026-06-01）は Windows / PowerShell での落とし穴をまとめている — [note.com](https://note.com/shiratama1126/n/nfab5d83b40f0)
  - `codex login` で ChatGPT アカウントにサインインし、`authMethod` が `chatgpt` になっていることを確かめる（`api_key` なら作り直す）。
  - PowerShell では UTF-8 の設定（`$OutputEncoding` など）をしないと、日本語のプロンプトや保存パスが「?」に化け、ファイルが書き出されない。
  - プロンプトをコマンドの引数で渡すと stdin 待ちで止まる。here-string をパイプで `codex exec` に渡せば動く。
  - 画像はまず `~/.codex/generated_images/<session>/` に書かれ、そこからコピーされる。コピーに失敗したらここを探す。
  - プロンプトでモデル（gpt-image-2）を名指ししないと、低品質な既定モデルに落ちることがある。
  - 著者の SKILL.md は、承認とサンドボックスを飛ばすフラグを常に付ける設計になっている（セキュリティ上の注意は Q5）。
- agent-sprite-forge と sprite-gen も、Codex CLI を画像生成の経路の1つとして組み込んでいる（`route_media.py`、`gen-set --provider codex`） — [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge), [sprite-gen](https://github.com/aldegad/sprite-gen)
- 逆向き（Codex / ChatGPT から Claude を使う）の例として、artokun/comfyui-mcp-panel は「Claude と ChatGPT どちらのサブスクでも動く」ComfyUI のサイドバーエージェント — [GitHub](https://github.com/artokun/comfyui-mcp-panel)

### Inferences
- いまの `generate.py`（`%LOCALAPPDATA%\OpenAI\Codex\bin\*\codex.exe` を探して `codex exec` + `$imagegen` を呼び、`raw/` に保存して Pillow で後処理する）は、上のブリッジと同じ構成。新しく MCP を入れる必要は薄い。取り入れる価値があるのは次の3つ。
  1. gpt-image-bridge のように、一時ディレクトリに出力させてからコピーする。サンドボックスを緩めずに済む。
  2. codex-bridge の `--ref` のように、参照画像でスタイルを揃える。
  3. sprite-gen や agent-sprite-forge にある、後処理（クロマキーでの alpha 抽出、ドット絵のグリッド補正）と Godot への書き出しのやり方。
- Claude は画像を読めるので、「生成 → Claude が見て判定 → 作り直し」のループは skill の指示書だけで作れる（codex-bridge の設計がこれ）。

### Gaps
- Images 2.5 で Codex の `$imagegen` が透過 PNG を出せるかは、一次情報で確認できなかった。

---

## Q5. セキュリティ・保守面の注意

### Takeaway
主なリスクは5つ。(1) ★の少ない新しいリポジトリが乱立している、(2) 「Official」を名乗る非公式リポジトリがある、(3) 任意コードを実行するツール（`game_eval`、Lua / GDScript の実行）、(4) Codex のサンドボックスや承認を飛ばす設定、(5) 有料版や AGPL などライセンスの条件。

### Cited Findings
- 「Official Plugin for the Godot Engine」と名乗る bebabinlarsson-blip/Godot-MCP は、2026-09-17 に個人アカウントで作られたリポジトリ。Godot 公式の組織（godotengine）のものではない。公開トンネル機能について README 自身が、MCP サーバーがネットワーク外にさらされうると警告している — [GitHub](https://github.com/bebabinlarsson-blip/Godot-MCP)
- tugcantopaloglu/godot-mcp の `game_eval` は、実行中のゲームで任意の GDScript を実行する — [GitHub](https://github.com/tugcantopaloglu/godot-mcp)
- MalloyTheDev/aseprite-mcp は、作った Lua スクリプトを `aseprite -b --script` で実行する方式 — [GitHub](https://github.com/MalloyTheDev/aseprite-mcp)
- note の記事の構成は、`codex exec` に承認とサンドボックスを飛ばすフラグを常に付けている — [note.com](https://note.com/shiratama1126/n/nfab5d83b40f0)。これに対して gpt-image-bridge はサンドボックスを保ったまま、一時ディレクトリへの出力とコピーで対処している — [GitHub](https://github.com/oakplank/gpt-image-bridge)
- Codex 経由のブリッジは Codex 内部の挙動に依存している。保存先が `generated_images` に変わる、組み込みの画像ツールが有効でないと `save_path_not_found` になる、といった壊れやすさが指摘されている — [oakplank/gpt-image-bridge](https://github.com/oakplank/gpt-image-bridge), [mishagavura](https://github.com/mishagavura/claude-code-image-generation)
- API キー: 複数のプロバイダーを扱う画像 MCP は `OPENAI_API_KEY` / `GOOGLE_API_KEY` / `REPLICATE_API_TOKEN` を環境変数から読む（Glama の一覧より） — [glama.ai](https://glama.ai/mcp/servers/nm3xjlrjpb)。agent-sprite-forge も、API キーがあれば優先して使う — [GitHub](https://github.com/0x0funky/agent-sprite-forge)
- 有料・ライセンス: godot-mcp-pro はサーバーが有料（公開リポジトリだけでは動かない）— [GitHub](https://github.com/youichi-uda/godot-mcp-pro)。Comfy-Org/comfy-mcp は AGPL-3.0-or-later または商用 — [GitHub](https://github.com/Comfy-Org/comfy-mcp)
- 保守が止まっている、または縮小しているもの: willibrandon/pixel-plugin と pixel-mcp（2025-10 以後更新なし）、ee0pdt/Godot-MCP（2025-03）、bradypp/godot-mcp（2025-05）、ConechoAI/Nano-Banana-MCP（2025-11）、Coding-Solo/godot-mcp（2026-04 以後 push なし）、artokun/comfyui-mcp（README で保守縮小を宣言）（gh api の pushed_at と各 README）
- Godot のバージョン差: 2026-09 以降の MCP やスキルの多くは Godot 4.7 / 4.7.2 前提（leftos、bebabinlarsson、awesome-gamedev-agent-skills、godot-mcp-pro の一部ツール）。Godot 4.7-stable のリリースは 2026-06-18 — [godot releases](https://github.com/godotengine/godot/releases)

### Inferences
- 入れるなら次の順が安全。①スクリプトとスキルで完結させる（自作の `generate.py` を拡張する）。②★数百以上で最近も push されている OSS の MCP（tugcantopaloglu/godot-mcp、Comfy-Org/comfy-mcp）。③★の少ない新しいリポジトリは、コードを読んでから試す。
- MCP サーバーは Claude Code のプロジェクトスコープ（`.mcp.json`）で入れ、API キーを `.env` に置くなら `.gitignore` に入っていることを確かめる。これは一般的な運用上の推奨で、出典はない。

### Gaps
- 各 MCP について、依存パッケージの脆弱性や外部への通信の有無は監査していない（README のみ確認）。
