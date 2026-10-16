# 現在のアートアセット制作パイプライン（openslaythe / Petal Fallout）

調査対象: `D:/develop/openslaythe`（読み取りのみ。出典はリポジトリ相対パスと行番号。`~/.codex` は `C:/Users/waros/.codex`）
調査日: 2026-10-16

---

## Q1. Codex の呼び出し方・プロンプト構造・出力先・後処理・時間とコスト

### Takeaway
「設計書（brief.md）を Codex に渡して manifest JSON（style + assets[]）を書かせる → `generate.py` が 1 アセット 1 回 `codex exec` を起動し `$imagegen` で raw PNG を作る → Pillow で透過トリム／クロマキー／シート分割／縮小して所定パスへ保存」という 2 段構成。参照画像は一切使わず、テキストのみで生成している。1 枚ずつの API 課金ではなく Codex の組み込み画像ツールを使うため、リポジトリ内に料金の記録はない。

### Cited Findings
**呼び出し（CLI・フラグ・モデル）**
- Codex 本体は環境変数 `CODEX_BIN`、無ければ `%LOCALAPPDATA%\OpenAI\Codex\bin\*\codex.exe` のうち最新のものを使う — tools/codex_art/generate.py:30-36
- 実行コマンドは `codex exec -C tools/codex_art/raw -s workspace-write --skip-git-repo-check --ephemeral -`。プロンプトは stdin から渡し、タイムアウトは 900 秒 — tools/codex_art/generate.py:53-61
- 成否は `raw/<id>.png` があるかどうかだけで判定する。失敗すると stdout の末尾 1500 文字を表示する — tools/codex_art/generate.py:62-65
- 失敗時のリトライは 1 回だけ（`generate_raw(...) or generate_raw(...)`）。生成と後処理は `ThreadPoolExecutor` で並列に走り、既定は 4 workers — tools/codex_art/generate.py:280, 295-296
- CLI オプションは `--only`（id の前方一致、カンマ区切り）、`--force`、`--post-only`、`--workers`、`--manifest` — tools/codex_art/generate.py:7-11, 276-281
- PLAN と README にも同じ手順が書かれている（`codex exec` + `$imagegen`、生成物は `~/.codex/generated_images/` に出るので指定パスへコピーさせる）。README の実行例は `--workers 5` — docs/PLAN.md:8-15, README.md:29-35
- モデル: Codex の設定は `model = "gpt-6-astra"`、`model_reasoning_effort = "high"`。これはエージェント側のモデルで、画像生成モデルは設定ファイルに書かれていない — ~/.codex/config.toml:1-2
- `$imagegen` は Codex のシステムスキルで、既定では組み込みの `image_gen` ツールを使い、`OPENAI_API_KEY` は不要。CLI フォールバックは `scripts/image_gen.py`（generate/edit/generate-batch）。スキルは参照画像を使った生成と既存画像の編集（edit）にも対応している — ~/.codex/skills/.system/imagegen/SKILL.md（"Top-level modes and rules"、"Decision tree" の節）
- スキル側には `scripts/remove_chroma_key.py` が同梱されている — ~/.codex/skills/.system/imagegen/scripts/

**プロンプトと仕様の構造**
- 最終プロンプトは `"$imagegen Generate exactly one image..." + "Art direction:\n{style}" + "Subject:\n{prompt}" + 背景指示（transparent なら「完全透過」、そうでなければ「端まで塗りつぶす」）+ 「文字・透かし・UI 枠なし」+ 保存ファイル名の指定` で組み立てる — tools/codex_art/generate.py:39-50
- manifest は `{"style": 全体共通スタイル, "assets": [{id, out, size, transparent, category, brief, prompt, オプション...}]}` の形 — tools/codex_art/assets.json:2, tools/codex_art/design_brief.md:66-71
- 技術仕様（id/out/size/transparent/anchor）は `build_slots.py` がゲームデータ（`autoload/GlobalProdDataGenerator.gd`）を正規表現で読み取って `slots.json` を作る。デザイン（prompt）は Codex が書く、という分担 — tools/codex_art/build_slots.py:1-21, 97
- slots の内訳: カード絵 192×192（不透過）、カード枠 288×368、エネルギーアイコン 128、マップ背景 1200×700、マップノード 128、戦闘背景とタイトル 1200×700、主人公 256、敵 160（ボス 300、ミニボス 220、enemy_4 は 200）、インテント 128、状態異常 96、レリック／消耗品／HUD 128、宝箱／店 256 — tools/codex_art/build_slots.py:31-95
- デザインの依頼は 3 本の brief で行った（全体のアートディレクション design_brief、主人公のドット絵版 character_brief、主人公の手描き版 hero_painted_brief）。どれも「設計ファイルを書くだけで画像生成はしない」「id/out/size などのメタデータは変えない」と指示している — tools/codex_art/design_brief.md:1-58, tools/codex_art/character_brief.md:1-39, tools/codex_art/hero_painted_brief.md:1-35
- スプライトシートの prompt には決まり文句を必ず入れる（"exactly N frames in a single horizontal row, equal-width cells, the SAME character at the SAME size and the SAME ground line..., nothing crosses a cell border..."）— tools/codex_art/hero_painted_brief.md:24-25, tools/codex_art/character_brief.md:34-35
- キャラの同一性はテキストだけで保っている。brief は各 prompt の冒頭に外見をフルに書くよう求め、hero_painted_assets.json の 6 件すべてが同じ長い外見記述（約 1,000 字）で始まる — tools/codex_art/hero_painted_brief.md:26, tools/codex_art/hero_painted_assets.json:16
- manifest は 5 種類あり、style もそれぞれ違う。assets.json（142 件、手描きガッシュ調）、character_assets.json（4 件、ドット絵・11 色限定）、hero_painted_assets.json（6 件、手描きアニメセル調）、map_assets.json（10 件、セピア単色インク）、event_assets.json（10 件、絵本風の挿絵）— 各ファイルの :2 行目（style）、件数はスクリプトで集計
- assets.json のカテゴリ別件数: icon 74、card_art 34、vfx 12、combatant 10、card_frame 7、background 4、map 1 — tools/codex_art/assets.json（集計）

**出力先**
- raw は `tools/codex_art/raw/<id>.png`（gitignore 対象）、完成品は manifest の `out`（`external/sprites/...` または `sprites/...`）— tools/codex_art/generate.py:26, 218-219; .gitignore 末尾（`tools/codex_art/raw/`）
- raw は現在 182 枚。サイズは 1254×1254 が中心（RGBA 85、RGB 44）。ほかに 1024×1536（カード枠など）、2172×724 前後（4 コマのシート）、1672×941（タイトル）など。ただし bg_act_1〜3 の raw は 1200×700、vfx_fireball/petal/thorn の raw は 256×256 で、Codex 側でリサイズして保存したらしい — tools/codex_art/raw/（PIL で集計）

**後処理（Pillow）**
- `chroma_key`: 指定色との RGB 距離が tol=90 未満なら透明、90〜180 なら線形に半透明。カード枠 7 枚で `#FF00FF` を使用 — tools/codex_art/generate.py:68-80, tools/codex_art/assets.json:5-17
- `clear_window`: シード点から flood fill し、暗くて不透明な縁に当たるまで透明にする（カード枠の絵の窓を抜く）— tools/codex_art/generate.py:83-101
- `seamless_y`: 下端 20% の帯を上端へクロスフェードし、縦にタイルできるようにする（羊皮紙）— tools/codex_art/generate.py:104-113, tools/codex_art/map_assets.json（map_parchment）
- `fit: stretch`: 不透明部分の bbox で切り抜いてから枠いっぱいに引き伸ばす — tools/codex_art/generate.py:226-235
- `sheet: N`: 横一列のシートを等幅で N 分割する → `clean_cell` で、左端に接する成分（前のコマのはみ出し）、右端に接する小さな成分、最大成分の 1% 未満のゴミを消す → 足元（下 25%）の中心で左右をそろえる → 全コマ同じ高さで下端をそろえる → 本体の高さの中央値が `h*0.82` になる共通スケールで `place` → `<out>_1.png ...` に保存 — tools/codex_art/generate.py:131-198, 236-249
- `pixel: N`: NEAREST で 1/N に縮小 → アルファを 60 で 2 値化 → Max/Min フィルタで穴を埋める → NEAREST で拡大（ドット絵化）— tools/codex_art/generate.py:207-214
- 透過アセットは trim → pad 4% → 縮小して中央（または下端）に配置。不透過アセットは中央クロップしてから LANCZOS でリサイズ — tools/codex_art/generate.py:250-267
- パレット量子化（指定色への減色）はしていない。`pixelate` もサンプリングと 2 値化だけ — tools/codex_art/generate.py:207-214

**時間とコスト**
- ~/.codex/generated_images の画像ファイルを時刻別に数えると、2026-09-25 の 07 時台に 158 枚、10 時台に 26 枚、11 時台に 6 枚 — ~/.codex/generated_images（find で集計）
- コミット時刻では、設計 brief（07:03）→ 最初のアート統合（07:12）→ 全 146 アセット完了（07:39）— git log 39fc8af, 0b703b2, af77582
- 10 時台の 26 枚は hero2（6）+ map（10）+ event（10）の件数と一致し、11 時台の 6 枚は主人公の再生成（671fab6）の件数と一致する — git show 367147a/fa6c02e/671fab6, tools/codex_art/*.json（件数）

### Inferences
- 07 時台の 158 枚がほぼ全アセット分（142 + 旧枠など）にあたるので、ゲーム全体のアートを約 30 分前後（4〜5 並列）で一巡できたと推定する。手描き主人公 6 枚の作り直しも、prompt 修正を含めて約 12 分（10:56→11:08 のコミット間隔）。
- 生成画像の数とアセット数がほぼ一致することから、「何枚も生成して良いものを選ぶ」という選別はしておらず、1 枚生成してそのまま採用する運用と推測する。ただし `--force` の上書きで消えた試行は数えられない。
- 費用は Codex の組み込み image_gen（サブスクリプション枠）で払われていると推測される。1 枚あたりの金額はリポジトリから判断できない。

### Gaps
- 実際の画像生成モデル名（gpt-image 系のどれか）、1 枚あたりの生成秒数、料金はリポジトリにも config にも記録がない。
- brief.md を Codex に渡したときのコマンド（design_brief → assets.json を書かせた手順）はスクリプト化されておらず、どう実行したかの記録もない（PLAN.md:14 に「Codex に書かせる」とあるだけ）。

---

## Q2. アートスタイル規則（解像度・パレット・アニメーション一覧）

### Takeaway
画面は 1200×700 固定。手描きガッシュ調・太い手描き輪郭・二段階セル陰影・左上光源、という全体ルールと 12 色のパレットが docs/art_direction.md に決まっている。主人公 Vera のアニメーションは idle 4 / attack 4（設計書）に加えて、手描き版で hurt 3 / block 3 が足された。ただし文書の一部が古いまま残っている。

### Cited Findings
- タイトルは「Petal Fallout」、テーマは原子炉温室 × 園芸ロボット — docs/art_direction.md:1-11
- パレット 12 色: インクティール #142C30、工場ティール #315558、陶器クリーム #F3E8CF、銅 #B8754E、ミント #83C9A0、ライム #B8E986、シアン #72D9DD、ピーチ #F4AD91、コーラル #FF8068、アンバー #FFD178、プラム #78516B、発光アイボリー #FFE9BA — docs/art_direction.md:15-30
- 線と塗りのルール: 外周の線は内側の線の約 1.5 倍の太さ。192px のカード絵なら外周 4〜6px、96px のアイコンは 8px 以上。光源は左上、紙の粒子はアイコン／UI／VFX には載せない — docs/art_direction.md:34-38
- カード絵は 192×192 で不透過、96px に縮めても読めること。カード枠は 288×368 で、絵窓 x17〜83% / y6〜59%、文字面 y61〜98% — docs/art_direction.md:42-50
- 戦闘背景は 1200×700。プレイヤー域 x=140〜480、敵域 x=650〜1100、下 30% は手札で隠れる — docs/art_direction.md:65-73
- 戦闘スプライトは透過・全身・影なし、足裏は高さの約 94%、余白 6%、主人公は右向き、敵は左向き — docs/art_direction.md:81
- 確認サイズは状態アイコン 24px、意図アイコンとマップノード 32px、カード 96px — docs/art_direction.md:99, 125
- VFX テクスチャは 12 枚、すべて 256×256 の単体静止画。加算合成するものは芯が明るく外へ向かって透明 — docs/art_direction.md:111
- 主人公 Vera の 11 色パレットとドット絵規則（1px 輪郭、アンチエイリアスなし）— docs/character_design.md:21-37
- アニメーション設計: idle 4 コマ（各 200ms のループ）、attack 4 コマ（90/110/70/130ms、1 回再生して待機に戻る）— docs/character_design.md:39-59
- 手描き版では hurt（3 コマ: のけぞり→最大のひるみ→立て直し）と block（3 コマ: 六角シールド展開→踏ん張り→戻り）を追加 — tools/codex_art/hero_painted_brief.md:150-154
- 変更履歴: 2026-09-25 に背中の鉢原子炉を削除 — docs/character_design.md:67-68

### Inferences
- 文書が古いまま残っている。character_design.md の本文は今も「背中の小型鉢原子炉」「背中の芽」と書いており（docs/character_design.md:17, 63）、ドット絵規則も残っている（:37）。art_direction.md の主人公記述も旧 The Botanist（白衣・ゴーグル）のまま（docs/art_direction.md:79）。最新の正しい定義は hero_painted_assets.json の prompt にしかない（tools/codex_art/hero_painted_assets.json:16 の "She carries NOTHING on her back"）。
- 設計上のフレーム時間（attack が 90/110/70/130ms）は実装では使われておらず、固定 fps で再生されている（Q3 を参照）。

### Gaps
- 敵のアニメーション（攻撃・被弾・死亡）の設計は、どの文書にも書かれていない。

---

## Q3. Godot への組み込み（パス・形式・サイズ・コマ数）

### Takeaway
`external/sprites/` 以下は Godot のインポートを通さず（`external/.gdignore`）、実行時に `Image.load_from_file` で読み込む「命名規約で自動差し替え」方式。`sprites/` 以下は通常のインポート（.import）で `load()` する。主人公はフレームごとの連番 PNG を `AnimationData` に登録して `SpriteFrames` にし、敵は 1 枚の静止画だけで動きは Tween で付けている。

### Cited Findings
- `external/` には空の `.gdignore` があり、Godot のインポート対象外（external/sprites 以下には .import ファイルが 0 個、sprites/ 以下には全 PNG に .import がある）— external/.gdignore、ファイル一覧の集計
- `FileLoader.load_texture` は `Image.load_from_file` → `ImageTexture.create_from_image` で読み込んでキャッシュする。デバッグ時は `res://`、エクスポート版では実行ファイルのあるディレクトリを起点にする — autoload/FileLoader.gd:16, 66-74, 82-83, 133-155
- `ArtOverrides.apply()` はデータ生成の後に呼ばれ、規約どおりのパスに画像があれば差し替える。カード `external/sprites/cards/<color>/<id>.png`、状態異常、レリック `external/sprites/artifacts/<id>.png`、消耗品、Act 背景 `external/sprites/backgrounds/<act_id>.png`、キャラアイコン、敵 — scripts/ArtOverrides.gd:1-39, autoload/Global.gd:189
- 主人公のアニメーション: `hero_idle_%d.png` / `hero_attack_%d.png` / `hero_hurt_%d.png` / `hero_block_%d.png` を 1 番から、存在する分だけ読み込む。idle 5fps（ループ）、attack 12fps（終わると idle へ）、hurt/block 8fps（終わると idle へ）、death は idle の 1 コマ目を流用 — scripts/ArtOverrides.gd:14-16, 42-69
- `AnimationData.add_animation` はテクスチャのパス配列から `SpriteFrames` を作る。`animation_frame_durations`（コマごとの時間）は `regenerate_animations` でしか使われず、`add_animation` の経路では無視される — data/readonly/AnimationData.gd:58-80, 104-133
- `add_animation` のループ判定は `if animation_next_animation_name == animation_next_animation_name:` で、常に true になる（自分自身と比較している）— data/readonly/AnimationData.gd:76-77
- ただし `ArtOverrides.apply()` の後で `FileLoader.generate_all_animations()` が全 AnimationData の `regenerate_animations()` を呼ぶ。ここでは正しい判定（`animation_name == animation_next_animation_name`）でループが設定し直され、`animation_fps` も読まれるので、上の判定ミスは実際には表に出ない — autoload/Global.gd:189, 201; autoload/FileLoader.gd:159-163; data/readonly/AnimationData.gd:104-133
- `get_animation_sprite_frames()` は `AnimationData.animations`（SpriteFrames）を返す — scripts/combatants/BaseCombatant.gd:104-108
- `fit_sprite_to_feet()` は 1 コマ目の画像サイズをもとに offset を `SPRITE_FEET_Y(68) - size.y/2` に設定する。つまり画像の下端を足元とみなす。クリック判定は幅 `max(size.x*0.7, 96)`、高さ `size.y*0.9`。ダメージ数字の位置もここで決まる。最後に呼吸の Tween（振幅 3px、1.2 秒）を始める — scripts/combatants/BaseCombatant.gd:47-89
- Player は SpriteFrames を設定し、明るい縁取りシェーダーを付けて idle を再生し、`fit_sprite_to_feet` を呼ぶ。被弾で `play_reaction(HURT)`、Block 獲得で `play_reaction(BLOCK)` — scripts/combatants/Player.gd:25-35, 93, 117
- 縁取りシェーダーは上下左右 4 方向を `width=2.0` テクセルずつサンプリングし、クリーム色（0.95,0.9,0.75,0.9）の縁を付ける — sprites/shaders/outline.gdshader
- 敵は `enemy_texture_path` が差し替わると、`add_combatant_animations([1 枚])` で idle/attack/death すべてが同じ 1 枚になる — scripts/ArtOverrides.gd:34-38, data/readonly/AnimationData.gd:85-88
- 敵の元データは旧素材 `enemy_red_small.png` などを指しており、差し替えで初めて Codex 製のアートになる — autoload/GlobalProdDataGenerator.gd:2019, 2035, 2046, 2070
- 主人公の元データ（差し替え前）は `character_green.png` 1 枚を idle/attack/death に使う — autoload/GlobalProdDataGenerator.gd:1709-1716
- `res://sprites/` の読み込み: カード枠 `res://sprites/ui/card_frame_%s.png`（color_type 別、無ければ green にフォールバック）、マップの背景／羊皮紙／ボス紋章／ノード、HUD アイコン、タイトル背景、ヒーローのバストアップ、VFX の `res://sprites/vfx/vfx.json` — scripts/ui/card/CardFrames.gd:6-27, scripts/ui/Map.gd:14-19, 106-157, scripts/ui/UiSkin.gd:6-16, 92-93, autoload/Vfx.gd:7
- 羊皮紙は `TextureRect.STRETCH_TILE` で縦に並べる — scripts/ui/Map.gd:111-119
- イベント画像は `external/sprites/events/%s.png`（512×512）を `load()` で読み込む — scripts/content/EventContent.gd:6, 246-252
- タイトルのバストアップ（512×512）は 580×580 に拡大し、`TEXTURE_FILTER_NEAREST` で表示している（コメントは「ドット絵」のまま）— scripts/ui/UiSkin.gd:75-89
- 主人公スプライトの NEAREST フィルタは、手描き版に切り替えたときに Player.gd からは削除された — git show 367147a -- scripts/combatants/Player.gd
- インポート設定はロスレス（compress/mode=0）、ミップマップなし、fix_alpha_border=true — sprites/ui/hero_bust.png.import
- レンダラーは gl_compatibility、ビューポートは 1200×700 固定 — project.godot:53-55, 78-80
- 画面確認用に、Godot の `--write-movie` で数十フレームを撮影する `tools/shot.ps1` がある（`--auto=combat` などの DevAutoPilot と組み合わせて使う）— tools/shot.ps1:1-10

### Inferences
- 主人公は 300×300 の連番 PNG、1 アニメーションあたり 3〜4 コマ、という形式が前提になっている。コマ数を増やす（6〜8 コマ）こと自体は `_frame_paths` が連番を自動検出するのでコードの変更なしでできる。ただしフレームごとの時間を指定する経路は使われていない。
- タイトルのバストアップに NEAREST が残っているのは、ドット絵版の名残（scripts/ui/UiSkin.gd:82）。512 を 580 に拡大しているので、ギザギザが出る可能性がある。
- `fit_sprite_to_feet` は 1 コマ目の画像サイズしか見ないので、アニメーションごとにキャンバスサイズが違うと足元がずれる。今は generate.py が全コマを同じ w×h に配置しているので問題は出ていない。
- 敵には攻撃・被弾のフレームアニメーションがなく、AnimationPlayer と Tween だけで動きを付けている。

### Gaps
- 敵の攻撃演出に使っている AnimationPlayer トラックの中身（"Player/attack" など）は今回詳しく見ていない。

---

## Q4. git 履歴に見える繰り返し作業とペインポイント

### Takeaway
2026-09-25 の約 4.5 時間に、アートは「全量生成 → カード枠の作り直し → 主人公をドット絵で作成 → 手描きで作り直し → 背中の装備を削除して再生成」と 3 回方向転換した。そのたびに generate.py に後処理の関数を足して対応している（クロマキー＋窓抜き、シートの分割と掃除、中央値スケール、縦シームレス）。

### Cited Findings
- 06:40 にベースを Slay-The-Robot（MIT）へ切り替え → 07:03 に design_brief と slots → 07:12 に Codex がアートディレクションと assets.json を書き、最初のアートを統合 → 07:39 に全 146 アセットが完了 — git log（6d4cb0c, 39fc8af, 0b703b2, d83b6c1, eac5faf, af77582）
- 07:43（2a2495d）「Readable card redesign」: カード枠を色 × 種別ごとに作り直し、クロマキーと flood fill で絵窓を抜く処理を追加。generate.py に +48 行 — git show 2a2495d --stat
- 08:52（b970156）: generate.py に `--manifest`、足元揃えのシート分割、ドット絵の量子化を追加 — git show b970156
- 09:01（fa4bc41）: ドット絵の主人公 Vera を作成。「cleaned (bleed/speck removal, hole fill, pixel quantize)」、generate.py +55 行。タイトル背景も旧主人公を消すために再生成 — git show fa4bc41
- 10:20（367147a）: 「Drop pixel art; Codex re-drew Vera in the game's painted style」。hurt/block を追加。「Sprite sheet cleanup: remove neighbor fragments, median-height scaling」。`clean_cell` に右端の破片除去、`body_height` で中央値スケール、`seamless_y` を追加 — git show 367147a -- tools/codex_art/generate.py
- 10:25（dfc3cfd）: マップの開始地点アイコンを追加し、map_assets.json を 133 行書き換え — git show dfc3cfd --stat
- 10:56（fa6c02e）: イベント挿絵 10 枚（event_assets.json）— git show fa6c02e
- 11:08（671fab6）: 「Hero: remove the potted sprout reactor from her back. Prompts now state nothing is carried on her back; all hero sheets, icon and title bust regenerated」。prompt の小さな変更 1 つのために 14 フレーム＋アイコン＋バストを全部作り直した — git show 671fab6 --stat
- 手描き主人公のフレームを並べて見ると（external/sprites/characters/character_green/hero_*_*.png を合成した画像を目視）、シートごとに剣のデザインが違う。idle は細身で、attack/hurt は幅広のクリーム色の刃、block は別の刃。装甲の装飾もシートごとに違う — external/sprites/characters/character_green/（目視）
- 各フレームの不透明部分の bbox: idle は x=59〜261、hurt は x=13〜258（左に約 45px ずれている）、attack_4 は x=64〜286。足元は全コマ y=287〜288 でそろっている — PIL で計測
- attack_3 の斬撃の弧は右端 x≈270 で縦にまっすぐ切れて見える（セル境界でクロップされた跡と思われる）— hero_attack_3.png（目視、bbox 29〜270）

### Inferences
- 一番の痛みは、キャラの一貫性がテキストの prompt だけに頼っていること。シートは別々の生成なので、剣や装飾が毎回少しずつ変わる。参照画像（idle 1 コマ目やキャラシート）を渡すしくみがない（generate.py:39-50 にその機能はない）。
- 2 番目は、シートの切り分けとそろえ方がヒューリスティックなこと。等幅分割と連結成分の除去に頼っているため、セルをまたいだエフェクトは切れる。左右位置を足元の中心でそろえるので、アニメーションを切り替えたときに体が横に跳ぶ（hurt で約 45px）。
- 3 番目は、作り直しの単位が「シートまるごと」なこと。小さな修正でもすべて作り直すので、部分修正（edit／inpaint）の経路がない。
- 4 番目は、品質チェックが人の目と `tools/shot.ps1` のスクリーンショットだけなこと。自動の検査（パレットからの逸脱、余白、bbox の跳び、キャラの類似度）がない。

### Gaps
- 生成に失敗した回数（`[NG]` ログ）や、選別で捨てた画像は記録されていないので、失敗率はわからない。

---

## Q5. アセット在庫（数・サイズ・プレースホルダー）

### Takeaway
Codex 製は約 150 枚が組み込み済み。主人公だけが 4 アニメーション 14 フレームを持ち、敵 9 体は静止画 1 枚ずつ。ベースプロジェクト由来の小さな（64/96px）旧素材が、他の色のキャラ・カード・敵・アイコンにまだ大量に残っている。

### Cited Findings（PIL とファイル一覧での集計）
- 主人公（character_green）: hero_idle 4、hero_attack 4、hero_hurt 3、hero_block 3（すべて 300×300 RGBA）、アイコン 128×128、旧 `character_green.png` 256×256（The Botanist の Codex 版で、今は差し替えられている）— external/sprites/characters/character_green/
- タイトル用バスト: sprites/ui/hero_bust.png（512×512）
- 敵: Codex 製 9 枚（enemy_1〜4、minion_1〜2 は 160px、enemy_4 は 200、miniboss 2 体は 220、boss は 300）と、旧素材 15 枚（enemy_{blue,green,purple,red,yellow}_{small,medium,large}、64/96/128px）— external/sprites/enemies/
- 戦闘背景 3 枚（1200×700、act_1〜3）、タイトル背景とマップ背景（sprites/ui、1200×700）— external/sprites/backgrounds/, sprites/ui/
- マップ: ノードアイコン 7 枚（128）、開始地点（160）、ボス紋章（512）、羊皮紙タイル（888）— sprites/map/
- カード絵: green 33 枚（192）＋ white 1 枚（192）が Codex 製。旧素材は card_green/card_white（96）と blue/orange/red 各 3 枚（96）— external/sprites/cards/
- カード枠 7 枚（288×368）、HUD アイコン 9 枚、chest と shop（256）— sprites/ui/
- インテント 5 枚（128）— sprites/intents/
- 状態異常: Codex 製 26 枚（96）、旧素材 5 枚（64）— external/sprites/status_effects/
- レリック: Codex 製 25 枚（128）、旧素材 7 枚（artifact_{color}.png、64）— external/sprites/artifacts/
- 消耗品: Codex 製 4 枚（128）、旧素材 7 枚（64）— external/sprites/consumables/
- エネルギーアイコン: Codex 製 green/white（128）、旧素材 5 色（64）— external/sprites/colors/
- イベント挿絵: Codex 製 10 枚（512）、旧素材 3 枚（96: gain_items/modify_card/pick_something）— external/sprites/events/
- VFX テクスチャ 12 枚（256）と vfx.json — sprites/vfx/
- 旧素材のインパクトアニメーション 14 フレーム（128、OpenGameArt sinestesiastudio）、カードデコレーター 7 枚（24）— external/sprites/animated_effects/impact_default/, external/sprites/card_decorators/, README.md:47
- manifest 間の対応: slots.json は 134 件、assets.json は 142 件。旧 frame_attack/power/skill と map_* 7 件は assets.json から消え、map_assets.json の mapicon_* に置き換わった。VFX 12 件と color 別の枠 6 件が追加された — tools/codex_art/slots.json, assets.json（id を比較して集計）

### Inferences
- プレースホルダーと言えるもの: 青・橙・赤のキャラ／カード／敵 15 体と、色別の汎用アイコン類（64/96px の旧素材）。実際に遊べるのは green キャラだけなので、表に出る影響は限られる。
- 不足しているもの: 敵のアニメーション（攻撃・被弾・死亡）、主人公の death（今は idle 1 コマ目で代用）、Act 2/3 の敵、カードを増やしたときの絵（ビルド軸を増やした 35f58d0 以降に足したカードの絵があるかどうかは未確認）。

### Gaps
- 最新コミット 35f58d0（Physical / Reactor のビルド軸）で増えたカードやレリックに、絵が揃っているかどうかは照合していない。

---

## Q6. ツールで改善できそうなボトルネック

### Takeaway
効果が大きい順に、(1) キャラ一貫性（参照画像 / edit を使った生成）、(2) シートの切り分けと位置合わせ（セル単位の生成、または定点の基準線・ピボットを機械で検証）、(3) パレットと解像度の自動検査、(4) 文書の正本の一元化、(5) Godot 側のフレーム時間と死亡・敵アニメーションの受け口。既存の命名規約（ArtOverrides）と manifest の形を保てば、ゲーム側を壊さずに差し替えられる。

### Cited Findings
- 参照画像なしの text-to-image を 1 アセット 1 回 — tools/codex_art/generate.py:39-61
- imagegen スキル自体は参照画像による生成と edit に対応している — ~/.codex/skills/.system/imagegen/SKILL.md（"Decision tree"）
- シート処理は等幅分割、連結成分の除去、足元中心での整列 — tools/codex_art/generate.py:131-198
- 減色・パレット検査はない（pixelate は 2 値化のみ）— tools/codex_art/generate.py:207-214
- 差し替えは「ファイルがあれば使う」だけなので、ファイル名と連番さえ守ればコードの変更は不要 — scripts/ArtOverrides.gd:62-77
- フレーム時間の配列は `regenerate_animations` にしか効かない — data/readonly/AnimationData.gd:58-80, 112-125
- 正本が分散している（character_design.md は古く、prompt 側が最新）— docs/character_design.md:17, 63, 67-68; tools/codex_art/hero_painted_assets.json:16

### Inferences
1. **一貫性**: キャラの基準画像（ターンアラウンド / idle 1 コマ目）を固定し、各シートを「参照画像あり」か「edit」で作る経路を generate.py に足すと、剣や装飾のぶれ（Q4）が減る見込み。671fab6 のような小さな修正も、作り直しではなく部分編集で済む。
2. **切り分け**: 1 セルずつ生成するか、セル境界に余白を持たせた生成をしてから、bbox の跳び（hurt で約 45px）と弧の切れを自動で検出する。左右の基準を「足元の中心」ではなく「アニメーション全体で共通の固定ピボット」にする必要がある。
3. **ピクセルとパレットの掃除**: 12 色パレットへの最近傍減色（任意）、アルファ縁のハロー除去、縁取りシェーダー（2px）と合わせたときの縁の確認を自動化する。
4. **Godot への取り込み**: `add_animation` が `_animation_data` に `animation_frame_durations` を入れるようにすれば、起動時の `regenerate_animations` がそれを読むので、設計書の 90/110/70/130ms を再現できる（今は全コマ 1.0 倍）。`add_animation` のループ判定ミスは regenerate で上書きされるので実害はないが、直しておくと安全。UiSkin の NEAREST も見直す。
5. **QA**: `tools/shot.ps1` の自動撮影と、実寸に縮めた比較シート（24/32/96px）の自動生成を組み合わせ、生成後の目視の手間を減らす。

### Gaps
- ゲームを実際に動かしての確認（ループの挙動、NEAREST 表示のギザギザ）はしていない。コードを読んだだけ。
- 画像生成 1 枚あたりの所要時間と料金がわからないので、「生成枚数を増やして選別する」方式の費用対効果は見積もれない。
