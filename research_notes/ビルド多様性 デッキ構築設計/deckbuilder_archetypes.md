# デッキ構築ローグライクにおける「ビルド多様性」と「複数の勝ち筋」の作り方（比較メモ）

> 調査日: 2026-10-16。対象: 1人のヒーローを LoL の AD/AP のように大きく別ビルドへ分岐させたい StS 系インディー開発向け。
> **前提の訂正**: 依頼文では「Slay the Spire 2 は 2025年3月から Early Access」とあるが、複数ソースでは **2026年3月5日 Steam EA 開始**（2025年予定から延期）。Monster Train 2 は **2025年5月21日** 発売、初DLC「Destiny of the Railforged」は **2026年2月2日**。
> 凡例: 【古い可能性】= 2020〜2024年の情報で現行バランスと違う恐れあり。【未検証】= 一次ソース未確認。

---

## Q1. Slay the Spire 1 / 2 のキャラ別アーキタイプ、誘導方法、ビルドが「完成」する条件、壊れコンボの頻度

### Takeaway
StS は「キャラ固有カードプール × 少数の汎用スケーリング資源（Strength / Focus / Poison / Shiv / Stance 等）× レリック」で各キャラに 2〜4 個の明確なアーキタイプを持たせ、カード報酬（3枚から1枚選択＋スキップ可）とレア率の pity 補正で「中盤にキーカードが来る」体験を作っている。無限コンボはデッキ圧縮（除去/Exhaust）＋0コスト・ドロー・エナジー還元が揃った時だけ成立する「稀なご褒美」として許容されており、開発者も「シングルプレイだから稀な壊れコンボは許される」という立場。StS2 は「Ancients（各Act開始時の祝福選択）」と「Enchantment（カード単位の付与効果）」でラン単位の戦略層を追加した。

### Cited Findings
**StS1 のアーキタイプ（プレイヤー認識）**
- Ironclad: Inflame / Spot Weakness で Strength を積み Limit Break で倍化、Heavy Blade で100+ダメージを狙う Strength ビルド（Vajra, Red Skull などのレリックと相性）。もう一つは Corruption（スキル0コスト化＋Exhaust）＋Feel No Pain＋Dark Embrace の Exhaust シナジー — [gamecat（StS2向け記事、StS1と差異ありうる）](https://www.gamecat.it.com/articles/slay-the-spire-2-best-builds)
- Silent: 代表的に Shiv ビルドと Poison ビルドの2系統。Shiv はデッキに直接入れられず多数のカード/レリックから生成され、「1ターンに大量のカードを使うこと」に報酬がある — [highgroundgaming](https://www.highgroundgaming.com/slay-the-spire-character-guide/)
- Defect: Lightning（受動/能動ダメージ）、Frost（毎ターン受動ブロック）、Plasma（エナジー増）の Orb を使い分け、Frost 防御型などのアーキタイプがある — [fantasywarden](https://fantasywarden.com/games/slay-the-spire-defect-builds)
- Barricade（Ironclad ブロック保持）・Claw（Defect 0コスト連打）・Silent の Discard 系、Watcher の Stance/Divinity については今回良質なソース未取得（Gaps 参照）。

**カード報酬・レア率（誘導の仕組み）**
- 通常戦闘のレア基本確率 3%、エリート 10%、ショップ 9%、ボス報酬は全てレア — [StS Wiki: Card Rewards](https://slay-the-spire.fandom.com/wiki/Card_Rewards)
- pity 補正: オフセットは -5% から始まり、コモンが出るたび +1%、レアが出ると -5% にリセット、上限 +40%。カード報酬（Orrery, Tiny House 含む）のみがカウント対象 — [StS Wiki: Card Rewards](https://slay-the-spire.fandom.com/wiki/Card_Rewards)
- 同内容の別表現: 通常戦 (65-x)% コモン / 37% アンコモン / (x-2)% レア、エリート (55-x)% / 40% / (x+5)%（x はコモンを引くごとに +1）— [Steam Discussion](https://steamcommunity.com/app/646570/discussions/0/594015710347314793)
- 各 Act の最初のフロアでは原則レアが出ない — [StS Wiki: Card Rewards](https://slay-the-spire.fandom.com/wiki/Card_Rewards)

**無限コンボ（「壊れ」）の成立条件**
- Ironclad: Dropkick＋Vulnerable（デッキ圧縮後に Dropkick×2 でエナジー還元）が「最も簡単な無限」。Double Tap+ 追加で4回発動。Hemokinesis＋Rampage＋Pommel Strike の HP 消費型ループもある — [slaythespire.info](https://slaythespire.info/en/slay-the-spire-12-infinite-loop-combo-builds-by-character/)
- Silent: Tactician＋Reflex（6枚デッキ）、Heel Hook ループ（5枚デッキ・Purity 実質必須）、After Image 型（8枚） — 同上
- Defect: All For One＋Madness×2（完全圧縮不要で「意外と達成可能」）、Meteor Strike＋Skim、Plasma＋Recursion の Energy Festival（Nuclear Battery で容易化）— 同上
- Watcher: Eruption＋Rushdown＋Inner Peace、Worship＋Establishment での Divinity ループ、Fear No Evil＋Empty Head — 同上
- 共通点: 5〜8枚まで「圧縮」したデッキ＋0コスト/ドロー/エナジー還元。同記事は成功率や頻度の数値は出しておらず難易度は主観評価 — 同上

**開発者の設計思想（GDC 2019）**
- Anthony Giovannetti（Mega Crit）GDC 2019 講演「Slay the Spire: Metrics Driven Design and Balance」— 早期からメトリクス重視、EA 期間中もデータ駆動で開発 — [Game Developer](https://www.gamedeveloper.com/design/learn-i-slay-the-spire-i-s-metrics-driven-approach-to-game-balancing-at-gdc-2019) / [GDC Vault](https://www.gdcvault.com/browse/gdc-19/play/1025731)
- 講演要約: 「every card should have its place」、OP効果は戦略多様性のため避ける一方、シングルプレイなので稀な OP コンボは他プレイヤーを害さず許容できる — [Podwise 要約](https://podwise.ai/episodes/1459444)

**Slay the Spire 2（2026年3月5日 EA 開始）**
- EA 開始 2026年3月5日（2025年目標から延期）、EA 期間中は Steam 独占、最大4人協力モード — [Shacknews](https://www.shacknews.com/article/147940/slay-the-spire-2-early-access-release-date) / [Insider Gaming](https://insider-gaming.com/slay-the-spire-2-early-access-release-date-exact-start-times/)
- ローンチ時キャラ5人: Ironclad / Silent / Defect（リワーク）＋新キャラ Necrobinder / Regent。Watcher はローンチ時未収録 — [slaythespire2.gg](https://slaythespire2.gg/guides/sts2-release-date)
- Necrobinder: 骸骨の相棒 Osty、Doom（敵HP以下になると即死させる蓄積デバフ）、Souls、カード変換 — [slaythespire2.gg](https://slaythespire2.gg/guides/sts2-release-date)
- Necrobinder のビルド例: Banshee/Exhaust 循環型、Soul Engine 型、Osty 殴り型（ソース間で記述が食い違うため要検証）— [intoindiegames](https://intoindiegames.com/walkthroughs/tips-tricks/slay-the-spire-2-necrobinder-ultimate-build-guide/)
- Regent: ターンを跨いで持ち越す副資源 Stars、Forge で専用武器 Sovereign Blade のダメージを強化 — [Mobalytics](https://mobalytics.gg/slay-the-spire-2/characters/regent-guide)
- Regent ビルド: Star / Forge / Colorless / Infinite Deck の4系統（Star が最も安定）— [intoindiegames](https://intoindiegames.com/walkthroughs/tips-tricks/slay-the-spire-2-the-regent-ultimate-build-guide/)。「安定した Star 生成＋エナジー生成＋ドロー/手札管理のエンジンに、1〜2個の勝ち筋（payoff）を載せる」— [slaythespire2.gg Regent guide](https://slaythespire2.gg/guides/regent-build-guide)
- Ancients: 各 Act 開始時に会う NPC が、旧作のボスレリックの代わりに「祝福」を3択で提示（Act1 は Neow）。例: Beautiful Bracelet（3枚に Swift 3 付与）、Glitter（全カード報酬に Glam 付与）、Brilliant Scarf（毎ターン5枚目が無料）— [Mobalytics: Ancients](https://mobalytics.gg/slay-the-spire-2/guides/ancients)
- Enchantment: カード個別の付与効果（Corrupted: ダメージ+50%だが HP2 消費、Glam: 1戦闘1回リプレイ、Spiral: Replay 1 等）。「デッキが戦術、Ancient の祝福が戦略を決める」とのコミュニティ評 — [slaythespire2.gg Enchantments](https://slaythespire2.gg/enchantments) / [Mobalytics: Ancients](https://mobalytics.gg/slay-the-spire-2/guides/ancients)

### Inferences
- StS のアーキタイプは「専用スケーリング資源（Strength, Focus, Poison, Shiv数, Stars, Doom）」を軸に、**資源を作るカード（enabler）** と **資源を消費・倍化するカード（payoff: Limit Break, Heavy Blade, Catalyst 等）** が分離されている。payoff が引けた瞬間に「ビルドが完成した」と感じる。
- レア率 pity は「キーカード（多くはレア）が来ないまま終わる」ランを減らし、中盤〜後半にビルドが「完成する」タイミングを揃える装置として機能している。
- 無限コンボは「除去/Exhaust で圧縮」という明確な努力とスキルを要求するため、運だけのご褒美ではなく「腕で確率を上げる変動報酬」になっている（ユーザーの言う“ドーパミン設計”に合致）。
- StS2 の Ancients＋Enchantment は「デッキの外側にラン単位の方針を置く」仕組みで、1キャラ内のビルド分岐を増やす低コスト手段。ヒーロー1人で AD/AP 的に分けたいなら、この「Act開始時の大きな3択」が最も直接的な参考になる。

### Gaps
- GDC 2019 講演本編（カード別ピック率/勝率グラフ、具体的な調整カード）は GDC Vault/YouTube 本編を未視聴のため数値なし。
- Ironclad Barricade/Body Slam、Silent Discard、Defect Claw、Watcher Stance の一次的なアーキタイプ解説ソースは今回取得できず（一般にコミュニティで周知されているが【未検証】）。
- StS2 の 2026年10月時点の最新キャラ（Watcher 追加有無など）、最新パッチでの Necrobinder アーキタイプは未確認。無限コンボの発生頻度（全ラン中の％）の公式データは見つからず。

---

## Q2. Monster Train 1 / 2: クラン組み合わせ、チャンピオン強化パス、カード強化、アーティファクト

### Takeaway
Monster Train は「メインクラン（チャンピオン＋初期カード）× 同盟クラン（カードのみ）」の組み合わせでラン開始時点から構成を変え、さらにチャンピオンを「3パス×3段階」の分岐強化で育てる。これは“1人のヒーローを別ビルドに育てる”のほぼ直接的な実装例。パスは混合可能（例: Brawler I＋Reaper I）で、混合も成立するよう Level I に基礎パワーを分散させるのが設計上のコツ。

### Cited Findings
- MT1: メインクランが初期カードとチャンピオンを提供、同盟クランはカードのみ。5クラン×他4クラン＝20通り — [Indiecator / 各ガイドの要約](https://indiecator.org/2021/07/09/indietail-monster-train/)【古い可能性】
- MT1 チャンピオン強化: 各チャンピオンに3パス×3段階。異なるパスの強化は累積し混合ビルド可 — [steamah ガイド](https://www.steamah.com/?p=36232)【古い可能性: 2020年頃】
- 例 Hornbreaker Prince: Brawler（Multistrike＝多段攻撃）/ Reaper（攻撃力＋Slay で攻撃上昇）/ Wrathful（バランス成長＋Slay で装甲、Revenge で Rage）。The Sentient: 攻撃0固定で HP を伸ばしつつ Explosive（回復時ダメージ）/ Cultivating（被弾時ドロー）/ Bristling（Spikes）。Tethys Titansbane: Chillwind（高攻撃＋Frostbite）/ Conduit（呪文コスト減）/ Handheld Totem（Sweep＋Spell Weakness） — [steamah ガイド](https://www.steamah.com/?p=36232)
  - 注目点: The Sentient のように「同じユニットが“壁＋カウンター”“ドローエンジン”“棘反射”と全く別の役割になる」パス設計。
- MT2（Trainworks-Reloaded MOD フレームワークの仕様から）: 最大3パス（UI上限）、各パス正確に3段階。同パス内の上位段は下位を置換（Level II が Level I を除去）、別パス同士は共存。強化は Light Forge で選択 — [Trainworks-Reloaded Wiki](https://github.com/Monster-Train-2-Modding-Group/Trainworks-Reloaded/wiki/Custom-Champions)
- 同仕様の設計指針: ユニットは能力を1つしか持てないため「能力は基礎/Level III のみ/1パス専用」にする。クロスパス（各パス Level I つまみ食い）を成立させるため、初期パワーの一部を各パスの Level I に移す。数値例 10/10 → I:40/40 → II:100/70 → III:280/130（段階ごとに指数的に伸びる）— [Trainworks-Reloaded Wiki](https://github.com/Monster-Train-2-Modding-Group/Trainworks-Reloaded/wiki/Custom-Champions)
- MT2 発売 2025年5月21日 — [Gematsu](https://www.gematsu.com/2025/04/monster-train-2-launches-may-21)
- MT2: 主＋副クランで開始、初期5クラン＋隠しクラン。隠しを除いても「80通りの開始」。各クランに2チャンピオン。新カード種 Equipment（ユニットに装備）と Room（車両全体に効果: 呪文強化、ユニット死亡で金など）、Pyre（能動/受動能力）、21種の Dimensional Challenges（クラン固定＋変異ルール） — [Game Informer レビュー](https://gameinformer.com/review/monster-train-2/engine-ingenuity)
- MT2 クラン例: Banished＝Valor バフ（装甲＋ダメージ）、Pyreborn＝金を貯め pyregel で被ダメ増 — [Game Informer](https://gameinformer.com/review/monster-train-2/engine-ingenuity)
- MT2 の各クランは「他のクランと固有の形で噛み合う」よう設計されているとの評 — [Game Informer](https://gameinformer.com/review/monster-train-2/engine-ingenuity)（検索要約経由）。代替チャンピオンはクランレベル5で解放 — [dotesports](https://dotesports.com/indies/news/best-monster-train-2-alternate-champions)
- 2026年2月2日: 無料で Wurmkin クラン復帰、有料DLCで Railforged クラン、新モード Soul Savior（Soul をカードに装備して効果獲得、ボス撃破順自由・倒すごとに呪い＋報酬増）— [Good Shepherd プレスリリース](https://indigo-pearl.prezly.com/monster-train-2-gaining-massive-game-mode-with-new-structure-playable-clan-bosses--more-in-biggest-content-update-yet-first-dlc-launches-feb-2)

### Inferences
- 「メイン（キャラの核）× サブ（追加カードプール）」の2軸選択は、組み合わせ数を n×(n-1) に増やす最も安価な方法。1ヒーロー制でも「サブ系統（例: 炎の書／剣術の書）をラン開始時に選ぶ」形で移植できる。
- 3パス×3段階＋混合可は、合計 3 回程度の強化機会しかなくても「純特化（III まで）」と「ハイブリッド（I＋I＋I）」が両立する。AD/AP 分岐をヒーロー本体の強化パスとして実装する場合の最有力テンプレ。
- 段階ごとの指数的な数値伸び（10→40→100→280）は「特化するほど強い」誘因となり、混合とのトレードオフを生む。

### Gaps
- MT2 の各チャンピオンの具体的パス名、Light Forge の訪問回数/ラン、Upgrade Stone（Surgery 等）の仕様、Artifact（MT1 Artifact / MT2 Relics）の詳細は今回一次ソースを取得できず。
- Shiny Shoe 開発者自身によるクラン設計意図のインタビューは見つからず。

---

## Q3. Balatro: ジョーカーをビルドエンジンにする仕組み、Chips/Mult/xMult、壊れビルドの肯定、Stakes と力の快感

### Takeaway
Balatro のスコアは「Chips × Mult」で、ジョーカーは +Chips / +Mult / xMult / 経済 / 効果 / リトリガーに分類される。xMult 系（特に成長型）が後半の指数的スケーリングを担い、「仕組みを組んで動かす（ルーブ・ゴールドバーグ装置）」こと自体が快楽の中心。LocalThunk はスコア事前表示を意図的に入れず、装置が動く瞬間の驚きを守っている。難易度（Stake）はジョーカーにステッカー制約を追加する形で上げ、パワーファンタジーを削らずに制約で緊張感を作る。

### Cited Findings
- ジョーカー総数 150（1.0.1o 時点）、105 は初期から、45 は解放制。レア度: Common 61枚/出現70%、Uncommon 64枚/25%、Rare 20枚/5%、Legendary 5枚（ショップ不出現、The Soul 経由 0.3%）— [Balatro Wiki: Jokers](https://balatrowiki.org/w/Jokers)
- カテゴリ: +Chips、+Mult（加算）、xMult（乗算）、Chips＆加算Mult、Economy、Effect、Retrigger の7種 — [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- 成長型 xMult の例: Constellation（Planet 使用ごと）、Steel Joker（デッキ内 Steel カード数）、Hologram（カード追加ごと）、Lucky Cat、Campfire（売却ごと、ボス撃破でリセット）— [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- コピー系: Blueprint は右隣、Brainstorm は最左のジョーカーをコピー（配置順が戦略になる）— [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- ジョーカー枠は基本5。デッキで変動（Black Deck 6、Painted Deck 4 等）。エディション: Foil +50 Chips、Holographic +10 Mult、Polychrome x1.5 Mult、Negative +1枠 — [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- 高 Stake ではジョーカーに Eternal（売却/破壊不可）、Perishable（5ラウンドで無効化）、Rental（毎ラウンド$3）が付く — [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- LocalThunk: スコア事前表示を入れない理由として「ルーブ・ゴールドバーグ装置を組んで、勝てるか分からないまま動くのを見る方が楽しい」趣旨。オプション化しても皆押してしまい意図した体験にならない、とも — [GMTK: Balatro's 'Cursed' Design Problem](https://gmtk.substack.com/p/balatros-cursed-design-problem)
- 同記事の筆者見解: Balatro は「壊すのが楽しい」ゲーム。Soren Johnson の「プレイヤーは楽しさを最適化で消してしまう」を引用 — [GMTK](https://gmtk.substack.com/p/balatros-cursed-design-problem)
- LocalThunk は初期プロトタイプがバランス的に「かなり壊れていた」ことを認めている — [Game Developer](https://gamedeveloper.com/business/balatro-dev-gives-look-at-first-prototype-joker-poker)
- コミュニティとの反復で現在の戦略ゲームになった、ファンタジー/戦闘の“ゲームっぽい言語”は好まない — [TouchArcade インタビュー](https://toucharcade.com/2024/03/18/balatro-interview-mobile-port-localthunk-dlc-plans-updates-new-jokers-demo-feedback/)
- 150枚中30枚はパブリッシャー担当者の言い間違いを訂正しない代わりに追加したもので、ファンのお気に入りになったものもある — [80.lv](https://80.lv/articles/balatro-developer-added-30-jokers-to-avoid-correcting-publisher)
- 2025年予定だった 1.1 アップデートは延期（LocalThunk 発表）— [Tildes](https://tildes.net/~games/1q5n/localthunk_i_have_some_unfortunate_news_the_promised_2025_balatro_1_1_update_isnt_going_to_come_out)（2026年10月時点の状況は未確認）

### Inferences
- 「加算（+Chips/+Mult）→乗算（xMult）」の二段構造は、序盤は加算で凌ぎ、後半は乗算を積むという自然な“ビルドの成長曲線”を作る。StS の Strength（加算）と Limit Break（倍化）も同型。ヒーロー1人の AD/AP 分岐でも「加算資源」と「倍率 payoff」を系統ごとに用意すると“完成感”が出る。
- 計算過程を一つずつ演出して見せる（数字が積み上がる）ことが、壊れビルドを「祝福される瞬間」に変えている。演出コストは低いがドーパミン効果が大きい。
- 難易度は「敵を硬くする」だけでなく「ビルド部品に制約（Eternal/Perishable/Rental）」を付ける方式もある。プレイヤーのパワーは保ったまま判断を難しくできる。

### Gaps
- LocalThunk 本人による Stake 設計意図・xMult バランス観の一次発言は見つからず（Game Maker's Notebook 2024年12月回が有力だが未聴取）— [Game Maker's Notebook](https://gamemakersnotebook.libsyn.com/balatro-creator-localthunk-talks-inspirations-and-jokers)
- ジョーカーの評価順（左→右）の正確な仕様は Wiki の Activation Sequence ページ未取得。

---

## Q4. その他タイトル（「1キャラ・大きく違うビルド」に関連が深いもの）

### Takeaway
「1キャラ多ビルド」に最も近い仕組みは、(a) Hades/Hades II の **Weapon Aspect（同じ武器の“型”をラン開始前に選ぶ）＋Boon（ラン中の神の加護）＋Duo/Legendary（前提条件で解放）**、(b) Brotato の **武器タグのセットボーナス＋キャラ固有のスタット変換**、(c) Risk of Rain 2 の **アイテムスタック方式（線形/双曲/指数）**。いずれも「開始時の型選択」と「ラン中のシナジー積み上げ」の二層構造を持つ。

### Cited Findings
**Hades / Hades II**
- Aspect は武器の別形態で、単なるステータス強化ではなく新しい技/メカニクスを与える。Attack/Special/Omega を作り替え、同じ武器でも全く違うビルドになる。Boon・Daedalus 強化と組み合わせてラン毎に新ビルド — [Maxroll Hades 2](https://maxroll.gg/hades-2/guides/hades-2-weapon-and-aspect-overview) / [Mobalytics](https://mobalytics.gg/hades-2/tier-lists/weapon-aspects)
- Hades II: 各武器に標準3＋隠し1の Aspect（ソースにより数え方が異なる）、各 Aspect は Lv5 まで強化可。隠し Aspect は特定 Aspect を Lv5 にして条件達成で解放 — [Mobalytics](https://mobalytics.gg/hades-2/tier-lists/weapon-aspects) / [rogueranker](https://rogueranker.com/hades-2-weapons/) / [Gfinity](https://www.gfinityesports.com/article/how-to-unlock-the-nocturnal-arms-aspects-in-hades-2)
- Duo Boon: 2柱の神の特定 Boon を前提条件として持っている時だけ出現。Legendary Boon も同じ神の特定 Boon が前提。Keepsake や Mirror of Night で出現率を上げられる — [Prima Games](https://primagames.com/tips/hades-what-are-duo-boons-how-get-duo-boons) / [Twinfinite](https://twinfinite.net/guides/hades-duo-boons-list-how-work/)
- Hades II: Pom of Power は Boon のレベルを上げ、レアリティ（Common/Rare/Epic/Heroic）は別軸で既存数値を増幅。Duo/Legendary/Infusion は Pom 不可 — [rogueranker Hades 2 Boons](https://rogueranker.com/hades-2-boons/)
- Greg Kasavin（Supergiant）は StS を「キャラごとに違う上に、デッキ構築がプレイスタイルを生む」点で参考にしたと発言。ジャンルの魅力は難しさではなく「何度でも驚かされること」 — [Tom's Guide](https://www.tomsguide.com/uk/features/hades-exclusive-interview-supergiant) / [GameSpot](https://gamespot.com/articles/hades-changes-what-it-means-to-be-a-roguelike/1100-6483420/)

**Brotato**
- 武器にタグがあり、同タグを複数持つとオートチェス風のセットボーナス。v1.1.15.4 時点で武器202・アイテム197・キャラ50・武器クラスセット15（データツール調べ）— [Quarter to Three フォーラム](https://forum.quartertothree.com/t/brotato-arena-based-auto-shooter-with-crazy-variety-build/156437) / [spud-coach](https://glama.ai/mcp/servers/brendanlefebvre/spud-coach)
- キャラごとに「得意タグ」「禁止アイテム群」「初期武器プール」が定義されている（データツールのフィールド）— [spud-coach](https://glama.ai/mcp/servers/brendanlefebvre/spud-coach)
- 例: Speedy は Speed を近接ダメージに変換、Lucky は Luck スケーリング、Engineer はタレット特化 — [number13](https://en.number13.de/brotato-speedy-build/) / [PocketGamer](https://www.pocketgamer.com/brotato/best-builds/)【古い可能性】

**Risk of Rain 2**
- アイテムの多くは線形スタック（Soldier's Syringe: 1個 +15% 攻撃速度）。確率/軽減系は双曲（Tougher Times: 1−1/(1+0.15x)、10個で60%）で100%に到達しない。Shaped Glass は指数（2個でダメージ×4、HP÷4）— [RoR2 Wiki: Item Stacking](https://riskofrain2.wiki.gg/wiki/Item_Stacking)

### Inferences
- Hades の Aspect は「ラン開始前に“型”を選ぶ」、Monster Train のチャンピオンパスは「ラン中に“型”を育てる」。AD/AP 分岐を作るなら、両方を組み合わせる（開始時に大枠2〜3択＋ラン中に3パス強化）のが最も分かりやすい。
- Duo/Legendary の「前提条件で解放」方式は、プレイヤーにコミット（同系統を集める）を促し、集めた先に“ご褒美カード”が出る＝ビルド誘導の最も直接的な仕組み。
- RoR2 の双曲スタックは「同じものを積みすぎると収穫逓減」で一極集中を抑えつつ、指数スタック（Shaped Glass）は「リスク付き壊れ」を許す。スタック方式自体がバランスの道具になる。

### Gaps
- Wildfrost, Cobalt Core, Across the Obelisk, Roguebook, Griftlands, Dicey Dungeons, Inscryption, Backpack Hero / Backpack Battles, Ring of Pain, Peglin, Luck be a Landlord, Vampire Survivors は今回の調査量（ツール回数）制約で一次ソース未取得。特に Backpack Battles（配置による隣接シナジー）と Vampire Survivors（武器＋パッシブの Evolution）は「1キャラ多ビルド」の参考として追加調査の価値が高い【未調査】。
- Supergiant による Aspect/Boon 設計意図の一次インタビューは見つからず。

---

## Q5. 共通設計パターン（キーストーン、タグ/シナジーハブ、スケーリング資源、報酬バイアス、レア度、除去/変換、ショップ、リロール、3択パス、開始レリック、ピボット）

### Takeaway
成功作に共通するのは、(1) **開始時の大枠選択**（クラン/Aspect/Neow・Ancient の祝福）、(2) **ラン中の小さな3択の積み重ね**（カード/Boon/ジョーカー）、(3) **系統専用スケーリング資源と倍化 payoff**、(4) **コミットを促す前提条件・タグ・セットボーナス**、(5) **デッキを細くする除去/変換**、(6) **キーピースの出現時期を揃えるレア率補正**、の6層構造。

### Cited Findings
- 開始時の大枠選択: StS2 は Act 開始ごとに Ancient が祝福を提示（旧ボスレリックの代替）— [Mobalytics](https://mobalytics.gg/slay-the-spire-2/guides/ancients)。MT2 は主＋副クランで80通り — [Game Informer](https://gameinformer.com/review/monster-train-2/engine-ingenuity)。Hades II は Aspect — [Maxroll](https://maxroll.gg/hades-2/guides/hades-2-weapon-and-aspect-overview)
- 3パス×3段階＋混合可の分岐強化: MT1/MT2 チャンピオン — [steamah](https://www.steamah.com/?p=36232) / [Trainworks-Reloaded](https://github.com/Monster-Train-2-Modding-Group/Trainworks-Reloaded/wiki/Custom-Champions)
- 前提条件で出現する上位報酬: Hades の Duo/Legendary Boon — [Prima Games](https://primagames.com/tips/hades-what-are-duo-boons-how-get-duo-boons)
- タグ/セットボーナス: Brotato の武器タグ — [Quarter to Three](https://forum.quartertothree.com/t/brotato-arena-based-auto-shooter-with-crazy-variety-build/156437)
- レア度ティアと出現重み: Balatro 70/25/5％＋Legendary 0.3% — [Balatro Wiki](https://balatrowiki.org/w/Jokers)。StS のレア pity — [StS Wiki](https://slay-the-spire.fandom.com/wiki/Card_Rewards)
- 加算→乗算のスケーリング: Balatro の +Mult / xMult — [Balatro Wiki](https://balatrowiki.org/w/Jokers)。StS Strength＋Limit Break — [gamecat](https://www.gamecat.it.com/articles/slay-the-spire-2-best-builds)
- デッキ圧縮が壊れコンボの前提: StS 無限コンボ全般 — [slaythespire.info](https://slaythespire.info/en/slay-the-spire-12-infinite-loop-combo-builds-by-character/)
- カード単位の付与効果（Enchantment）: StS2 — [slaythespire2.gg](https://slaythespire2.gg/enchantments)
- 難易度をビルド部品への制約で付与: Balatro Stake ステッカー — [Balatro Wiki](https://balatrowiki.org/w/Jokers)
- スタック方式による収穫逓減/リスク付き爆発: RoR2 — [RoR2 Wiki](https://riskofrain2.wiki.gg/wiki/Item_Stacking)

### Inferences
- 「1ヒーロー×AD/AP」実装の最小構成案（推論）:
  1. ラン開始 or Act1 開始時に「系統の祝福」3択（例: 刃の誓い/魔導の誓い/鉄壁の誓い）→ 以後のカード報酬の重みを系統寄りに（weighted rewards）。
  2. 系統ごとに専用スケーリング資源（例: 刃＝Edge スタック、魔導＝Mana 蓄積）を1つずつ。enabler はコモン、payoff（倍化）はアンコモン/レアに置く。
  3. ヒーロー本体に MT 式「3パス×3段階」強化（エリート撃破やキャンプで解放）。混合可にし、Level I に基礎パワーを分散。
  4. 系統を2つ以上集めると出る「Duo カード」（前提条件解放）でハイブリッドの“ご褒美”を用意。
  5. 除去/変換（ショップ・イベント）で圧縮→無限・壊れの余地を残す。演出は Balatro 式に数字が積み上がるように。
- ピボット（途中で系統変更）を可能にするには、汎用カード（どの系統でも使える）を一定比率で混ぜ、カード変換イベントを置くのが定石と思われる【推論】。

### Gaps
- 「weighted rewards」（所持カード/タグに応じた報酬重み付け）を公式に採用しているタイトルの一次仕様は今回未確認（StS1 は報酬がキャラプール内ランダムでアーキタイプ重み付けはないと一般に言われるが【未検証】）。
- リロール（Balatro の Reroll、StS の Prayer Wheel/Question Card 等）の詳細仕様は未取得。

---

## Q6. 開発者はビルド多様性をどう測定・担保しているか

### Takeaway
Mega Crit は EA 初期からメトリクスサーバーでプレイデータを自動収集し、Slack/Discord/配信者の定性フィードバックと組み合わせて毎週アップデートでバランス調整した。ただし「メトリクスは解釈を誤ると誤導する」「スーパープレイテスターのバイアス」に注意を促している。具体的なピック率/勝率の公開数値は今回得られなかった。

### Cited Findings
- Mega Crit は早期からメトリクス駆動を採用し EA を通してデータ駆動開発を継続 — [Game Developer GDC 2019 予告](https://www.gamedeveloper.com/design/learn-i-slay-the-spire-i-s-metrics-driven-approach-to-game-balancing-at-gdc-2019)
- メトリクスサーバーで受動的にデータ収集、社内 Slack でプレイテスター連携。週次アップデート、Discord、ベータブランチ、Ascension、配信者の知見をバランスに反映。メトリクスの誤読と「スーパープレイテスター」バイアスに警鐘。Defect の EA 中のバランス調整、最大のメカニクス削除をデータで判断した話も章立てにある — [Podwise 要約](https://podwise.ai/episodes/1459444)
- 「every card should have its place」— [Podwise 要約](https://podwise.ai/episodes/1459444)
- Balatro はコミュニティとの反復で戦略ゲームとして完成した — [TouchArcade](https://toucharcade.com/2024/03/18/balatro-interview-mobile-port-localthunk-dlc-plans-updates-new-jokers-demo-feedback/)
- MT2 の Dimensional Challenges はクラン組み合わせを固定してプレイさせるモード（結果的に不人気な組み合わせも遊ばせる）— [Game Informer](https://gameinformer.com/review/monster-train-2/engine-ingenuity)

### Inferences
- インディー規模で真似できる最低限の計測: ランごとに「提示されたカード/選んだカード/スキップ」「最終デッキ」「到達階」「勝敗」を送信し、(a) カード別ピック率、(b) ピック時勝率、(c) 系統（タグ）別の勝率・採用率を見る。StS 式に“提示されたのに選ばれない”カードを弱いと判断する。
- 「全カードに居場所がある」をKPI化するなら、ピック率が極端に低いカードと、採用時勝率が極端に高い系統を毎週リスト化して調整するのが現実的。
- デイリー/チャレンジでの組み合わせ固定（MT2 Dimensional Challenges、StS Daily）は、プレイヤーを不人気アーキタイプに誘導して多様性を体験させる低コスト手段。

### Gaps
- GDC 講演内の具体的グラフ（カード別ピック率等）は未取得。Shiny Shoe / Supergiant / LocalThunk のテレメトリ運用に関する一次情報は見つからず。

---

## 設計パターン一覧

### Takeaway
「1ヒーローで大きく違うビルド」を低コストで実現するなら、優先度は **(1) 開始時/Act開始時の大枠3択祝福 → (2) 系統専用スケーリング資源＋倍化 payoff → (3) ヒーロー本体の3パス×3段階強化 → (4) レア pity と系統重み付け報酬 → (5) 前提条件で出る Duo/ハイブリッド報酬** の順が費用対効果が高い（推論）。

| 仕組み | 代表例 | ビルド多様性への効果 | 実装コスト |
|---|---|---|---|
| 開始時の大枠選択（祝福/型の3択） | StS Neow・StS2 Ancients、Hades Aspect | ラン毎の方針を早期に分岐させ、同キャラでも別ゲーム化 | 低〜中 |
| メイン×サブ系統の組み合わせ | Monster Train 主＋同盟クラン（MT1: 20通り、MT2: 80通り） | 組み合わせ数を掛け算で増やす | 中（系統ごとのカード群が必要） |
| ヒーロー本体の分岐強化（3パス×3段階、混合可） | Monster Train チャンピオン（Brawler/Reaper/Wrathful 等） | AD/AP 的な役割分岐を本体で直接表現。特化と混合の両立 | 低〜中 |
| 系統専用スケーリング資源 | StS Strength/Focus/Poison/Shiv、StS2 Stars/Forge/Doom | アーキタイプの「軸」になり、カードの価値を文脈依存にする | 中 |
| 加算 → 乗算（倍化 payoff） | Balatro +Mult→xMult、StS Limit Break | 「完成した」瞬間と指数的な爽快感（壊れの源） | 低 |
| キーストーン（ビルド定義）カード/レリック | StS Corruption、Barricade【未検証】、Balatro 成長型 xMult ジョーカー | 1枚でデッキ方針を決め、ピボットのきっかけになる | 低（設計は難しい） |
| 前提条件で出現する上位報酬 | Hades Duo/Legendary Boon | コミットを促し、ハイブリッドにご褒美を用意 | 中 |
| タグ/セットボーナス | Brotato 武器タグ | 同系統を集める動機を明示的に作る | 低〜中 |
| レア度ティア＋出現重み | Balatro 70/25/5%＋Legendary 0.3%、StS 3%/10%/ボス100% | ビルドの核をレアにし“引いた時”のドーパミン | 低 |
| レア pity（不運補正） | StS オフセット -5%→+1%/コモン、上限+40% | キーカードの到来時期を平準化し“完成しないラン”を減らす | 低 |
| カード単位の付与効果 | StS2 Enchantment（Glam, Spiral, Corrupted） | 同じカードでもラン毎に別物になる | 中 |
| 除去・変換（デッキ圧縮） | StS 除去/Exhaust/Purity、StS2 Necrobinder の変換 | 無限コンボ・特化ビルドの前提を作る | 低 |
| スタック方式の使い分け | RoR2 線形/双曲/指数 | 一極集中の抑制と“リスク付き壊れ”の両立 | 低 |
| 難易度＝ビルド部品への制約 | Balatro Stake の Eternal/Perishable/Rental | パワーファンタジーを保ったまま難しくする | 低〜中 |
| 組み合わせ固定チャレンジ/デイリー | MT2 Dimensional Challenges、StS Daily | 不人気アーキタイプも遊ばせ、多様性を体験させる | 中 |
| 計算過程の演出 | Balatro のスコア積み上げ演出（事前表示なし） | 壊れビルドを「祝福される瞬間」にする | 低 |
| テレメトリ（ピック率・勝率） | Mega Crit メトリクスサーバー＋週次調整 | 死にカード/支配的アーキタイプの検出 | 中 |
