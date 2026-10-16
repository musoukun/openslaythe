# 参照画像1枚でCodexのアートを揃える

結論から言うと、ここ1か月の新しい手法で本当に効くのは、新しい MCP や大型スキルではありません。**Codex CLI 0.158.0（2026-09-28）で入った「透明背景の明示指定」と「ファイルとして渡した画像の編集」を、今の `tools/codex_art/generate.py` に取り込むこと**です。手元の Codex は **codex-cli 0.162.0-alpha.17.2** で、`codex exec` に **`-i, --image <FILE>`**（最初のプロンプトに画像を添付する）オプションがあることも確認しました（本調査で `codex exec --help` を実行）。つまり、追加のツールを入れなくても「承認済みの立ち絵（master）1枚を毎回添付して描かせる」経路を作れます。今のパイプラインの一番の問題は、キャラの同一性をテキストだけで保とうとしていることです。その結果、シートごとに剣や装甲のデザインが変わり、hurt では体が約45px横に跳びます。参照画像の添付は、この問題に直接効きます。9〜10月に目立った OSS（agent-sprite-forge v0.4.0、sprite-gen v2.4x、ai-sprite-animator、Real-PixelArt など）は「master 静止画 → image-to-video → 決まった手順の後処理」という流れにそろってきました。ただ、動画の工程は Codex では作れず、別の API か、ローカルの Wan2.2 が要ります。そのため、ここは第2段階の選択肢として扱うのが妥当です。別セッションで進んでいる半竜の戦士（LoL 風ハイファンタジー）の再設計は、ドット絵ではなく手描きの HD 調になるはずです。なので、ドット絵のグリッド復元 OSS は今回の主役ではなく、**master 1枚の確定、`refs` 欄の追加、生成サイズの固定、候補の複数生成とコンタクトシートでの選別**の4点が最初にやるべきことになります。

## 今のパイプラインの骨格は正しく、弱点は3つの癖にある

今の仕組みは2段構えです。まず brief.md を Codex に渡して manifest JSON（`style` と `assets[]`）を書かせます。次に `generate.py` が1アセットにつき1回 `codex exec -C tools/codex_art/raw -s workspace-write --skip-git-repo-check --ephemeral -` を起動し、`$imagegen` で raw PNG を作り、Pillow で切り抜き・クロマキー・シート分割・縮小をします（tools/codex_art/generate.py:39-65, 131-267）。この構成は、9〜10月に大量に作られた「Claude Code から `codex exec` を呼んで ChatGPT のサブスクで画像を作る」ブリッジ類と同じ形です（[oakplank/gpt-image-bridge](https://github.com/oakplank/gpt-image-bridge)、[Sateezg/codex-bridge](https://github.com/Sateezg/codex-bridge)）。なので、作り直す必要はありません。git の履歴を見ると、全146アセットを約30分（4〜5並列）で一巡しており、速さはすでに十分です（git log 39fc8af→af77582 のコミット時刻からの推定）。

問題は、生成の速さではなく、3つの癖にあります。1つ目は、**参照画像を一切使わずテキストだけで同一性を保っていること**です。手描き主人公の6件は、どれも同じ約1,000字の外見記述で始まります（tools/codex_art/hero_painted_assets.json:16）。それでも、idle は細身の剣、attack と hurt は幅広のクリーム色の刃、block はまた別の刃になりました。2つ目は、**シートを足元の中心で左右合わせしていること**です。のけぞる hurt では bbox が x=13〜258 になり、idle（x=59〜261）から約45px左にずれます。attack_3 の斬撃の弧はセルの境界で切れています。3つ目は、**「1枚生成してそのまま採用」で、部分修正の経路がないこと**です。671fab6 では背中の鉢を消すだけのために、14フレーム、アイコン、バストをすべて作り直しました。加えて、設計文書は古いままで（docs/character_design.md:17, 63 は今も背中の原子炉を書いている）、最新の正しい定義が prompt の中にしかありません。これも、再設計のたびにぶれが出る下地になっています。

## 9月の2つの更新がgenerate.pyの改修点を決める

1つ目の更新は **GPT Image 2.5（2026-09-08）** です。ChatGPT と Codex の全ユーザー向けに公開され、API には速さ重視の `gpt-image-2.5-flare` と、精密な編集向けの `gpt-image-2.5-sunburst` が追加されました（[OpenAI Community](https://community.openai.com/t/introducing-gpt-images-2-5-in-the-api-and-chatgpt/1395897)、[OpenAI Image generation guide](https://developers.openai.com/api/docs/guides/image-generation)）。公式ドキュメントによると、`background` は `transparent` / `opaque` / `auto` から選べ、透明背景は両モデルで使えます。サイズは縦横とも16の倍数で、縦横比は1:3〜3:1、総画素数は655,360〜8,294,400です。品質には `xhigh` と `max` が追加されました（[同ガイド](https://developers.openai.com/api/docs/guides/image-generation)）。ただし、**Codex の組み込み `image_gen` が今どのモデルを使っているかは、公式の一次情報では確認できていません**。「Codex ではまだ 2.0 の絵が出る」という報告もありますが、裏は取れていません（未検証）。

2つ目の更新は **Codex CLI 0.158.0** です。リリースノートには「Image generation and editing can explicitly request transparent backgrounds」と「edits now accept file-backed conversation images」とあります（[GitHub release rust-v0.158.0](https://github.com/openai/codex/releases/tag/rust-v0.158.0)）。Codex 公式の imagegen スキルも、既定は API キー不要の組み込みツールで、参照画像を使った生成と edit に対応し、用途として「game assets」「sprites」を挙げています（[openai/skills](https://github.com/openai/skills)）。この2つと、手元の CLI で確認した `-i` オプションを合わせると、generate.py でやるべき改修は3つにまとまります。1つ目は、manifest に `refs` 欄を足して `codex exec -i <ref.png>` で添付すること。2つ目は、透明背景を「明示的に」頼み、生成後に四隅のアルファを機械で確かめること。3つ目は、生成サイズを API の制約に合わせて固定することです。3つ目の具体例として、戦闘背景（1200×700）は **1920×1120** で頼むと、縦横比がちょうど 1200:700 になり、縦横とも16の倍数を満たします。今のように中央クロップで端が欠けることもなくなります。ただし、組み込みツールが任意のサイズ指定に従うかは未検証です。今の raw は 1254×1254 が中心で、背景の一部は Codex が勝手に 1200×700 にリサイズして保存していました。

参照画像の渡し方には、Qiita の @archeleeds が7月に公開して9月に更新したパイプラインのやり方がそのまま使えます。承認済みの絵を参照に渡し、**「デザインは画像Aに、ポーズはテキスト（または画像B）に従え」と役割を分けて指示する**と、ポーズの写り込みが減ります。同じ記事は、Windows で `codex exec` がパイプの stdin 待ちで止まる問題（プロンプトを `-` で渡してすぐ閉じる）と、再生成で良い出力が失われる問題（入力ハッシュでキャッシュする）にも対処しています（[Qiita](https://qiita.com/archeleeds/items/2efad73069b54288deb4)）。前者は generate.py ですでに対処済みです。後者は `--force` の上書きで実際に起きているので、raw を履歴として残すだけで防げます。PowerShell から日本語のプロンプトを渡すと文字化けして画像が書き出されない、という落とし穴も報告されています（[note しらたま](https://note.com/shiratama1126/n/nfab5d83b40f0)）。generate.py は `encoding="utf-8"` で stdin に渡しているので、ここは影響を受けません。

## 半竜の主人公は「master 1枚＋参照付き生成」で作り、動画経路は後回しにする

9〜10月に一番伸びた2本のスキルは、どちらもシートを丸ごと描かせる方式から離れました。**agent-sprite-forge v0.4.0（2026-10-06、★4,467）** は、承認した master 静止画1枚から、アクションごとに image-to-video を作ります。そこから Python で、キー抜き、位置合わせ、ループ化、リタイムを行い、Godot の SpriteFrames `.tres` まで書き出します（[agent-sprite-forge](https://github.com/0x0funky/agent-sprite-forge)）。**sprite-gen（2026-10-15 更新、★2,833）** は「画像モデルにスプライトシートを頼むと顔がコマごとに変わり、背景が抜けず、グリッドからずれる」と明言しています。そのため、ベース画像から1行ずつ生成し、フレームの座標を `manifest.json.frame_layout` で渡す設計にしています（[sprite-gen](https://github.com/aldegad/sprite-gen)）。agent-sprite-forge が挙げる一貫性の規則（モーションのプロンプトごとに特徴の要約を毎回入れる、体の大きさは master で1つに決める、数値チェックだけでは合格にせずコンタクトシートを目で見る）は、そのまま今回の再設計の作業ルールにできます。

ただし、どちらもそのまま入れるのは勧めません。理由は3つあります。1つ目は、動画の工程に xAI（Grok Imagine）、fal、BytePlus などの API か、ローカルの動画モデルが必要になることです。「Codex で画像を作る」という前提から外れます。2つ目は、agent-sprite-forge の README 自身が「Editor imports are not verified yet」と書いていることです。書き出した `.tres` を Godot 4.6 で開けるかは誰も確かめていません。3つ目は、このゲームの Godot 側が `.tres` を必要としていないことです。`ArtOverrides` は `hero_idle_%d.png` などの連番 PNG を「あれば読む」方式なので、ファイル名さえ守ればコードを変えずに差し替えられます（scripts/ArtOverrides.gd:42-77）。2本のライセンスは今回のノートでは確かめていないので、コードを取り込む前に確認が要ります（未確認）。また、agent-sprite-forge は API キーが環境変数にあればそれを優先して使います。`OPENAI_API_KEY` などを設定したままだと、サブスクではなく API 課金に流れる点にも注意してください。

そこで、再設計の作業は次の順で進めるのが一番単純です。まず、半竜の戦士の **master（正面寄りの右向き全身、透明背景、1024×1024）を1枚だけ確定**し、`tools/codex_art/refs/hero_master.png` として正本にします。次に、idle、attack、hurt、block の各シートをこの master を `-i` で添付して作ります。これで、剣、角、鱗、装甲の意匠が master に引っぱられます。宝石のような小さな修正は、作り直さずに edit で直します（GPT Image 2.5 Sunburst が得意とする用途）。それでも歩きや速い動きが足りなければ、そのときに動画経路を1アクションだけ試します。ローカルで試すなら、商用で使えて一番安全なのは **Wan2.2（Apache-2.0）** です（[Wan2.2](https://github.com/Wan-Video/Wan2.2)）。RTX 3070 Ti 8GB でも MiniMax H3 Turbo が 448×448・39フレームを約25秒で作った実測があり（[sprite-action-forge](https://github.com/aowind/sprite-action-forge)）、16GB の 5070 Ti なら Wan2.2 も動く見込みは高いです。ただし、5070 Ti での実測は見つかっていません。RTX 50 系は CUDA 12.8 以上と最新の PyTorch が必要です（[Wonderful Launcher](https://wonderfullauncher.com/docs/gpu-compatibility)）。

シートの位置合わせは、外部ツールより generate.py の小さな修正で直すのが早いです。今は全フレームを足元の中心で個別にそろえています。これを、**各シートの1コマ目を idle 1コマ目と同じ基準点に置き、シート内の各コマの相対的なずれは生成されたまま残す**方式に変えると、hurt ののけぞりは動きとして残り、アニメーションを切り替えたときの横跳びも消えます（ノートの計測をもとにした本レポートの提案です）。ai-sprite-animator（MIT、2026-09-15）の「足元を基準にグリッドの位相を固定する」処理も同じ考え方です（[ai-sprite-animator](https://github.com/isabellagreco1997/ai-sprite-animator)）。斬撃の弧が切れる問題は、tau-home の「エフェクトは4コマ以内に収め、セル境界は手で確かめる」という勧めのとおりです（[tau-home.com](https://tau-home.com/en/post/gpt-image-2-5-character-to-16-frame-pixel-art-combat-sprite-sheet/)）。セルに余白を持たせて生成し、弧がセルの端に触れたら自動で NG にする検査を足せば対処できます。

## 背景・羊皮紙・アイコンは style bible とサイズ固定で足りる

1枚で完結するアセットに、新しい OSS はほとんど要りません。効くのは、スタイル定義文（style bible）を共通にすることと、解像度を固定することです（[Converge guide](https://combos.converge.ai/page/en-US/blog/gpt-image-2-game-development)）。今は manifest が5本あり、`style` がそれぞれ違います（ガッシュ、ドット絵、アニメセル、セピアインク、絵本）。LoL 風ハイファンタジーへ寄せるなら、**`tools/codex_art/style_bible.md` を1つ作って全 manifest の `style` をそこから読み込む**ようにします。そうすれば、主人公・背景・敵の画風を1か所で切り替えられます。戦闘背景の prompt には、プレイヤー域 x=140〜480、敵域 x=650〜1100、下30%は手札で隠れる、という配置の決まり（docs/art_direction.md:65-73）を毎回入れます。さらに、Act 1 の背景を `-i` で添付して Act 2・3 を作ると、光源と筆致がそろいます。羊皮紙マップは今の `seamless_y` のクロスフェードで縦に並べられているので（tools/codex_art/generate.py:104-113）、手を入れるのはスタイルの更新だけで済みます。

レリックやカードのアイコンでは、透明背景がうまく出るかどうかが鍵になります。0.158.0 で明示指定はできるようになりましたが、**`$imagegen` 経由で本当にきれいなアルファが出るかは未検証**です。tau-home は Web と API の出力でも白や灰色の背景になりやすいと報告しています（[tau-home.com](https://tau-home.com/en/post/gpt-image-2-5-character-to-16-frame-pixel-art-combat-sprite-sheet/)）。そこで、生成後に四隅のアルファと不透明率を測り、失敗したら `#00FF00` のグリーンバックで描き直して、既存の `chroma_key` で抜く、という二段構えにします。それでも縁が汚いときの補助には、**rembg（MIT、10/10 更新）＋ BiRefNet（MIT）** を使います（[rembg](https://github.com/danielgatis/rembg)、[BiRefNet](https://huggingface.co/ZhengPeng7/BiRefNet)）。よく名前の出る **BRIA RMBG-2.0 は CC BY-NC 4.0 で非商用**なので使わないでください（[HF](https://huggingface.co/briaai/RMBG-2.0)）。96px と 24px に縮めて読めるかどうかは、生成後に実寸のコンタクトシートを自動で作り、Claude に画像として見せて判定させると、目視の手間が減ります。

ドット絵のグリッド復元ツール（Retro-Diffusion/pixel-art-fixer、proper-pixel-art、Real-PixelArt。いずれも MIT）は、9〜10月にも更新や新作が続きました（[pixel-art-fixer](https://github.com/Retro-Diffusion/pixel-art-fixer)、[proper-pixel-art](https://github.com/KennethJAllen/proper-pixel-art)、[Real-PixelArt](https://github.com/Bocchi-The-Glock/Real-PixelArt)）。ただ、このゲームは 367147a でドット絵をやめて手描きに移っています。ドット絵版を復活させるときまでは保留でかまいません。同じ理由で、タイトルのバストアップに残っている `TEXTURE_FILTER_NEAREST`（scripts/ui/UiSkin.gd:82）は、手描きの新主人公では外すべきです。

## MCPとスキルは「入れない」判断が多く、ライセンスの赤旗も多い

Claude Code 側では、Anthropic 公式の `anthropics/skills` にゲームアート用のスキルはありません（[anthropics/skills](https://github.com/anthropics/skills)）。Godot MCP は9〜10月に大量に作られましたが、新しいものの多くは **Godot 4.7 / 4.7.2 前提**です（[leftos/godot-mcp](https://github.com/leftos/godot-mcp)、[bebabinlarsson-blip/Godot-MCP](https://github.com/bebabinlarsson-blip/Godot-MCP)）。後者は「Official」を名乗っていますが、個人のリポジトリです。継続して更新されていて MIT の **tugcantopaloglu/godot-mcp**（2026-10-09 push）は `game_screenshot` を持ちますが、任意の GDScript を実行する `game_eval` もあります（[GitHub](https://github.com/tugcantopaloglu/godot-mcp)）。4.6 で動くかは未検証です。このプロジェクトにはすでに、`--write-movie` で撮影する `tools/shot.ps1` と DevAutoPilot があるので、見た目の確認のために MCP を足す価値は小さいです。画像生成の MCP も、OpenAI 向けは★0〜1 のものばかりで、generate.py と同じことをするだけです。

| 項目 | ライセンス・条件 | 判定 |
|---|---|---|
| rembg / BiRefNet / BEN2 | MIT | 使ってよい（ツールとして） |
| pixel-art-fixer / proper-pixel-art / Real-PixelArt / ai-sprite-animator | MIT | 使ってよい（ドット絵を作るとき） |
| Wan2.2 | Apache-2.0 | 動画経路を試すならこれ |
| FLUX.2 klein 4B / Qwen-Image-Edit-2511 | Apache-2.0 | ローカルで補助に使うなら可 |
| **BRIA RMBG-2.0** | **CC BY-NC 4.0（非商用）** | 使わない |
| **Qwen-Image-2.1**（9月公開、RGBA 生成） | **qwen-research（非商用）** | 製品素材には使わない |
| **FLUX.2 klein 9B / FLUX.1 Kontext dev** | **非商用** | 使わない |
| **MiniMax H3** | **独自ライセンス。ローカル生成物の商用利用にも別ライセンスが要る** | 使わない |
| LTX-2 | 独自ライセンス | 条文を確認するまで保留 |
| **Comfy-Org/comfy-mcp / envy-ai/sprite-generator** | **AGPL-3.0** | ツールとして使うのは可。リポジトリに取り込まない |
| LibreSprite / Sprite-Sheet-Packer | GPL | 同上 |
| TostAI / ComfyUI-PixelPipeline / SpriteSheetPack / sprite-action-forge | ライセンス表記なし | コードを流用しない |
| agent-sprite-forge / sprite-gen | 本調査では未確認 | 取り込む前に確認する |

出典は、表の行ごとに [rembg](https://github.com/danielgatis/rembg)、[Wan2.2](https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B)、[Qwen-Image-2.1](https://huggingface.co/Qwen/Qwen-Image-2.1)、[FLUX.2 klein 9B](https://huggingface.co/black-forest-labs/FLUX.2-klein-9B)、[MiniMax H3 ガイド](https://docs.comfy.org/tutorials/video/minimax/minimax-h3)、[comfy-mcp](https://github.com/Comfy-Org/comfy-mcp)、[envy-ai/sprite-generator](https://github.com/envy-ai/sprite-generator) です。MIT のゲームに生成物を入れるときに一番の落とし穴になるのは、「ローカルで動くから自由に使える」と思い込みやすい MiniMax H3 と Qwen-Image-2.1 の2つです。どちらも9月前後に話題になったモデルで、9月作成の ComfyUI ノードの一部はこの2つを前提にしています（[ComfyUI-SpriteSheetPack](https://github.com/UnlimitedEditing/ComfyUI-SpriteSheetPack)）。

## 採用計画は「master確定」から始めて1歩ずつ広げる

下の表は、小さい一歩から順に並べています。どのステップも「1アセットで試す → 目で見る → 全体に広げる」の単位で止められます。Codex 以外の画像生成器は、ステップ8まで出てきません。

| 順 | やること | 変更する場所 | 完了の目安 | 未検証の点 |
|---|---|---|---|---|
| 1 | 半竜の戦士の master を1枚だけ確定し、`tools/codex_art/refs/hero_master.png` に置く。外見の正本を docs/character_design.md に書き直し、背中の原子炉などの古い記述を消す | 再設計セッションの成果物、docs | master 1枚と文書が一致している | — |
| 2 | manifest に `refs: [...]` 欄を足し、`generate_raw` で `-i <ref>` を付ける。prompt に「デザインは添付画像1、ポーズは Subject に従う」を足す（約10行） | generate.py:39-61 | hero_idle を1件だけ生成し、剣と装甲が master と一致する | **`-i` で添付した画像を `$imagegen` が参照として使うかは未検証**（CLI にオプションがあることだけ確認済み） |
| 3 | 透明背景を明示的に頼み、生成後に四隅のアルファで判定する。失敗したら `#00FF00` のグリーンバックで描き直し → `chroma_key` | generate.py の `build_prompt` と後処理 | レリックのアイコン5件で縁にハローが出ない | **`$imagegen` 経由で透過 PNG が出るかは未検証** |
| 4 | manifest に `gen_size` 欄を足す（背景 1920×1120、キャラ 1024×1024 など）。`style_bible.md` を1本にまとめて全 manifest から読む | generate.py、新規 style_bible.md | Act 1 背景が中央クロップなしで 1200×700 になる | 組み込みツールが指定サイズに従うか |
| 5 | `--variants N` で候補を N 枚作り、raw を上書きせず履歴に残す。実寸（24/32/96/300px）のコンタクトシートを自動で作り、Claude か人が選ぶ | generate.py | 「1発採用」をやめ、選別の記録が残る | サブスクのレート制限にどれだけ余裕があるか |
| 6 | シートの整列を「1コマ目を idle 1コマ目の基準点に合わせ、シート内のずれは残す」方式に変える。bbox の跳びとセル端の接触を自動検査する | generate.py:131-249 | アニメーションを切り替えても横跳びせず、攻撃の弧が切れない | — |
| 7 | Godot 側: `add_animation` が `animation_frame_durations` を渡すようにし（設計の 90/110/70/130ms を反映）、バストアップの NEAREST を外す | data/readonly/AnimationData.gd、scripts/ui/UiSkin.gd | shot.ps1 の動画でタイミングが設計どおり | 実機での表示はまだ確かめていない |
| 8 | 足りない動き（death、敵の攻撃）だけ、master から Wan2.2 I2V で1アクションを試す。agent-sprite-forge を使うなら、ライセンスを確認し、API キーを外した状態で試す | 別フォルダで試す | 1アクションの PNG 連番が ArtOverrides の命名で読み込める | 5070 Ti での速度と VRAM、`.tres` が Godot 4.6 で開けるか |
| 9 | Godot MCP や画像 MCP は今は入れない。必要になったら、4.6 で動くかを確かめてから tugcantopaloglu/godot-mcp を候補にする | — | — | 4.6 で動くか |

ステップ2〜3は、それぞれ generate.py の数十行以内の修正で済みます。さらに、再設計セッションが作る master をそのまま入力にするので、作業がぶつかりません。逆に、ステップ1の前にステップ2以降へ進むと、正本の定まらない絵を参照に固定してしまいます。順番は守ってください。

## Conclusion

この1か月の流行（動画からスプライトを作る、Aseprite や Godot の MCP の量産）は、このプロジェクトにとっては「まだ要らないもの」がほとんどです。本当に価値があったのは、Codex 本体の小さな更新（透明背景の明示指定と、ファイルで渡した画像の編集）と、上位のスキル作者たちが口をそろえて言う「master 1枚を固定し、それを毎回参照させる」という設計の考え方でした。今の generate.py は、ほかのブリッジ類より早くから同じ形を実装していました。欠けていたのは、参照画像という1本の線だけです。

もう1つの示唆として、アートの方向転換のコストを決めているのはプロンプトの長さではなく、正本が何か所に散っているかです。9月25日に3回あった方向転換は、どれも「後処理の関数を足す」ことで吸収してきました。今回の半竜の主人公への再設計は、master 画像と style bible を正本にして、文書、manifest、生成物がそこから派生する形に切り替える好機です。この形にしておけば、次に画風を変えるときも、master を1枚描き直して `--force` で流すだけで済みます。
