# AI 補助の 2D ドット絵アセット制作 OSS とパイプライン（2026年10月16日 調査）

調査日: 2026-10-16。GitHub の数値（★、最終 push 日、ライセンス）は `gh api repos/...` で、Hugging Face の数値は `huggingface.co/api/models/...` で、どちらも調査日に取得した。「直近（2026-09〜10）」は 2026-09-01 以降に作られた、または更新されたものを指す。日付を確かめられなかったものには「未検証」と書いた。ゲーム本体のリポジトリは MIT。

---

## Q1. 後処理 OSS：AI の「なんちゃってドット絵」を本当のグリッドに揃えるもの、背景除去、アップスケール。2026年10月時点で保守されていて最良なのはどれか

### Takeaway
グリッド復元は MIT のツールが十分そろっていて、どれもモデル不要で CPU で動く。保守されていて実績のある中心は **Retro-Diffusion/pixel-art-fixer**、**Hugo-Dz/spritefusion-pixel-snapper**（★3.3k）、**KennethJAllen/proper-pixel-art**（10/10 更新）、**jenissimo/unfake.js**（9/29 更新）の4本。9月には新顔の **Real-PixelArt**（9/16 作成）も出た。背景除去は **rembg（MIT）＋ BiRefNet（MIT）** を使う。**BRIA RMBG-2.0 は CC BY-NC 4.0 で非商用**なので避ける。

### Cited Findings
**グリッド復元・減色（ドット絵の後処理）**
- **Retro-Diffusion/pixel-art-fixer**: 作成 2026-07-13、最終 push 2026-07-15、★468、MIT。README は「偽ドット絵をグリッドの揃った本物のドット絵に変換する。画像処理のみでモデル不要」と説明する。格子が整数でない（例: 6.38px）、格子がずれている、アンチエイリアスや JPEG の劣化がある、といった問題を扱う。README によると、既存の「pixel snapper」系は**内容の周期をピクセルの周期と取り違えたり、1オクターブ（2倍または1/2）ずれたりする**ので、複数の手がかりを組み合わせているという。ブラウザ版は無料。 — [GitHub](https://github.com/Retro-Diffusion/pixel-art-fixer)
  - 同じ組織が復元精度のベンチマーク **Retro-Diffusion/pixel-bench** も公開している（2026-07-15、MIT、★39）。 — [GitHub](https://github.com/Retro-Diffusion/pixel-bench)
  - 補足: 「最先端」という言い方は作者（商用の Retro Diffusion）自身の主張で、第三者が比べたものは見つからなかった。
- **Hugo-Dz/spritefusion-pixel-snapper**（Sprite Fusion Pixel Snapper）: ★3,282、MIT、最終 push 2026-07-16。不揃いなピクセルサイズ、格子からのずれ、中間色の混入、アンチエイリアスを直す。GIGAZINE が 2026-05-16 に紹介した。 — [GitHub](https://github.com/Hugo-Dz/spritefusion-pixel-snapper) / [GIGAZINE](https://gigazine.net/gsc_news/en/20260516-spritefusion-pixel-snapper)
  - 「パレットが16色までなので色が落ちることがある」というレビューがある。 — [korben.info](https://korben.info/en/pixel-snapper-fix-ai-pixel-art.html)
  - CLI 版と WASM 版があるという第三者の記事がある（未検証）。 — [brightcoding](https://converter.brightcoding.dev/blog/stop-wasting-hours-fixing-ai-pixel-art-use-pixel-snapper-instead)
- **KennethJAllen/proper-pixel-art**: ★576、MIT、**最終 push 2026-10-10**。エッジ検出と Hough 変換でグリッド線を見つけ、減色してから各セルの支配色を取る。CLI は `uv run ppa -i input -o output -c num_colors -s result_scale` で、既定は16色。 — [GitHub](https://github.com/KennethJAllen/proper-pixel-art) / [sourcepulse](https://www.sourcepulse.org/projects/13911015)
- **jenissimo/unfake.js**: ★931、MIT、**最終 push 2026-09-29**。ブラウザで動く JS ライブラリで、色のにじみ、曲がった線、揃っていないグリッドを直す。itch.io のデモ「Unfaker」は入力幅が560pxまで。GIGAZINE が 2025-12-02 に紹介した。 — [GitHub](https://github.com/jenissimo/unfake.js) / [GIGAZINE](https://gigazine.net/gsc_news/en/20251202-unfaker-fix-ai-pixel-art)
  - Python への移植 **painebenjamin/unfake.py**（★63、MIT、最終 push 2026-07-30、PyPI `unfake`、Rust で高速化）。 — [PyPI](https://pypi.org/project/unfake/) / [GitHub](https://github.com/painebenjamin/unfake.py)
- **giventofly/pixelit**: ★1,773、MIT、最終 push 2026-05-09。写真や絵をドット絵風にするブラウザ用ライブラリ（以前からある）。 — [GitHub](https://github.com/giventofly/pixelit)
- **Astropulse/pixeldetector**: ★368、MIT、**最終 push 2024-04-04**（Retro Diffusion の作者による古い検出器で、更新は止まっている）。 — [GitHub](https://github.com/Astropulse/pixeldetector)
- **dimtoneff/ComfyUI-PixelArt-Detector**: ★449、MIT、最終 push 2025-10-31。 — [GitHub](https://github.com/dimtoneff/ComfyUI-PixelArt-Detector)

**直近（2026-09〜10）に出たグリッド復元系**
- **Bocchi-The-Glock/Real-PixelArt**: **作成 2026-09-16**、最終 push 2026-10-09、★132、MIT。AI の「偽ドット絵」を低解像度の本物のドット絵に戻す。Web 版、Windows/Mac のデスクトップ版、Python CLI があり、依存は NumPy と Pillow だけ。FFT の周期とエッジ間隔から候補を出し、半分と2倍の間隔も比べてから位相を探す。出力サイズを指定する `--target-size 128x96`、減色の `--colors`、半透明を2値化するオプションがある。 — [GitHub](https://github.com/Bocchi-The-Glock/Real-PixelArt)
- **unclepomedev/ComfyUI-ProperPixelArt**: 作成 2026-10-04、MIT。proper-pixel-art を ComfyUI のノードにした非公式ラッパーで、動画と GIF にも対応する。 — [GitHub](https://github.com/unclepomedev/ComfyUI-ProperPixelArt)
- **PeaarLi/ComfyUI-PixelPipeline**: 作成 2026-09-28、★2、ライセンス未表記（NOASSERTION）。グリッド復元（静止画と動画）、パレットの抽出と適用、背景除去、スプライトシート詰めの7ノード。k-means のシードを固定しているので結果が毎回同じになる。対応できない入力では処理を止めて失敗を返す。 — [GitHub](https://github.com/PeaarLi/ComfyUI-PixelPipeline)
- **UnlimitedEditing/ComfyUI-SpriteSheetPack**: 作成 2026-09-23、ライセンス未表記。入力スプライトのグリッドを戻して整数倍の参照画像を作り、画像モデルで描かせた最大15ビューをグリッドに戻す。そのうえで**全フレームを入力スプライトの共通パレットに固定**してシートにまとめる。 — [GitHub](https://github.com/UnlimitedEditing/ComfyUI-SpriteSheetPack)

**背景除去**
- **danielgatis/rembg**: ★25,093、MIT、**最終 push 2026-10-10**。 — [GitHub](https://github.com/danielgatis/rembg)
- **ZhengPeng7/BiRefNet**: ★4,289、MIT、**最終 push 2026-10-11**。HF モデルも MIT（ダウンロード約76.7万）。 — [GitHub](https://github.com/ZhengPeng7/BiRefNet) / [HF](https://huggingface.co/ZhengPeng7/BiRefNet)
- **PramaLLC/BEN2**: MIT（HF 最終更新 2025-12-31）。 — [HF](https://huggingface.co/PramaLLC/BEN2)
- **briaai/RMBG-2.0**: **CC BY-NC 4.0 で非商用のみ**。「商用利用は BRIA との商用契約が必要」と明記されている。 — [HF](https://huggingface.co/briaai/RMBG-2.0)
- Qwen-Image-2.1 は**透過 PNG（RGBA）を直接生成・編集**でき、写真から被写体を切り出すこともできる（ただし Q3 のとおり非商用ライセンス）。 — [HF](https://huggingface.co/Qwen/Qwen-Image-2.1)

**アップスケーラー**
- **xinntao/Real-ESRGAN**: ★37k、BSD-3、**最終 push 2024-08-06** で、更新は止まっている。 — [GitHub](https://github.com/xinntao/Real-ESRGAN)

### Inferences
- **Codex で生成する場合の推奨順**: ①グリッド復元（pixel-art-fixer か proper-pixel-art。比べるなら Real-PixelArt も）→ ②共通パレットに固定（全フレーム同じパレット）→ ③アルファの2値化と、四辺につながった背景の除去。背景を単色（#00FF00 など）で描かせれば色キーで抜けるので、rembg/BiRefNet が要らない場面も多い。
- どの手法も「2倍か1/2倍か」を取り違えることがある。そのため、出力サイズ（例: 64×64）を固定できるツール（Real-PixelArt の `--target-size`、ComfyUI-SpriteSheetPack の整数倍の参照画像）のほうがアニメのフレーム間で安定しやすい。
- ドット絵の拡大は最近傍補間で足りるので、Real-ESRGAN のような AI アップスケーラーはほぼ不要。使うのは、ドット絵にする前のイラストを拡大したいときくらい。
- 商用の MIT ゲームに入れる素材なら、RMBG-2.0 は使わず BiRefNet か BEN2（MIT）を選ぶ。

### Gaps
- pixel-art-fixer、Pixel Snapper、proper-pixel-art、unfake、Real-PixelArt を第三者が同じ条件で比べたものは見つからなかった（pixel-bench は作者側のベンチマーク）。
- Pixel Snapper の16色上限が今も残っているかは、リポジトリで確かめていない（未検証）。

---

## Q2. アニメーション OSS：フレーム間でキャラを一貫させる方法（ComfyUI、動画モデル→コマ抽出→ドット化、spritesheet LoRA、多視点）と、RTX 5070 Ti 16GB（Blackwell）で動くか

### Takeaway
2026年の主流は**「1枚絵 → I2V 動画モデルで動かす → コマを抜く → 背景を抜く → 全フレームを同じグリッドと同じパレットで復元 → シート化」**で、AnimateDiff 世代の手法はほぼ使われていない。動画モデルは **Wan2.2（Apache-2.0）** と **MiniMax H3（2026-08-03 に重み公開、独自ライセンスで、ローカル生成物の商用利用には別ライセンスが要る）** が中心。9〜10月にはこの流れを丸ごと自動化する OSS が何本も出た。

### Cited Findings
**動画モデル**
- **Wan2.2**: GitHub ★17,954、Apache-2.0、最終 push 2026-09-21。HF の I2V-A14B と TI2V-5B はどちらも Apache-2.0。 — [GitHub](https://github.com/Wan-Video/Wan2.2) / [HF I2V-A14B](https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B)
  - **styly-agents/Wan2-2-pixel-animate**: Wan2.2 I2V 14B 用の LoRA（2025-12-10、Apache-2.0）。226本のドット絵スプライトアニメで学習しており、静止画からドット絵アニメを作る。4ステップの蒸留 LoRA と併用することが推奨されている。 — [HF](https://huggingface.co/styly-agents/Wan2-2-pixel-animate)
- **MiniMax H3**: 2026-08-03 に重みが公開され、同じ日に ComfyUI が対応した。公開されたのは FL2VA（最初と最後のフレーム → 動画＋音声）と Ref2VA の2チェックポイント。 — [comfyui-wiki](https://comfyui-wiki.com/en/news/2026-08-03-minimax-h3-open-weights-comfyui)
  - ライセンスは **minimax-h3-community-license-agreement**。Comfy-Org の再配布版（HF）の最終更新は 2026-09-29。int8_convrot や fp8_scaled の量子化版がある。 — [HF Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3)
  - Comfy 公式ガイドによると、**ローカルで生成したものを商用利用するには MiniMax の商用ライセンスが必要**。 — [docs.comfy.org](https://docs.comfy.org/tutorials/video/minimax/minimax-h3)
  - 米国・EU・英国・韓国では使えないように読める、という RunPod ブログの指摘がある（情報源は1つだけなので未検証）。 — [RunPod](https://www.runpod.io/blog/minimax-h3-the-open-weight-omni-modal-video-model-and-what-it-takes-to-run-it)
- **LTX-2**: v1.4.2（2026-10-02）。ライセンスは **ltx-2-community-license-agreement**（独自）。 — [GitHub](https://github.com/Lightricks/LTX-2) / [HF](https://huggingface.co/Lightricks/LTX-2)

**直近（2026-09〜10）に出た「動画→スプライトシート」系 OSS**
- **isabellagreco1997/ai-sprite-animator**（作成 2026-09-15、MIT）: AI 動画のドット絵キャラをスプライトシートにする。手順は、グリーンバックで生成 → 背景色・影・ずれ・歩行周期・実際のグリッドを採点 → 色キー → セルサイズを比較 → Retro Diffusion の pixel-art-fixer でフレームごとに復元 → シート、タイミング JSON、GIF を出力。**足元を基準にグリッドの位相をそろえる処理**を既定で入れ、フレームごとの上下のガタつきを抑えている。AGENTS.md/CLAUDE.md があり、Codex や Claude Code から実行できる。README には「目や口がフレーム間で1px動くことがあるので、完成品ではなく出発点」と書かれている。 — [GitHub](https://github.com/isabellagreco1997/ai-sprite-animator)
- **camenduru/TostAI-Sprite-Sheet-Studio**（作成 2026-09-26、★76、ライセンス未表記）: 動画を VRMBG-3.0 で切り抜き、自動クロップしてグリッドのシート、JSON、GIF にする。エディタ（ピボット合わせ、マットの修正、再グリッド、再タイミング）付き。Docker で動き、VRAM 4GB 以上。 — [GitHub](https://github.com/camenduru/TostAI-Sprite-Sheet-Studio)
- **MANFRI-DEV/sprite-sheep**（作成 2026-09-02、MIT、pre-alpha 0.0.4）: スプライト1枚とプロンプトから、ローカルの動画拡散（ComfyUI バックエンド、MiniMax H3 と Wan2.2）で5×5の25フレームのシートを作る。itch.io に Windows 版がある。 — [GitHub](https://github.com/MANFRI-DEV/sprite-sheep)
- **aowind/sprite-action-forge**（作成 2026-10-07、ライセンス未表記）: 立ち絵1枚から動作スプライトのセットを作る（ComfyUI＋MiniMax H3）。README の実測では **RTX 3070 Ti 8GB で 448×448、39フレーム、Turbo 8ステップが約25秒、VRAM ピーク 7.5GB**。 — [GitHub](https://github.com/aowind/sprite-action-forge)
- **envy-ai/sprite-generator**（作成 2026-09-19、**AGPL-3.0**）: 参照画像から4方向の idle/走り/歩き/ジャンプ/しゃがみを作る。ComfyUI のワークフローで動画を生成し、SDPose と背景除去を通してシートにする。 — [GitHub](https://github.com/envy-ai/sprite-generator)
- **MakabakaGuo/video-frame-animator**（作成 2026-10-04、MIT）: 動画からコマを抜き、AI で切り抜き、**Godot 4 の SpriteFrames として書き出す**デスクトップツール。 — [GitHub](https://github.com/MakabakaGuo/video-frame-animator)
- **miles990/video-gif-studio**（作成 2026-09-09、MIT）: **Codex 用のスキル**。キャラ画像は GPT-Image 系で作り、動きは Grok か fal の MiniMax H3 Max で付け、背景除去とフレーム処理を経て GIF/APNG/スプライトにする。 — [GitHub](https://github.com/miles990/video-gif-studio)
- **tomiya7688/comfyUI_support_tools Issue #382**（2026-10-11）: 4/8方向のスプライト列を作るノードの**提案段階**で、まだ実装されていない。 — [GitHub Issue](https://github.com/tomiya7688/comfyUI_support_tools/issues/382)

**それ以前のパイプライン例**
- **mor-o/comfyui-2d-character-pipeline**（★106、MIT、最終 push 2026-06-20）: 等サイズセルの idle/歩行の横長ストリップと、着せ替え用のレイヤーを出力する。 — [GitHub](https://github.com/mor-o/comfyui-2d-character-pipeline)
- Qiita「ComfyUI × 動画生成AI × Codex で…」（2026-07-14 投稿、09-08 更新）: キャラシート → SDXL LoRA（kohya_ss）→ depth ControlNet でポーズ → **Wan2.2 I2V-A14B で49フレーム** → 人が8〜12フレームを選ぶ → **Codex の画像生成でドット化** → 透過、1:1正規化、クロップ。後処理では、エッジの自己相関でドットのピッチを推定し、エッジのヒストグラムで位相を求め、セル中心を最近傍で取る。高さ比で拡大し、bbox の中心で位置を合わせる。 — [Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)
- steven2711/pixel-sprite-lab（SD1.5＋OpenPose＋IP-Adapter → 24×32、16色）は検索には出たが、**gh api では 404**（削除または改名、未検証）。 — [検索結果のURL](https://github.com/steven2711/pixel-sprite-lab)

**spritesheet LoRA と多視点**
- **svntax-dev/pixel_spritesheet_4walk_small_lora_v1**: FLUX.2-klein-base-4B 用（Apache-2.0、2026-02〜03）。32×32キャラの上下左右歩行、ジャンプ、倒れなどのフレームを作る。 — [HF](https://huggingface.co/svntax-dev/pixel_spritesheet_4walk_small_lora_v1)
- **xocialize/spritesheet-FLUX.2-klein-4B-lora**（2026-07-14、Apache-2.0）: 物体1枚から4アングルの2×2シートを作る編集 LoRA（fal の LoRA のミラー）。 — [HF](https://huggingface.co/xocialize/spritesheet-FLUX.2-klein-4B-lora)

**RTX 5070 Ti（Blackwell）について**
- RTX 50 系には CUDA 12.8 以上と最新の PyTorch が必要。SageAttention はビルドに失敗することがあるという注意がある（ガイド自身が「要検証」と書いている）。 — [Wonderful Launcher GPU 互換](https://wonderfullauncher.com/docs/gpu-compatibility)
- MiniMax H3 の ComfyUI 再配布版は、**cu130 の PyTorch が使えれば int8_convrot を推奨し、使えなければ fp8_scaled** としている。 — [HF Comfy-Org/MiniMax-H3](https://huggingface.co/Comfy-Org/MiniMax-H3)
- 5070 Ti（torch 2.10.0+cu128）で1回の生成に約75秒かかり、4060 8GB とほぼ同じだったという報告が1件ある（構成の問題と思われ、統制された比較ではない）。 — [Reddit スナップショット](https://reddit.sentinel-team.org/posts/1tf753j/snapshots/2026-05-22T22%3A42%3A24.48386Z)

### Inferences
- 8GB の 3070 Ti で H3 Turbo が動いた実測があるので、**16GB の 5070 Ti なら MiniMax H3（int8/fp8）も Wan2.2 I2V 14B（fp8 か GGUF、オフロードあり）も動く可能性は高い**。ただし 5070 Ti での実測は見つからなかった。
- **ライセンス面では Wan2.2（Apache-2.0）が最も安全**。MiniMax H3 は、ローカルで作ったものでも商用には別ライセンスが要るので、MIT の商用ゲームでは避けるか、ライセンスを取ってから使う。
- フレーム間の一貫性で特に効くのは、①**全フレームを同じセルサイズと同じパレットで復元すること**、②**足元を基準にグリッドの位相を固定すること**（ai-sprite-animator）、③グリーンバックで生成すること。目や口の1pxの揺れは残るので、最後は Aseprite で手直しする前提にする。
- Codex の画像生成だけで多フレームを作るより、**Codex でキーフレームを1枚作る → Wan2.2 I2V で動かす → グリッド復元**のほうが動きは滑らかになる。一方で Qiita の例のように、Codex をドット化の工程に使う混合型もある。

### Gaps
- RTX 5070 Ti での Wan2.2 や H3 の生成時間と VRAM の実測は見つからなかった。
- Hunyuan 系の動画モデルについての直近の情報は今回集められなかった。
- r/StableDiffusion、r/aigamedev、HN の9〜10月のスレッドは、検索で直接取れなかった。

---

## Q3. 2026年にローカルでドット絵に向く画像モデルとライセンス

### Takeaway
商用で安全に使える（Apache-2.0）のは **FLUX.2 klein 4B**、**Qwen-Image-2512 / Qwen-Image-Edit-2511 / Qwen-Image-Layered**、**Wan2.2**。注目の新モデル **Qwen-Image-2.1**（HF 作成 2026-09-14、9月20日ごろ公開と報道、RGBA ネイティブ）は **qwen-research ライセンスで非商用**。FLUX.2 klein 9B と FLUX.1 Kontext dev も非商用。

### Cited Findings
- **Qwen/Qwen-Image-2.1**: HF 作成 2026-09-14、最終更新 2026-09-30、いいね 3,321、**license: qwen-research**。視覚生成部は 7B。T2I と編集を1つのモデルで行い、**RGBA の透過画像を生成・編集**でき、参照画像は最大10枚。 — [HF](https://huggingface.co/Qwen/Qwen-Image-2.1)
  - 報道では公開日は 2026-09-20。非商用で、商用はメールで別途ライセンスを申請する。Qwen-Image 1.0、Edit、Layered、2512 は Apache-2.0 だったので、ライセンス面では後退した。 — [datanorth](https://datanorth.ai/news/qwen-releases-qwen-image-2-1) / [latenode](https://latenode.com/ai-trends/qwen-image-2-1-commercial-licence)
  - ComfyUI-SpriteSheetPack と ComfyUI-PixelPipeline（どちらも9月作成）は Qwen-Image-2.1 を前提にしている。 — [SpriteSheetPack](https://github.com/UnlimitedEditing/ComfyUI-SpriteSheetPack) / [PixelPipeline](https://github.com/PeaarLi/ComfyUI-PixelPipeline)
- **Qwen/Qwen-Image-Edit-2511**（2025-12-17、Apache-2.0）、**Qwen-Image-2512**（2025-12-30、Apache-2.0）、**Qwen-Image-Layered**（2025-12-17、Apache-2.0）。 — [HF Edit-2511](https://huggingface.co/Qwen/Qwen-Image-Edit-2511) / [HF 2512](https://huggingface.co/Qwen/Qwen-Image-2512) / [HF Layered](https://huggingface.co/Qwen/Qwen-Image-Layered)
  - Qwen-Image-Edit と Lightning LoRA（4ステップ）で写真をドット絵にする検証記事がある。 — [lilting.ch](https://lilting.ch/en/articles/qwen-image-edit-pixel-art-conversion)
  - ドット絵 LoRA **artificialguybr/PIXELART-REDMOND-QWENIMAGE**（ベースは Qwen-Image-2512、Apache-2.0、2026-07 更新）。 — [HF](https://huggingface.co/artificialguybr/PIXELART-REDMOND-QWENIMAGE)
- **FLUX.2 klein 4B**: Apache-2.0（2026-01-14）。**klein 9B**: flux-non-commercial-license。 — [HF 4B](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B) / [HF 9B](https://huggingface.co/black-forest-labs/FLUX.2-klein-9B)
  - 9B の出力は商用利用できるが、モデルを商用で提供するには有料ライセンスが要る、という第三者の解釈がある（未検証）。 — [invideo](https://invideo.io/blog/flux-ai-image-generator/)
- **FLUX.1 Kontext dev**: flux-1-dev-non-commercial-license。 — [HF](https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev)
- **SDXL の定番ドット絵 LoRA nerijs/pixel-art-xl**: creativeml-openrail-m（2023年）。 — [HF](https://huggingface.co/nerijs/pixel-art-xl)
- **Retro Diffusion**: GitHub で公開しているのは pixel-art-fixer、pixel-bench、API のサンプル、**ホスト型の MCP サーバー**（retro-diffusion-mcp、2026-07 作成、MIT）で、**生成モデルの重みは公開されていない**（組織のリポジトリ一覧で確認）。 — [GitHub retro-diffusion-mcp](https://github.com/Retro-Diffusion/retro-diffusion-mcp) / [api-examples](https://github.com/Retro-Diffusion/api-examples)

### Inferences
- MIT の商用ゲームに使うなら、**Codex（メイン）＋ローカルの補助に FLUX.2 klein 4B（spritesheet LoRA あり）か Qwen-Image-Edit-2511** が無難。Qwen-Image-2.1 の RGBA 生成は魅力的だが、非商用なので製品素材には使えない。
- HF の新規ドット絵モデルは9〜10月にもいくつか出ているが（例: Krea-2-PixelArt-16x16、2026-10-15、ダウンロード0）、どれも実績がほぼない。

### Gaps
- HiDream の直近の状況とライセンスは今回確認していない。
- Retro Diffusion の旧ローカル版（Aseprite 拡張）のモデルが今も配布されているかは未検証。

---

## Q4. スプライトシートのツール：Aseprite CLI/Lua、LibreSprite、Pixelorama、パッカー、Godot SpriteFrames（.tres）の出力

### Takeaway
エディタは **Aseprite v1.3.18.6（9/22）**、**Pixelorama v1.2.3（9/15、MIT）**、**LibreSprite v1.3（10/2、約1年半ぶりの新版、GPL-2.0）** と、3つとも9〜10月に新版が出ている。9月には **AI エージェントから Aseprite を操作する MCP/CLI** が2本出たことが目立つ。Godot 連携は **godot-aseprite-wizard（MIT）** が定番。

### Cited Findings
- **aseprite/aseprite**: ★40,142、最新 v1.3.18.6（2026-09-22）。GitHub API ではライセンスが空（OSI ライセンスではなく EULA。条文は未確認）。 — [GitHub](https://github.com/aseprite/aseprite)
- **Orama-Interactive/Pixelorama**（Godot 製）: ★10,551、MIT、v1.2.3（2026-09-15）、v1.2.2（09-09）。 — [GitHub](https://github.com/Orama-Interactive/Pixelorama)
- **LibreSprite/LibreSprite**: ★8,578、GPL-2.0、**v1.3（2026-10-02）**。その前の v1.2 は 2025-03-02。 — [GitHub](https://github.com/LibreSprite/LibreSprite)
- **viniciusgerevini/godot-aseprite-wizard**: ★1,385、MIT、最終 push 2026-08-17。 — [GitHub](https://github.com/viniciusgerevini/godot-aseprite-wizard)

**直近（2026-09〜10）の AI エージェント × Aseprite**
- **with-pebbly/aseprite-ai-artist**（作成 2026-09-08、★348、MIT）: Aseprite の拡張と MCP サーバーで、開いている Aseprite のドキュメントにエージェントが1ピクセルずつ描く。各手順は Ctrl+Z で戻せる。Claude Code、Codex CLI、Gemini CLI、Cursor などに対応し、`npx @pebbly/aseprite-ai-artist install codex` で入る。Aseprite 1.3 以上、Node 22.6 以上が必要。 — [GitHub](https://github.com/with-pebbly/aseprite-ai-artist)
- **aigengame/aseprite-automation（SPA）**（作成 2026-09-10、最終 push 10-15、MIT）: CLI、Agent Skill、MCP の3通りで、Aseprite のレイヤー、フレーム、タグ、タイミングを操作し、検証して書き出す。外部 PNG にパレット、透過、サイズ、アンカーを揃えてから取り込める。PyPI は `aseprite-automation`、Python 3.13 以上。 — [GitHub](https://github.com/aigengame/aseprite-automation)

**Godot SpriteFrames 生成（2026年の新しいもの、どれも小規模）**
- **Minato-chen/godot-spriteframes-batch-importer**（2026-08-30、MIT）: ルールに従ってシートから名前付きの SpriteFrames を一括生成する。 — [GitHub](https://github.com/Minato-chen/godot-spriteframes-batch-importer)
- **spritesheetbuilder/sprite-atlas-importer**（2026-09-26、MIT）: Phaser/TexturePacker の JSON、Unity の .frames.json、Sparrow XML を SpriteFrames にする。 — [GitHub](https://github.com/spritesheetbuilder/sprite-atlas-importer)
- **DRS90/dot-aseprite-importer**（2026-09-17、MIT）: 3×3 の方向グリッドで描いた .aseprite を SpriteFrames にする。 — [GitHub](https://github.com/DRS90/dot-aseprite-importer)
- **RogerRandomDev/GodotAPNGParser**（2026-09-08、MIT）: APNG を SpriteFrames にする。 — [GitHub](https://github.com/RogerRandomDev/GodotAPNGParser)
- **EliteMasterEric/Godot-SpriteFrameBuddy**（2026-07-21、MIT）。 — [GitHub](https://github.com/EliteMasterEric/Godot-SpriteFrameBuddy)

**パッカー**
- **Mike-Leone/Sprite-Sheet-Packer**（2026-09-29、GPL-3.0）: オフラインで切り分けと詰め込みを行う。 — [GitHub](https://github.com/Mike-Leone/Sprite-Sheet-Packer)
- **taho140303/crop-asset-desktop**（2026-10-13、MIT）: AI が作ったシートを切ってアニメにする。 — [GitHub](https://github.com/taho140303/crop-asset-desktop)
- free-tex-packer は `free-tex-packer/free-tex-packer-core` の名前では gh api が 404 だった（正しいリポジトリ名は未確認）。

### Inferences
- Aseprite の CLI（`--batch`、`--sheet`、`--data` で JSON アトラスを出す）と Lua スクリプトは定番だが、今回はドキュメントを取得していないので、使う前に公式 CLI ドキュメントを確認すること（未検証）。
- このプロジェクトの規模なら、**Python（Pillow）で「フレーム PNG → 等間隔シート＋Godot の SpriteFrames .tres」を自作するのが最も単純**（KISS）。既製品を使うなら、エディタで直したいときは godot-aseprite-wizard、JSON アトラスからなら sprite-atlas-importer。
- 9月に作られた Godot 用プラグインはどれも★0〜4なので、依存させるより処理の参考にとどめたほうが安全。
- ツールとして使うぶんには、LibreSprite（GPL）も envy-ai/sprite-generator（AGPL）も出力物に影響しない。ただし MIT のリポジトリにソースを取り込むのは避ける。

### Gaps
- Aseprite CLI/Lua の最新 API（v1.3.18 系）の変更点は未取得。
- ライセンス未表記（NOASSERTION/none）のリポジトリ（TostAI、PixelPipeline、SpriteSheetPack、sprite-action-forge）は、コードを流用する権利がはっきりしない。

---

## Q5. 2026年9〜10月の注目の新リポジトリと記事（まとめ）

### Takeaway
9〜10月の流れは3つ。①**AI エージェント（Codex、Claude Code）から操作するドット絵ツール**（Aseprite MCP、Codex スキル、AGENTS.md 付きのパイプライン）が急に増えた。②**動画モデル → スプライトシート**の自動化。③**Qwen-Image-2.1 前提の ComfyUI ノード**。どれも★が少なく新しいので、成熟度は低い。

### Cited Findings（作成日順）
- 2026-09-02 MANFRI-DEV/sprite-sheep — [GitHub](https://github.com/MANFRI-DEV/sprite-sheep)
- 2026-09-08 with-pebbly/aseprite-ai-artist（★348、9〜10月作成のドット絵系で最多） — [GitHub](https://github.com/with-pebbly/aseprite-ai-artist)
- 2026-09-09 miles990/video-gif-studio（Codex スキル） — [GitHub](https://github.com/miles990/video-gif-studio)
- 2026-09-10 aigengame/aseprite-automation — [GitHub](https://github.com/aigengame/aseprite-automation)
- 2026-09-14（HF）/ 2026-09-20（報道）Qwen-Image-2.1 — [HF](https://huggingface.co/Qwen/Qwen-Image-2.1)
- 2026-09-15 isabellagreco1997/ai-sprite-animator — [GitHub](https://github.com/isabellagreco1997/ai-sprite-animator)
- 2026-09-16 Bocchi-The-Glock/Real-PixelArt（★132） — [GitHub](https://github.com/Bocchi-The-Glock/Real-PixelArt)
- 2026-09-19 envy-ai/sprite-generator — [GitHub](https://github.com/envy-ai/sprite-generator)
- 2026-09-23 UnlimitedEditing/ComfyUI-SpriteSheetPack — [GitHub](https://github.com/UnlimitedEditing/ComfyUI-SpriteSheetPack)
- 2026-09-26 camenduru/TostAI-Sprite-Sheet-Studio — [GitHub](https://github.com/camenduru/TostAI-Sprite-Sheet-Studio)
- 2026-09-28 PeaarLi/ComfyUI-PixelPipeline — [GitHub](https://github.com/PeaarLi/ComfyUI-PixelPipeline)
- 2026-10-02 LibreSprite v1.3 — [GitHub](https://github.com/LibreSprite/LibreSprite)
- 2026-10-04 unclepomedev/ComfyUI-ProperPixelArt、MakabakaGuo/video-frame-animator — [GitHub](https://github.com/unclepomedev/ComfyUI-ProperPixelArt) / [GitHub](https://github.com/MakabakaGuo/video-frame-animator)
- 2026-10-07 aowind/sprite-action-forge — [GitHub](https://github.com/aowind/sprite-action-forge)
- 2026-10-11 comfyUI_support_tools Issue #382（提案） — [GitHub](https://github.com/tomiya7688/comfyUI_support_tools/issues/382)
- 9〜10月に更新された既存ツール: unfake.js（09-29）、proper-pixel-art（10-10）、rembg（10-10）、BiRefNet（10-11）、Wan2.2（09-21）、LTX-2 v1.4.2（10-02）、Pixelorama v1.2.3（09-15）、Aseprite v1.3.18.6（09-22）、ComfyUI 本体（10-16 push、GPL-3.0、★137k） — [ComfyUI](https://github.com/Comfy-Org/ComfyUI)

**日本語の記事（Codex 関連）**
- Zenn「Codexの『ペット』の作り方」: Codex ペットのスプライトシート仕様の例として、1536×1872 を 8列×9行に分け、1セル 192×208 とする（日付は未検証）。 — [Zenn](https://zenn.dev/galirage/articles/codex-custom-pets)
- AICU「CodexアプリとImageGenプラグインによるスプライト生成」（URL から 2026-05-27 と推定、未検証）: 参照画像を添付し、256×256 のセルで idle や歩行を作る。 — [AICU](https://corp.aicu.ai/ja/codex-20260527)

### Inferences
- このプロジェクト（Codex がメインのジェネレータで、MIT ゲーム）に最も合うのは、**isabellagreco1997/ai-sprite-animator の考え方（グリーンバック、足元で位相をそろえる、pixel-art-fixer、AGENTS.md 駆動）＋ Real-PixelArt か pixel-art-fixer ＋ 自作の Godot .tres 出力**。どれも MIT なので、ライセンス上の問題はない。

### Gaps
- Reddit（r/StableDiffusion、r/aigamedev、r/comfyui）、Hacker News、X の9〜10月の投稿は、検索で直接取れなかった（取れたのはスナップショットのミラー1件だけ）。
- 新リポジトリの品質（実際に動くか）は試していない。★数は2026-10-16時点の値。
