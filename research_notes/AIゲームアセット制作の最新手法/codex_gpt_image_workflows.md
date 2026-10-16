# OpenAI Codex / gpt-image で2Dゲームアセットを作る最新手法（2026年9月中旬〜10月中旬を中心に）

調査日: 2026-10-16。表記ルール: 【9-10月】＝2026-09-10〜10-16 の新情報、【旧】＝それ以前、【未検証】＝日付や中身を一次情報で確かめられなかったもの。

## Q1. Codex (CLI/アプリ/クラウド) の画像生成機能は2026年10月時点でどうなっているか。9〜10月に何が変わったか

### Takeaway
9月の大きな変化は2つ。(1) 2026-09-08 に GPT Image 2.5（API名 `gpt-image-2.5-flare` と `gpt-image-2.5-sunburst`）が出て、ChatGPT と Codex で使えるようになった。(2) Codex CLI 0.158.0（2026-09-28〜29）で、画像生成と編集が透明背景を明示的に指定できるようになり、編集にファイルとして保存された会話内画像を渡せるようになった。公式の Codex アプリ changelog には、9〜10月の画像生成に関する項目はほかに見当たらない。

### Cited Findings
- 【9-10月】**Codex CLI 0.158.0**: リリースノートの原文は "Image generation and editing can explicitly request transparent backgrounds" と "edits now accept file-backed conversation images"。PR は #47484 "Add explicit background control to image generation" と #47956 "Support file references in image edit requests"。GitHub 上の日付は "28 Sep"、Releasebot は 2026-09-29 と記録 — [GitHub release rust-v0.158.0](https://github.com/openai/codex/releases/tag/rust-v0.158.0); [Releasebot](https://releasebot.io/updates/openai/codex)
- 【9-10月】Codex CLI の9〜10月の版は 0.155.0（9/20）から 0.162.1（10/10）まで。画像関係の記載があるのは 0.158.0 だけだった（表示が "Show more" で切れていた項目もあるので、取りこぼしの可能性は残る）。0.159.0 では同梱の plugin-creator スキルが削除された — [Releasebot](https://releasebot.io/updates/openai/codex)
- 【9-10月】**GPT Image 2.5（ChatGPT Images 2.5）の公開は 2026-09-08**。ChatGPT、ChatGPT Work、Codex の全ユーザー向けで、API には Flare（速度と量向け）と Sunburst（精密な編集向け。そのぶん遅い）の2モデルが追加された。OpenAI は Flare を GPT-Image-2 の2〜4倍速いとしている。一方 fal は「レイテンシ50%減」と書いており、数字が合わない — [Wikipedia: GPT Image](https://en.wikipedia.org/wiki/GPT_Image); [OpenAI announcement](https://openai.com/index/introducing-chatgpt-images-2-5/)（本文は403で取得できず、検索スニペット経由）; [fal](https://fal.ai/gpt-image-2.5); [DataCamp](https://www.datacamp.com/blog/chatgpt-images-2-5)
- 【9-10月時点の公式APIドキュメント】モデルIDは `gpt-image-2.5-sunburst` と `gpt-image-2.5-flare`。ドキュメントの説明は "Choose Sunburst for workflows where editing precision matters most, and Flare for fast, high-quality everyday image generation."。Responses API では本体モデル（例 `gpt-6-astra`）を選び、image tool の `model` にこの2つのどちらかを指定する — [OpenAI Image generation guide](https://developers.openai.com/api/docs/guides/image-generation)
- サイズ: 推奨は 1024x1024 / 1536x1024 / 1024x1536。任意サイズも使えるが、縦横は16の倍数、縦横比は1:3〜3:1、一辺は最大3840px、総画素数は655,360〜8,294,400。2560x1440 を超える解像度は experimental — [同上](https://developers.openai.com/api/docs/guides/image-generation)
- `background`: `transparent` / `opaque` / `auto` から選ぶ。透明背景は両モデルで使え、出力形式は png か webp にする — [同上](https://developers.openai.com/api/docs/guides/image-generation)
- `quality`: `low` / `medium` / `high` / `xhigh` / `max` / `auto`。`xhigh` と `max` は2.5系で追加された（それより前のモデルは `high` まで）。`n` で1回のリクエストから複数枚を出せる。参照画像の上限はドキュメントに書かれていない（例では4枚）。複数の入力画像にマスクを使うと、マスクは1枚目に適用される — [同上](https://developers.openai.com/api/docs/guides/image-generation)。第三者の資料には「1回の編集で参照画像16枚まで」とあるが、公式では確認できていない（【未検証】）— [DataCamp](https://www.datacamp.com/blog/chatgpt-images-2-5)
- 【旧・2026-04】Codex 公式の **imagegen スキル**（openai/skills の `skills/.system/imagegen`）には2つのモードがある。(a) 既定は組み込みの `image_gen` ツールで、APIキーは要らない。(b) CLI フォールバックは `scripts/image_gen.py` を使い、サブコマンド `generate` / `edit` / `generate-batch` を持つ。こちらは `OPENAI_API_KEY` が必要で、ユーザーが明示したときしか使わない。組み込みツールの出力先は `$CODEX_HOME/generated_images/...` なので、プロジェクトで使う画像はワークスペースへ移す決まりになっている。手元のファイルを組み込みツールで編集するときは、先に `view_image` で会話に読み込む。組み込みツールでの複数枚生成は「1枚につき `image_gen` を1回呼ぶ」。SKILL.md は用途として "game assets" や "sprites" を挙げている。このパスの最終コミットは 2026-04-15 — [openai/skills imagegen SKILL.md](https://github.com/openai/skills)（gh api で取得）
- 【旧】第三者ブログによると、2026年4月に Codex CLI の既定画像モデルが gpt-image-1.5 から gpt-image-2 に変わった — [Daniel Vaughan blog](https://codex.danielvaughan.com/2026/04/27/codex-cli-image-generation-gpt-image-2-visual-development-workflows/)
- 【9-10月】Codex アプリの9〜10月の公式 changelog には、画像生成、gpt-image、透明背景についての項目がない。関係ありそうなのは 2026-09-11 の Pets 機能の更新（"Custom pets also stay in place when you refresh their artwork." など）と、`$` でスキルを選べる Quick chats だけ — [ChatGPT & Codex changelog](https://learn.chatgpt.com/docs/changelog)

### Inferences
- プロジェクトの `tools/codex_art/generate.py` が Codex の組み込み生成を呼んでいるなら、0.158.0 以降は透明背景を「明示的に」指定できる。これまでのクロマキー後処理が要らなくなる可能性がある（実際の出力のアルファ品質は試して確かめる必要がある）。
- API を直接使う場合、スプライトシートの下書きは `gpt-image-2.5-flare`、前フレームや参照画像を使った精密な編集は `gpt-image-2.5-sunburst`、と使い分けるのが公式の説明どおり。

### Gaps
- Codex の組み込み `image_gen` が今どのモデル（2.5 Flare/Sunburst のどちらか、またはその他）を使っているのかを、公式の一次情報で確認できなかった。
- 公式価格ページ（2.5系の1枚あたりの料金）は取得できていない。
- OpenAI の発表ページ本文が403で読めず、そこからの数値は検索スニペット経由。

## Q2. ゲームアセット生成向けの公式／人気の Codex スキル・AGENTS.md パターン・プラグイン

### Takeaway
公式は `imagegen`（汎用）と `hatch-pet`（Codex ペット用スプライトアトラス）の2つ。コミュニティでは agent-sprite-forge と sprite-gen が大きく、どちらも9〜10月に大型更新があった。両者とも「静止画1枚 → 画像から動画を生成 → 決定論的な Python 後処理」という流れに軸足を移している。

### Cited Findings
- **openai/skills**（Skills Catalog for Codex）: ★28,093。最終 push は 2026-09-08。`.system` に imagegen / openai-docs / plugin-creator / skill-creator / skill-installer、`.curated` に hatch-pet、playwright、figma 系などが入っている — [openai/skills](https://github.com/openai/skills)（gh api、2026-10-16 時点）
- 【旧・2026-05】**hatch-pet**（openai/skills curated）: Codex のペット用スプライトアトラスを作るスキル。2026-05-01 に追加され、2026-05-12 にワークフローが置き換えられた。行ごとに画像を作ってフレームを抜き出し、9行×8列のアトラスに合成する。見た目は画像生成が担い、セル配置・透明化・検証はスクリプトが担う — [openai/skills commits](https://github.com/openai/skills); [gihyo.jp 2026-05](https://gihyo.jp/article/2026/05/hatch-codex-pets)。セルは192x208とする資料もあるが【未検証】 — [mcpservers.org](https://mcpservers.org/agent-skills/agentspace-so/codex-pet)
- 【9-10月】**0x0funky/agent-sprite-forge**: ★4,467。作成は 2026-04-23、最終 push は 2026-10-06。**v0.4.0 "the big upgrade"（#17）は 2026-10-06**。中身は次のとおり。
  - 承認した master 静止画1枚から、アクションごとに image-to-video のクリップを作り、Python でゲート判定・キー抜き・位置合わせ・ループ化・タイミング調整・仕上げを行う。
  - 生成の呼び先は `route_media.py` が決める。まず API（OpenAI / Gemini / xAI / BytePlus / fal.ai）、次にログイン済みの Codex か Grok の CLI、最後の手段としてコードで描いたアート。
  - 仕上げは HD が既定。pixel 仕上げにすると32色以下・2値アルファになる。
  - 出力は PNG アトラス、透明 PNG フレーム、GIF、Godot SpriteFrames (.tres)、Aseprite JSON、Tiled / Godot 4.3+ / LDtk のマップ。ただし 0.4.0 で出力した Godot・LDtk・Aseprite 形式を各エディタで読み込めるかは、作者も「未検証」としている。
  - 10-06 のコミットに "Codex edit run folder on Windows" がある。
  — [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge)（README と gh api のコミット履歴）
- 【9-10月】**aldegad/sprite-gen**: ★2,833。作成は 2026-05-12、最終 push は 2026-10-15。Codex と Claude の両方で使えるスキル兼 Python CLI。2つのパイプラインがある。
  - A「atlas rows」: ベース画像1枚から行ごとに生成し、クロマ背景を本物のアルファに変換する（"unmix"）。フレームを抜き出し、`sprite-sheet-alpha.png` と `manifest.json.frame_layout` を出力する。
  - B「video → loop」: Grok Imagine で静止画を動かし、透明なループ GIF / WebP にする。
  - ほかに比較・却下・微調整用の curation webview、`slice-sheet`、`recolor`、Aseprite / Phaser / Flame 向けの書き出しがある。
  - 2026-10-15 には Windows のテスト修正（#103）、play mode（loop / once-return / once-hold）の追加、`prepare --request` が style を保持するよう直す修正が入った。READMEには日本語版もある。
  — [sprite-gen](https://github.com/aldegad/sprite-gen)
- 【旧・2026-05】**tachikomared/character-animation-creator-skill**: ★350。最終 push は 2026-05-08。Codex と GPT Web Agent 向けのスキルで、64x64セル・8方向のドット絵キャラ用スプライトシートを作り、掃除と検証のスクリプトが付く。画像を作るのは外部（Codex の `$imagegen` など） — [GitHub](https://github.com/tachikomared/character-animation-creator-skill); [sourcepulse](https://www.sourcepulse.org/projects/32289298)
- 【日付未検証】そのほかの候補: jwynia/agent-skills `godot-asset-generator`（Godot 4.x のインポート設定まで書き出す）、wuyoscar/GPT-Image2-Skill（ドット絵のプロンプト集あり）、Godot 4.2 用プラグイン「Sprite Pipeline」（OpenAI の自前キーを使い、JSON のキューで一括生成） — [skills.sh](https://www.skills.sh/jwynia/agent-skills/godot-asset-generator); [GPT-Image2-Skill](https://github.com/wuyoscar/GPT-Image2-Skill/blob/main/skills/gpt-image/references/gallery-pixel-art.md); [Godot Asset Library](https://godotengine.org/asset-library/asset/4764)

### Inferences
- 9〜10月の主流は「画像モデルにシートを丸ごと描かせる」方式から、「画像モデルでキャラの元絵（master）を固め、動きは動画モデル（Grok Imagine など）に任せ、切り出しと正規化はコードでやる」方式へ移っている。プロジェクトの generate.py（JSON 仕様 → Codex 画像生成）は、このうち「master 静止画」と「背景・アイコン」を作る段に当たる。
- sprite-gen の `manifest.json.frame_layout`（フレームの絶対座標）は、エンジン側でグリッドを推測しなくて済む設計で、まねする価値がある。

### Gaps
- star 数は 2026-10-16 時点の gh api の値。インストール数や実際の利用者数は分からない。
- 9〜10月に公開された新しい Codex 公式スキル（ゲーム向け）は見つからなかった。

## Q3. gpt-image で一貫性を保つためのベストプラクティス

### Takeaway
報告されている手法は5つにまとまる。(1) 参照画像1枚と構造化プロンプトで、グリッド（4x4 = 16コマ など）を指定して1枚に描かせる。(2) 承認済みの master や参照画像を「固定参照」にして、前のフレームから次を作る連鎖はしない。(3) ポーズとデザインの役割を分けて指示する。(4) 1K で下書きしてから高解像度で作り直す。(5) 後処理でグリッドを推定し、1ドット=1px に正規化し、色数を絞り、アルファを掃除する。

### Cited Findings
- 【9-10月・2026-09-10】参照画像1枚から4x4 = 16コマの戦闘スプライトシートを作る手順。プロンプトは3つのブロックでできている。(a) キャラの特徴（髪型・服・色・武器・頭身）を全フレームで固定するブロック。(b) 攻撃の設計（武器に合った攻撃、分からない能力を勝手に足さない）のブロック。(c) 「構え→予備動作→攻撃→インパクト→エフェクト消失→戻り」の流れと、16コマ目を構えにつなげる指定のブロック — [tau-home.com](https://tau-home.com/en/post/gpt-image-2-5-character-to-16-frame-pixel-art-combat-sprite-sheet/)
- 【日付未記載】GPT Image 2.5 はグリッドを保ち、セルをそろえ、同じ被写体を少しずつ変えて繰り返すのが得意。対策として次が挙がっている。1K で配置とポーズを確認してから 4K で作り直す。コマ撮り風のアニメは前フレームを連鎖させず固定参照から作る。出力はアニメーターが手を入れる前の静的な下書きとして扱う。ただしこの記事の発行元は GPT Image 2.5 の利用権を売っている会社 — [VidCella](https://vidcella.ai/posts/gpt-image-2-5-sprite-sheets)
- 【旧・2026-07-14、最終更新 2026-09-08】Qiita @archeleeds による ComfyUI × 動画生成AI × Codex のパイプライン。
  - Codex は `codex exec` を子プロセスとして呼び、ドット絵への変換を担当する（サブスクのログインで動くのでAPIキー不要。seed がないので毎回結果が変わる）。
  - フレームごとのデザインの揺れには、承認済みのドット絵を参照画像として渡し、「ポーズは画像B、デザインは画像Aに従え」と役割を分けて指示することで、ポーズの写り込みを抑えた。
  - ドット化の正規化手順: エッジ強度の自己相関でグリッドの間隔を推定（放物線補間でサブピクセル精度）→ 境界ヒストグラムで位相を推定 → 各セル中心を nearest でサンプリングして1ドット=1pxにする。
  - 透過: 画像の縁につながった背景色の領域だけを抜き、1px 膨張させて外周の残りを消す。
  - 位置合わせ: bbox の高さ比と中心で機械的に補正する。
  — [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)
- 【旧・2026-05-27】AICU の記事。参照画像を Codex アプリに添付し、ImageGen で歩行シートを作る。仕様は 1024x1024、256x256 セル、行が上下左右の向き、列が静止＋歩行3コマ、RGBA PNG。四隅のアルファを確認し、ずれは Python / Pillow で直す。通常の生成はAPIキー不要だが、大量生成や API / CLI 経由では `OPENAI_API_KEY` と API 料金がかかる — [AICU](https://corp.aicu.ai/ja/codex-20260527); [note英語版](https://note.com/aicu/n/ne7f684ee7d41?hl=en)
- 【9-10月・2026-10-06】agent-sprite-forge v0.4 の一貫性対策。
  - モーションのプロンプトごとに、キャラの特徴の要約（"identity recap"）を毎回入れる。
  - "One body scale per character from the master"（キャラの体の大きさは master で1つに決める）。
  - 動画モデルは速く動く手足で色がずれる（"drift colours on fast limbs"）ので、カラーロックで master の色に戻す。
  - キーの抜き方はキャラごとに1つのプロファイル（soft matte）に固定する。
  - "numeric QA never approves anatomy or motion by itself"（数値チェックだけで体の形や動きを合格にしない）。最後はコンタクトシートを目で見て判断する。
  — [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge)
- 【9-10月・2026-10-15】sprite-gen の考え方。画像モデルに「スプライトシート」を頼むと、フレームごとに顔が変わる、背景が抜けない、グリッドからずれる、と指摘している。そのため1行ずつ生成し、キャラの特徴を固定し、クロマを unmix してアルファにし、フレームの座標をマニフェストで渡す。向きは `--facing right|left` で指示するが「保証はできない」と明記している — [sprite-gen README](https://github.com/aldegad/sprite-gen)
- アセット同士のスタイルをそろえるには、共通のスタイル定義文（"style bible"）を使う。スプライト・背景・UI の解像度がばらばらだとエンジン内で縮尺が合わない、という指摘もある — [Converge guide](https://combos.converge.ai/page/en-US/blog/gpt-image-2-game-development); [SeaGames](https://www.seagames.com/blog/gpt-image-2-game-assets-seagames)（SeaGames はモデルIDの記述に誤りがあり、信頼性は低い）

### Inferences
- 戦闘背景・マップ・アイコンは1枚ずつで完結するので、「共通の style bible ＋ 固定の解像度 ＋ `background: transparent`（アイコン）」を JSON 仕様に入れるだけで一貫性はかなり上がると見込める。
- キャラのアニメーションは、「1枚のシートに描かせて slice する」方式と「master＋動画モデル」方式の二択になりつつある。ドット絵にするなら、どちらでも Qiita の方式のようなグリッド推定と nearest サンプリングによる正規化が要る。

### Gaps
- パレット固定（決まったパレットへの量子化）を gpt-image 側でやる公式な方法は見つからなかった。後処理での減色が一般的（agent-sprite-forge は32色以下）。

## Q4. 報告されている弱点と回避策

### Takeaway
主な弱点は、歩行・走りのサイクル、フレーム間のずれ（グリッドの1〜2pxずれ、衣装や身長の揺れ）、出力がピクセルパーフェクトでないこと、透明背景が出ないことがあること、seed がなく再現できないこと。回避策は後処理のコードと人の目による選別。

### Cited Findings
- 歩行・走りのサイクルは難しい（"Walk animations remain difficult"）。歩幅や衣装がフレーム間でずれる。小物を持つ手もまだ不安定 — [VidCella](https://vidcella.ai/posts/gpt-image-2-5-sprite-sheets)
- 【2026-09-10】シート全体を1回で描くので、セルの境界が1〜2pxずれ、端の欠けや揺れの原因になる。Aseprite や Unity Sprite Editor の均等自動スライスに頼らず、境界を手で確認し、フレームごとにピボットを中央に置くよう勧めている。長く残るエフェクトは戻りのコマで途切れるため、パーティクルは4コマ以内に収める。Web / API の出力でも白や灰色の背景になることが多い — [tau-home.com](https://tau-home.com/en/post/gpt-image-2-5-character-to-16-frame-pixel-art-combat-sprite-sheet/)
- 【最終更新 2026-09-08】正規化した後もモーションごとにキャラの身長が ±12〜19% 揺れ、整数倍でない拡大縮小はドットの格子を壊すので未解決のまま。グリッド間隔の推定が倍の周期を拾う誤りは、最小ラグの局所ピークを優先して回避した。`codex exec` は stdin がパイプだと止まるので、プロンプトを `-` で渡してすぐ閉じる。生成が再抽選で失われる問題には、入力ハッシュによる永続キャッシュで対処した — [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)
- 生成AIの出力は1ドット=1pxにならないので、ドット絵には正規化が必要 — [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)
- コスト: Codex 組み込みの生成はサブスクのレート制限を消費し、API や CLI 経由の大量生成は API 料金がかかる — [AICU](https://corp.aicu.ai/ja/codex-20260527); [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)。第三者の再販価格（1枚 1K=5、2K=15、4K=24 クレジット）しか見つからず、OpenAI の公式単価は確認できていない — [VidCella](https://vidcella.ai/posts/gpt-image-2-5-sprite-sheets)
- 【2026-10-06】動画経由の方式にも弱点がある。動画モデルは速く動く手足で色がずれる。agent-sprite-forge は CHANGELOG と検証記録に、実際に動かした2回目（Aria, fox2）の弱点を記録している — [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge)
- sprite-gen は、向きの自動判定が高い確信度でも外れることがあると書いており、既定では判定結果を記録するだけにしている（`--facing-fix none`） — [sprite-gen](https://github.com/aldegad/sprite-gen)

### Inferences
- Windows 環境では、`codex exec` の stdin の扱い（Qiita）と、sprite-gen / agent-sprite-forge の Windows 修正（10月）が関係してくる。

### Gaps
- 2.5 系でフレーム間のずれがどれくらい改善したかを数値で比べた資料は見つからなかった（OpenAI はベンチマークを出していない、と VidCella は書いている）。

## Q5. 2026年9〜10月の、Codex からゲームアセットまでの通しパイプライン事例（Godot / Unity）

### Takeaway
9〜10月で日付が確かめられた通し事例は3つ。agent-sprite-forge v0.4（10/06、Godot 書き出しあり）、sprite-gen の更新（10/15）、tau-home の16コマ戦闘シート記事（9/10）。Qiita の Unity 向けパイプラインは9/08に更新されている（初出は7月）。note.com・Zenn・X・Reddit で9〜10月のものは確認しきれなかった。

### Cited Findings
- 【2026-10-06】agent-sprite-forge v0.4 は、Godot 4 のタワーディフェンス試作と編集できる TileMap の RPG マップを紹介し、Godot SpriteFrames (.tres) と Godot 4.3+ のマップを書き出す。Unity は書き出し先ではなく、Unity WebGL の作品紹介だけ — [agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge)
- 【旧・初出2026-07-14／更新09-08】Qiita: ComfyUI（SDXL＋キャラLoRA＋depth ControlNet）→ Wan2.2 I2V-A14B で49フレームの動画を作り8〜12フレームを選ぶ → `codex exec` でドット化 → グリッド推定で正規化 → Unity（SpriteAtlas、ピボット整列、PPU 補正） — [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)
- 【2026-09-10】GPT Image 2.5 による4x4シート → GIF / Aseprite / Unity Sprite Editor でのスライスの注意点 — [tau-home.com](https://tau-home.com/en/post/gpt-image-2-5-character-to-16-frame-pixel-art-combat-sprite-sheet/)
- 【日付未検証】X: Renoise が「GPT-Image 2.5 でどんなキャラも 4×4 シートから GIF にできる」とプロンプト付きで投稿（2.5 の公開後なので9月以降と思われる） — [X @renoiseai](https://x.com/renoiseai/status/2097999579618889812)
- 【日付未検証】Indie Hackers の記事 "GPT Image 2.5: A Full Sprite Sheet From One Reference"（403で本文を取得できず） — [Indie Hackers](https://www.indiehackers.com/post/gpt-image-2-5-a-full-sprite-sheet-from-one-reference-110562d19f)
- 【日付未検証】Contra: Godot を使ったことがない作者が、ChatGPT で作った参照画像からスプライトシートを作り、Codex で Godot の試作を約1時間で作った — [Contra](https://contra.com/community/JQGhJ8JA-create-prototypes-quickly-in-godot-with)
- 【旧・2026-05】Sorceress のブログ: ブラウザ上の AI パイプラインで Godot 4.6 へ。ヒーロー画像は GPT Image 2 製 — [Sorceress](https://sorceress.games/blog/how-to-make-a-2d-game-in-godot-browser-ai-pipeline)

### Inferences
- Godot に通しで持っていく既製品としては、10月時点で agent-sprite-forge（.tres 出力）が最も近い。ただしエディタでの読み込みは作者も未検証としているので、取り入れる前に小さく試すべき。

### Gaps
- note.com、Zenn、YouTube、Reddit（r/aigamedev など）の9〜10月の投稿は、今回の検索では日付付きで見つけられなかった。X の投稿日も確かめられていない。
