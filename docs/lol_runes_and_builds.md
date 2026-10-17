# League of Legends のルーン・ビルド・チャンピオン固有成長（デッキ構築ローグライク向けリファレンス）

調査日: 2026-10-18。目的: 「試合前に選ぶルーンで方向性が決まる」「キャラ固有の力が試合中に伸びる」という LoL の仕組みを、二度と調べ直さずに済むように事実ベースでまとめる。

- 数値の出所は主に League of Legends Wiki（wiki.leagueoflegends.com）の現行ページ（V26.x 表記。ページごとに更新時期が違い、V26.16〜V26.19 前後）。統計は lolalytics の Patch 16.20（Emerald+ / Solo-Duo / Global）。他サイトが「26.20」と書くものと同じパッチの別表記と思われる（未確認）。パッチで数値は変わるので「仕組みの例」として読むこと。
- 記号: **【事実】** 出典ページに書かれていること / **【推論】** 事実から筆者が導いたこと / **未確認** 出典を取得できなかった、またはページ内で食い違う。
- 日本語名: ルーン・系統名は日本語クライアント表記を扱うサイト（[seemeta 日本語ルーン一覧](https://seemeta.com/ja/lol/runes)）から。英語名との対応は表記から読み取ったもの。チャンピオン名のうち スレッシュ / チョ＝ガス / マスター・イー / カイ＝サ（[lolalytics 日本語](https://lolalytics.com/ja/lol/tierlist/)）、オレリオン・ソル、スモルダー、ケイル（検索結果で確認）以外は一般的な日本語表記で、今回は照合していない。
- 直接引用は最小限（1か所）。ほかは要約。
- アイテム（神話級の歴史、アイテム構造、Riot のアイテム設計目標）は既存ノートに詳しいので重複させない: [lol_itemization.md](../research_notes/ビルド多様性%20デッキ構築設計/lol_itemization.md)

---

## 1. ルーン（Runes Reforged）の構造

### 1.1 ルーンページの形

| 部品 | 内容 | 出典 |
|---|---|---|
| メイン系統（primary path） | 5系統から1つ。**キーストーン1個**＋通常ルーン3個（行ごとに1個、3行） | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) |
| サブ系統（secondary path） | メインと別の系統から**通常ルーン2個**（キーストーンは取れない）。Riot の2017年の説明では「2つの行から1個ずつ」 | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) / [Riot dev blog の転載（Surrender at 20, 2017-06）](https://www.surrenderat20.net/2017/06/red-post-collection-honor-explained.html) |
| ステータスシャード | 系統の外にある3スロット（攻撃・柔軟・防御）から各1個 | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) |

- 【事実】メイン系統は「キーストーン行（3〜4択）＋3行×3択」。キーストーンは現在**17種**（4+3+4+3+3）。 — [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends))
- 【事実】Riot は2017年の時点で「各系統に3キーストーン、計15個くらいを目指す」と述べていた（Riot Stashu）。現在は17個。 — [Surrender at 20, 2017-07](https://www.surrenderat20.net/2017/07/red-post-collection-july-bundles-runes.html)
- 【事実】サブ系統の2個は同じ系統から取る必要がある。Riot はこれを「何でも詰め込める袋ではない」と説明した（要約）。 — [Surrender at 20, 2017-06](https://www.surrenderat20.net/2017/06/red-post-collection-honor-explained.html)

### 1.2 5系統とテーマ

| 系統 | 日本語 | Wiki のテーマ文（要約） | キーストーン数 |
|---|---|---|---|
| Precision | 栄華 | 攻撃の強化と持続ダメージ | 4 |
| Domination | 覇道 | バースト（瞬間火力）と標的への到達 | 3 |
| Sorcery | 魔道 | スキルの強化とリソース操作 | 4 |
| Resolve | 不滅 | 耐久とクラウドコントロール | 3 |
| Inspiration | 天啓 | 独創的な道具とルール曲げ | 3 |

出典: [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends))（テーマ・数）、[seemeta 日本語](https://seemeta.com/ja/lol/runes)（日本語名）。

通常ルーンの各行（現行。日本語名は seemeta の並びから対応を推定）:

| 系統 | 1行目 | 2行目 | 3行目 |
|---|---|---|---|
| 栄華 | Triumph（凱旋）/ Absorb Life（体力吸収）/ Presence of Mind（冷静沈着） | Legend: Alacrity（迅速）/ Haste（ヘイスト）/ Bloodline（血脈） | Coup de Grace（最期の慈悲）/ Cut Down（切り崩し）/ Last Stand（背水の陣） |
| 覇道 | Cheap Shot / Taste of Blood（血の味わい）/ Sudden Impact（サドンインパクト） | Sixth Sense（第六感）/ Grisly Mementos（グリスリー メメント）/ Deep Ward（ディープワード） | Treasure Hunter / Relentless Hunter（執拗な賞金首狩り）/ Ultimate Hunter（至極の賞金首狩り） |
| 魔道 | Axiom Arcanist（アクシオム アルカニスト）/ Manaflow Band / Nimbus Cloak | Transcendence / Celerity / Absolute Focus | Scorch / Waterwalking / Gathering Storm（強まる嵐） |
| 不滅 | Demolish（打ちこわし）/ Font of Life（生命の泉）/ Shield Bash | Conditioning / Second Wind / Bone Plating | Overgrowth（超成長）/ Revitalize / Unflinching（気迫） |
| 天啓 | Hextech Flashtraption / Magical Footwear / Cash Back | Triple Tonic / Time Warp Tonic / Biscuit Delivery | Cosmic Insight / Approach Velocity / Jack of All Trades（なんでも屋） |

出典: [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends))。

### 1.3 ステータスシャード（現行）

| スロット | 選択肢 |
|---|---|
| 1（攻撃） | 適応型 5.4 追加AD または 9 AP / 攻撃速度 10% / スキルヘイスト 8 |
| 2（柔軟） | 適応型 / 移動速度 2.5% / 体力（レベルで 10〜200） |
| 3（防御） | 体力 65 / 行動妨害耐性・スロウ耐性 15% / 体力（レベルで 10〜200） |

- 【事実】シャードは V8.23 で追加（同時に系統の組み合わせ特性ボーナスを廃止）。V25.22 で移動速度 2%→2.5%、テナシティ 10%→15%。 — [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends))
- 【事実】「適応型（Adaptive）」は AD と AP のうち装備で多い方に自動で振られる。Riot は2017年に、ビルド違いのチャンピオンが余計なステータスを受け取らずに自分向けのルーンを使えるようにする狙いと説明した（要約）。 — [Surrender at 20, 2017-07](https://www.surrenderat20.net/2017/07/red-post-collection-runes-content.html)

### 1.4 Riot がこの形にした理由（開発者発言）

| 発言（要約） | 発言者・時期 | 出典 |
|---|---|---|
| ルーンとマスタリーを1つの簡潔なシステムに統合する。ルーンは自分の目標とプレイスタイルを決めるためのもの。直接引用: "These Runes help you set your own goals and define your own playstyle." | Riot dev blog「Runes Reforged: Picking your playstyle」2017-06 | [Surrender at 20 転載](https://www.surrenderat20.net/2017/06/red-post-collection-honor-explained.html) |
| 最も強いスロットがキーストーン。メイン系統には小さなステータス効果があり、キャラクターの手触りを方向付ける（例: 栄華は少しの攻撃速度） | 同上 | 同上 |
| 一部のルーンは特定のチャンピオンにとって最適になることを想定している（Riot Reinboom） | 同上コメント | 同上 |
| ルーンは1つ1つの効果に集中した力を持たせた。キーストーン方式のマスタリーは今回の実験台だった。事前の選択を支えるには9キーストーンでは足りないと分かった（Riot Reinboom） | 2017-07 | [Surrender at 20](https://www.surrenderat20.net/2017/07/red-post-collection-runes-content.html) |
| ルーンはロード画面で固定されるので、試合中の変化に頼れない。アイテムは相手を見て調整できる、という対比（Reinboom の発言の要約） | 2017-07 | 同上 |
| 覇道は「リードを雪だるま式に伸ばす」系統。3つのキーストーンはそれぞれ、雪だるま・狩り・バーストのどれかを体現する（Riot Stashu） | 2017-07 | [Surrender at 20](https://www.surrenderat20.net/2017/07/red-post-collection-july-bundles-runes.html) |
| キーストーンの力には代償（機会費用）が伴うべき。例として、狩り系を取ったタンクは倒されやすくなる（Stashu、要約） | 同上 | 同上 |
| キーストーンの守護系（Guardian）は、ウォーデンやエンチャンター向けに味方を守る手段として作った（gregab、要約） | 2017-08 | [Surrender at 20](https://www.surrenderat20.net/2017/08/red-post-collection-pbe-livestream.html) |
| 全ルーンを無料にしたのは、全員に同じ選択肢を与え、その前提でバランスを取れるようにするため（要約） | Riot 技術振り返り | [Riot: Runes Reforged technical retro](https://www.riotgames.com/en/news/runes-reforged-technical-retro) |
| 2018年1月の振り返り: ステータスボーナスが系統の選択肢を狭めていた（例: ファイターが攻撃速度を嫌って栄華を避ける）。不滅（Resolve）はスクイッシーが取りにくい（検索結果の要約経由） | Riot Nexus 2018-01 | [Dev update on Runes Reforged](https://nexus.leagueoflegends.com/en-us/2018/01/dev-update-on-runes-reforged/)（現在はリダイレクトされ本文未確認） |

### 1.5 「試合前に選ぶ」ことの意味【推論】

- ルーンは試合開始前に確定し、試合中は変えられない（Reinboom の対比より）。つまり**開始1分目から「このキャラは今日こう戦う」という方向性が存在する**。アイテムは相手を見て変えられるが、ルーンは変えられない、という役割分担になっている。
- 方向性を作る要素は、キーストーン（戦い方の型）＞通常ルーン（成長・利便性）＞シャード（数値の微調整）の順に重い。デッキ構築ローグライクの「開始時の1つの大きな選択」に直接対応する。
- Riot は2022年末のパッチ（V12.23）でルーン推奨機能を導入し、プリセットページを廃止した。選択肢が多いので「推奨」を出す必要があった、という運用上の事実。 — [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends))
- 既存ノートによれば、プレイヤーの約68%が推奨アイテムを主な導線にしていた。ルーンでも同じ傾向があるかは未確認。 — [lol_itemization.md](../research_notes/ビルド多様性%20デッキ構築設計/lol_itemization.md)

### 1.6 変遷（直近の変更だけ）

| パッチ | 変更 | 出典 |
|---|---|---|
| V7.22 | Runes Reforged が本番に実装（Pre-Season 2018 の目玉）。既存のルーンページは移行 | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) |
| V14.10 | Absorb Life / Cash Back / Jack of All Trades / Legend: Haste を追加。Lethal Tempo など7個を削除 | 同上 |
| V14.19 | Lethal Tempo を新効果で再追加 | 同上 |
| V25.S1.1（2026シーズン開幕パッチの表記。日付は未確認） | 追加: Axiom Arcanist / Deep Ward / Grisly Mementos / Sixth Sense。削除: Eyeball Collection / Ghost Poro / Nullifying Orb / Zombie Ward | 同上 |
| V26.09（2026年4月下旬。Season 2 開始期） | キーストーン Phase Rush を削除し Stormraider's Surge に置換。Deathfire Touch を魔道のキーストーンとして追加（どちらも Season 6 のマスタリーの復活） | [Wiki: Phase Rush](https://wiki.leagueoflegends.com/en-us/Phase_Rush) / [Wiki: Stormraider's Surge](https://wiki.leagueoflegends.com/en-us/Stormraider%27s_Surge) / [Wiki: Deathfire Touch](https://wiki.leagueoflegends.com/en-us/Deathfire_Touch) / [esports.gg](https://esports.gg/news/league-of-legends/deathfire-touch-stormraiders-surge-returns-in-lol-2026-season-2/)（本文は取得できず、検索結果の要約経由） |

---

## 2. 現行キーストーン一覧（17種）

数値は各 Wiki ページの現行説明（V26.16〜V26.19 前後）。「報いるプレイ」は効果から読める遊び方で【推論】を含む。

| キーストーン | 系統 | 効果（要約） | 報いるプレイ |
|---|---|---|---|
| 征服者（[Conqueror](https://wiki.leagueoflegends.com/en-us/Conqueror)） | 栄華 | 敵チャンピオンへのダメージでスタック（最大12、5秒で更新）。1スタックごとに適応型 1.08〜2.56 AD / 1.8〜4.26 AP。最大で与ダメの一部を回復（近接8%・遠隔5%） | **長い殴り合い**で力が積み上がる。短い小競り合いでは弱い |
| リーサルテンポ（[Lethal Tempo](https://wiki.leagueoflegends.com/en-us/Lethal_Tempo)） | 栄華 | チャンピオンへの通常攻撃でスタック（最大6、6秒）。1スタックにつき攻撃速度 +6%（近接）/+4.8%（遠隔）。最大時は通常攻撃が追加の弾を撃つ。V14.10 で一度削除、V14.19 で新効果で復活 | **撃ち続ける**通常攻撃主体（AD の射手など） |
| プレスアタック（[Press the Attack](https://wiki.leagueoflegends.com/en-us/Press_the_Attack)） | 栄華 | チャンピオンへの通常攻撃3回（4秒以内）で 40〜174.12 の適応ダメージ＋その敵への与ダメ +8%（戦闘を離れて5秒まで）。CD 6秒 | **短い交換**でダメージを前借りする。レーンの小競り合い向き |
| フリートフットワーク（[Fleet Footwork](https://wiki.leagueoflegends.com/en-us/Fleet_Footwork)） | 栄華 | チャージが100になると次の通常攻撃が回復＋短い移動速度上昇（回復は近接 15〜182.73。履歴の V26.16 の記載は 15〜160 で食い違い）。V26.16 で基礎回復を増加 | **削り合いで耐える**・粘るレーン戦 |
| 電撃（[Electrocute](https://wiki.leagueoflegends.com/en-us/Electrocute)） | 覇道 | 3ヒット（3秒以内）で 70〜260 ＋10%追加AD＋5%AP の適応ダメージ。CD 20秒（ページ内で 70〜240 との食い違いあり） | **3発を素早く当てる**バースト型（アサシン、メイジ） |
| 魂の収穫（[Dark Harvest](https://wiki.leagueoflegends.com/en-us/Dark_Harvest)） | 覇道 | HP50%未満のチャンピオンに追加ダメージ（30 + 魂1つにつき11 ＋10%追加AD＋5%AP）。発動で魂を1つ得て、CD 35秒（キル/アシストで1秒に短縮） | **とどめを刺す**・スノーボール。魂が溜まるほど強い |
| ヘイルブレード（[Hail of Blades](https://wiki.leagueoflegends.com/en-us/Hail_of_Blades)） | 覇道 | 敵チャンピオンへの攻撃開始で2スタック（3秒）。攻撃速度 +90%（近接）/+60%（遠隔）で上限を超えられる。CD 10秒。V26.16 で攻撃速度を下げ、AD/AP 係数を上げた | **初撃から全力**の突っ込み。一気に削るバースト |
| エアリー召喚（[Summon Aery](https://wiki.leagueoflegends.com/en-us/Summon_Aery)） | 魔道 | 敵チャンピオンへ10〜54.71の適応ダメージ、または味方へのシールド（20〜109.41）。スキルが味方に回復・シールド・強化を与えると味方へ飛ぶ | **ポーク**（遠隔削り）とエンチャンター（味方を強化するサポート） |
| 秘儀の彗星（[Arcane Comet](https://wiki.leagueoflegends.com/en-us/Arcane_Comet)） | 魔道 | スキルが当たると、その位置に遅れて彗星が落ちる（15〜110 ＋10%追加AD＋5%AP、距離で最大2倍）。V26.09 で距離ボーナスを追加、スキルダメージによるCD短縮を廃止 | **遠くから当てる**ポーク。射程の長いメイジ |
| 嵐乗りの勇躍（[Stormraider's Surge](https://wiki.leagueoflegends.com/en-us/Stormraider%27s_Surge)） | 魔道 | 3秒で敵チャンピオンの最大HPの25%相当を与えると、移動速度（近接48%/遠隔36%、4秒）とスロウ耐性50%。CD 20〜8.82秒 | **追い込みと逃げ**。アサシン、ブルーザー |
| 死神の残り火（[Deathfire Touch](https://wiki.leagueoflegends.com/en-us/Deathfire_Touch)） | 魔道 | スキル/ペットのダメージで敵に火傷（0.5秒ごと 1.5〜6.53 ＋3.5%追加AD＋1.25%AP の魔法ダメージ。3秒続くと+75%）。V26.11 で適応→魔法ダメージに変更 | **多段のスキル連打**・継続ダメージ |
| 不死者の握撃（[Grasp of the Undying](https://wiki.leagueoflegends.com/en-us/Grasp_of_the_Undying)） | 不滅 | 強化通常攻撃が最大HPの3.5%（近接）/1.4%（遠隔）の魔法ダメージ、1.3%/0.52% の回復、**最大HP +5/+2 を永続**で得る | **繰り返し殴り合う**タンク・ブルーザー |
| アフターショック（[Aftershock](https://wiki.leagueoflegends.com/en-us/Aftershock)） | 不滅 | 敵をCCで拘束すると、追加防御（45 ＋75%追加防具）を2.5秒得て、終了時に周囲へ衝撃波（25〜120 ＋8%追加HP）。CD 20秒 | **エンゲージ**（突っ込み役）のタンク |
| ガーディアン（[Guardian](https://wiki.leagueoflegends.com/en-us/Guardian_(Rune)) ） | 不滅 | 自分か近くの味方が一定ダメージ（50〜178.53）を受けると、自分と対象にシールド（40〜162.94 ＋20%AP ＋6%追加HP）。CD 75〜約36秒（V26.11 で調整） | **味方を守る**サポート |
| グレイシャルオーグメント（[Glacial Augment](https://wiki.leagueoflegends.com/en-us/Glacial_Augment)） | 天啓 | 敵をCCで拘束すると氷の光線3本が飛び、氷のゾーン（3秒＋拘束時間）が生まれて減速（20% ＋AD/AP/回復力ボーナス）。CD 25秒 | **CCの多い**メイジ・サポート |
| 解放の魔導書（[Unsealed Spellbook](https://wiki.leagueoflegends.com/en-us/Unsealed_Spellbook)） | 天啓 | 6:00以降、戦闘を離れて5秒で、サモナースペルを使い切りの別のものに交換できる（交換CD 270秒から、種類ごとに25秒短縮、最短120秒） | **状況に応じて切り替える**プレイ。知識量がものを言う |
| ファーストストライク（[First Strike](https://wiki.leagueoflegends.com/en-us/First_Strike)） | 天啓 | 先に敵チャンピオンへ攻撃すると10ゴールドと3秒間の追加真ダメージ（7%）。与えた追加ダメージの50%（近接）/35%（遠隔）がゴールドに。CD 25〜15秒（Wiki の最新履歴は V14.12） | **先制ポーク**・序盤の優位 |

- 【推論】17個を「長期戦（征服者、握撃）」「短期バースト（電撃、ヘイルブレード、PTA）」「ポーク（彗星、エアリー、FS）」「機動（嵐乗り、フリート）」「CC連動（アフターショック、グレイシャル）」「味方支援（ガーディアン、エアリー）」「実験枠（解放の魔導書）」に分けると、**戦い方の型**がほぼ重ならないように設計されていることが分かる。
- 【事実】数値調整は頻繁。各 Wiki ページの履歴に V25.S1.3〜V26.16 の変更が載っているのは、PTA、電撃、魂の収穫、ヘイルブレード、エアリー、彗星、握撃、アフターショック、ガーディアン、フリートの10個に加え、新規の嵐乗り・死神の残り火の計12個。

---

## 3. ゲーム中に成長・スタックするルーン

### 3.1 一覧

| ルーン | 何が育つか | 育てる行動 | 上限 | 出典 |
|---|---|---|---|---|
| 魂の収穫（Dark Harvest） | 追加ダメージが魂1つにつき +11 | 発動のたびに魂+1（CD 35秒。キル/アシストで1秒に短縮） | 上限なし（Wiki 記載なし） | [Wiki](https://wiki.leagueoflegends.com/en-us/Dark_Harvest) |
| 征服者（Conqueror） | 戦闘中に適応型 AD/AP が最大12スタック | 敵チャンピオンへダメージ（近接は通常攻撃で2スタック） | 12スタック（5秒で消える短期成長） | [Wiki](https://wiki.leagueoflegends.com/en-us/Conqueror) |
| リーサルテンポ（Lethal Tempo） | 攻撃速度 | チャンピオンへ通常攻撃 | 6スタック（6秒） | [Wiki](https://wiki.leagueoflegends.com/en-us/Lethal_Tempo) |
| 強まる嵐（Gathering Storm） | 適応型 AP/AD（時間経過） | **何もしなくても**10分ごと。10分: 8 AP/4.8 AD、20分: 24/14.4、30分: 48/28.8、40分: 80/48、60分: 168/100.8（累計。Wiki の表を10分刻みで換算） | **上限なし** | [Wiki](https://wiki.leagueoflegends.com/en-us/Gathering_Storm) |
| レジェンド: 迅速（Alacrity） | 攻撃速度 3% ＋ スタック毎 1.5% | レジェンドポイント（100点で1スタック）。チャンピオンのキル/アシスト100点、エピックモンスター100点、大型モンスター25点、ミニオン4点 | 10スタックで 18% | [Wiki](https://wiki.leagueoflegends.com/en-us/Legend:_Alacrity) |
| レジェンド: ヘイスト（Haste） | スキルヘイスト（1スタック 1.5） | 同上 | 10スタックで 15（V14.10 追加） | [Wiki](https://wiki.leagueoflegends.com/en-us/Legend:_Haste) |
| レジェンド: 血脈（Bloodline） | ライフスティール（1スタック 0.45%）と最大HP | 同上 | 15スタックで 6.75% ＋ 体力85 | [Wiki](https://wiki.leagueoflegends.com/en-us/Legend:_Bloodline) |
| 賞金首狩り系（Treasure Hunter） | ゴールド | 異なるチャンピオンのキル/アシスト（1人1回）。1〜5人目で 50/70/90/110/130 ゴールド | 合計 450 ゴールド（5人） | [Wiki](https://wiki.leagueoflegends.com/en-us/Treasure_Hunter) |
| 至極の賞金首狩り（Ultimate Hunter） | ウルトのスキルヘイスト（6 ＋ スタック毎 5） | 異なるチャンピオンへのテイクダウン | 5スタックで 31 | [Wiki](https://wiki.leagueoflegends.com/en-us/Ultimate_Hunter) |
| 執拗な賞金首狩り（Relentless Hunter） | 戦闘外の移動速度（スタック毎 8） | 同上 | 5スタックで 40 | [Wiki](https://wiki.leagueoflegends.com/en-us/Relentless_Hunter) |
| グリスリー メメント（Grisly Mementos） | トリンケットヘイスト（1スタック 6） | チャンピオンのテイクダウン | 18スタックで 108（V25.S1.1 追加、25.S1.2 で調整） | [Wiki](https://wiki.leagueoflegends.com/en-us/Grisly_Mementos) |
| Eyeball Collection | （旧）目玉スタックでAD/AP | チャンピオンのテイクダウン | **V25.S1.1 で削除**。後継との対応は未確認 | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) |
| 超成長（Overgrowth） | 最大HP | 近くで8体のミニオン/モンスターが死ぬごとに1スタック（+3 HP）。15スタックで最大HP +3.5% | スタック数に上限なし | [Wiki](https://wiki.leagueoflegends.com/en-us/Overgrowth) |
| 不死者の握撃（Grasp） | **永続**の最大HP（+5/+2） | 強化通常攻撃を当てる | 上限の記載なし | [Wiki](https://wiki.leagueoflegends.com/en-us/Grasp_of_the_Undying) |
| なんでも屋（Jack of All Trades） | スキルヘイスト・適応型 | 装備が持つステータスの種類の数だけスタック。5スタックで 8 AP/4.8 AD、10スタックで 20 AP/12 AD | 10スタック（V26.15 で下方修正） | [Wiki](https://wiki.leagueoflegends.com/en-us/Jack_of_All_Trades) |
| アクシオム アルカニスト（Axiom Arcanist） | ウルトのダメージ +12% ＋ キルで ウルトCD -7% | チャンピオンのテイクダウン | 上限なし（スタックではなく毎回効く） | [Wiki](https://wiki.leagueoflegends.com/en-us/Axiom_Arcanist) |

注記: 「ゴールドや回復を得る」類（First Strike の稼ぎ、Dark Harvest の魂）は【事実】、**他の稼ぎ・成長手段との相互作用の評価は【推論】**。

### 3.2 「スノーボール感」を作る仕組み【推論】

- **見えるカウンタ**: 魂・レジェンド・グリスリー メメントなど、数えられる単位がある。進捗が見えるので「あと1回で次の段階」が欲しくなる。
- **成長の入り口が2種類**: 行動で伸びるもの（魂の収穫、レジェンド、賞金首狩り）と、時間で伸びるもの（強まる嵐）。後者は活躍できなかった側にも一定の追い上げを与える。
- **短期成長と永続成長の使い分け**: 征服者・リーサルテンポは戦闘ごとにリセットされる短期。握撃・超成長・メメントは試合を通して残る永続。
- **上限の有無**: 強まる嵐・超成長・魂の収穫には上限の記載がない。一方で征服者（12）、レジェンド（10〜15）、賞金首狩り（5人）には小さな上限がある。**「天井が低い成長は頻繁に満タンになる」「天井がない成長は試合が長いほど強い」**という違いが、ルーンの個性になっている。
- **勝っている側が有利**: 魂の収穫・賞金首狩り・テイクダウン系は、先にキルを取った側がさらに伸びる（正のフィードバック）。ファーストストライクも先制した側にゴールドが入る。逆転用の仕組みは強まる嵐（時間）ぐらいしか見当たらない。

---

## 4. キャラ固有の力が伸びる仕組み（チャンピオン固有スケーリング）

各チャンピオンのスキルやパッシブが、試合中に永続的に強くなる例。数値は Wiki の現行ページ。ここでの「好まれる理由」は【推論】。

### 4.1 一覧

| チャンピオン | 何が伸びるか | 伸ばす行動 | 解禁・変化するもの | 好まれる理由【推論】 |
|---|---|---|---|---|
| ベイガー（Veigar） | 1スタックにつき 1 AP（永続） | スキルがチャンピオンに当たる（1スタック。ダメージを与えなくても可）、チャンピオンのテイクダウン（+5）、Q（ミニオンを倒すと1、大型は3、チャンピオン撃破は7相当） | 上限の記載なし。Wiki は無限に伸びると説明 — [Wiki: Veigar](https://wiki.leagueoflegends.com/en-us/Veigar) | 毎ミニオンの小さな積み上げが、後半の一撃に化ける。「farm の成果」が目で見える |
| ナサス（Nasus） | Q の追加ダメージ（スタック数の100%＋基礎値） | Q の強化攻撃でキルを取る（通常4、チャンピオン・大型ミニオン・大型モンスターは10） | 上限の記載なし。R で巨大化（HP +300〜600 など） — [Wiki: Nasus](https://wiki.leagueoflegends.com/en-us/Nasus) | 「Q で刈る」という1つの動作が成長に直結する。遅いが確実 |
| セナ（Senna） | 1スタックにつき +0.75 追加AD。20スタックごとに射程 +20 とクリティカル率 +10% | 敵やミニオンが死ぬと出る霧の亡霊を攻撃して解放（Q も当たる）。通常攻撃や命中でも霧が溜まる | 100%超のクリ率はライフスティールに変換。上限の記載なし — [Wiki: Senna](https://wiki.leagueoflegends.com/en-us/Senna) | 戦闘以外（ミニオン亡霊の回収）でも成長でき、サポートでも伸びる |
| スレッシュ（Thresh） | 魂1つにつき 1 AP と 1 追加防具 | チャンピオン・大型ミニオン・大型モンスターの死亡時に出る魂（8秒）を回収。エピックは2個、小型は33.3%で出る | 上限の記載なし。ランタンの近くでも回収 — [Wiki: Thresh](https://wiki.leagueoflegends.com/en-us/Thresh) | 地味な「拾う」行動で、サポートが固くなる |
| キンドレッド（Kindred） | Mark 1つごとに永続強化（ラムの射程 75〜250、E の追加攻撃速度、狼の%現在HPダメージ） | ラムは敵チャンピオンを標的に選び、狩りを成功させる。狼は敵ジャングルの大型モンスターが標的（2:53から） | スタックが増えると狼の標的が大型化（0〜8+で Rift Scuttler から Baron/Dragon まで） — [Wiki: Kindred](https://wiki.leagueoflegends.com/en-us/Kindred) | 狩りの標的がマップに表示される「ミッション」形式。進行が物語化される |
| スモルダー（Smolder） | Q のダメージ（スタックの25〜60%の追加魔法ダメージ）と見た目 | スキルをチャンピオンに当てる、Q でミニオン/モンスターを倒す | 25スタック: 着弾で爆発、125: 追加の火炎弾、225: 燃焼＋チャンピオン処刑（最大HPの6.5%未満）— [Wiki: Smolder](https://wiki.leagueoflegends.com/en-us/Smolder) | 段階解禁（25/125/225）が分かりやすい節目になる |
| チョ＝ガス（Cho'Gath） | R（Feast）のスタック毎に追加HP 80/120/160、巨大化（上限+100%）、攻撃射程 | R で敵を食べて倒す（非エピックのモンスター・ミニオンからは最大6スタックまで） | 上限は HP にはなし、サイズ・射程に上限あり — [Wiki: Cho'Gath](https://wiki.leagueoflegends.com/en-us/Cho%27Gath) | 画面上で**体が大きくなる**。成長が文字通り目に見える |
| サイオン（Sion） | 最大HP（キル毎に+4、大型・チャンピオンは+15）、W のシールド量（最大HP比例） | 敵のキル（W を習得してから） | 上限の記載なし。死亡後も一定時間動けるパッシブ — [Wiki: Sion](https://wiki.leagueoflegends.com/en-us/Sion) | 「死なない壁」が育つ。HP がそのまま火力（W）にもなる |
| バード（Bard） | チャイム毎に移動速度・ミープの数・ミープのダメージ・スロウ | マップ上のチャイムを集める | 5個ごとにミープ強化。ミープ上限は100個で9。スロウは25%→75%（85個）— [Wiki: Bard](https://wiki.leagueoflegends.com/en-us/Bard) | 「集める」がそのまま役割（遊び）になる |
| ケイン（Kayn） | 形態（Rhaast / Shadow Assassin） | 近接の敵に与えたダメージは赤いオーブ、遠隔は青いオーブ。500点で満タン | 最初に満タンにした形態に変身（変身は拠点付近で6秒）。もう一方は4分後に解禁 — [Wiki: Kayn](https://wiki.leagueoflegends.com/en-us/Kayn) | 「誰を殴ったか」で自分の姿が決まる。ビルドが戦いから生まれる |
| カイ＝サ（Kai'Sa） | スキルの進化（装備由来の AD / AP / 攻撃速度の閾値） | 装備を買う | Q は AD 100、W は AP 100、E は攻撃速度100%で進化 — [既存ノート Q1](../research_notes/ビルド多様性%20デッキ構築設計/lol_itemization.md) | 買い物で「進化」が起きる離散スイッチ |
| オレリオン・ソル（Aurelion Sol） | Stardust（永続）— Q のダメージ、W の射程（1スタック 7.5）、E の半径と処刑閾値、R の範囲 | スキルを敵に当てる（Q は 1回 2、E は1秒ごとに1、R は1体 5 など） | 75スタックで R が「天が降る」形態に変化 — [Wiki: Aurelion Sol](https://wiki.leagueoflegends.com/en-us/Aurelion_Sol) | スキル範囲が目に見えて広がる |

- 【事実】ベイガーの W のクールダウンもスタックで短縮されると Wiki の要約にあるが、現行の仕様かは未確認（再確認推奨）。
- 【事実】スモルダーの閾値はページ内に「125で追加弾」とあり、「ダブルブレス」の記述はない。
- 【事実】キンドレッドのクエスト値（75秒、4分など）は Wiki と Wild Rift で異なるので別物として扱うこと。 — [検索結果より](https://wiki.leagueoflegends.com/en-us/WR:Kindred)

### 4.2 設計上の論点

- 【事実】Riot のレッドポスト（2011年、Morello）は、ナサスとベイガーの上限なしの farm 成長について、バランスを取りづらく、最良と最悪の差が大きすぎるため、上限なしのままにはしておけないと述べた（要約）。しかし2026年現在も両者のスタックに上限の記載はない。 — [Surrender at 20: Nasus and Veigar's "Stat Farming" (2011)](https://surrenderat20.net/2011/06/nasus-and-veigars-farming-skills.html) / 上の Wiki ページ
- 【事実】2022年に Riot は、パイクの R の処刑ライン（チャンピオンを処刑できる HP）を、あらゆる処刑で無限に伸ばす実験を PBE に出すと予告した（「とても実験的」と本人が表現）。 — [Dexerto FR](https://www.dexerto.fr/league-of-legends/lol-buff-pyke-pbe-1480811/)（二次情報）
- 【推論】成長型のキットは、**成長の入り口を限定する**（チョ＝ガスは非エピックから最大6スタックまで、ケインは500点の枠）と暴走しにくい。無限に伸びる系は、他の部分を弱く作る必要がある（二次情報から読み取れる範囲）。
- 【推論】好まれやすい成長は、①画面に現れる（体が大きくなる、射程が伸びる、ミープが増える）、②節目がある（25/125/225、5チャイム）、③行動がシンプル（刈る、拾う、食べる）のいずれかを満たす。

---

## 5. 1試合のビルドの流れ

### 5.1 時系列

| 段階 | 起きること | 根拠 |
|---|---|---|
| 0. 試合前 | ルーンとサモナースペルを確定（試合中は変更不可） | [Wiki: Rune](https://wiki.leagueoflegends.com/en-us/Rune_(League_of_Legends)) / 1.5 |
| 1. 開始 | スターターアイテムを買う。Doran 系（Blade / Ring / Shield / Helm / Bow）、ジャングル用ペット（Gustwalker Hatchling / Mosstomper Seedling / Scorchclaw Pup）、サポート用 World Atlas | [Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends)) |
| 2. ロールクエスト | サポート: World Atlas → Runic Compass（クエスト達成）→ Bounty of Worlds → **5択の完成品**（Bloodsong / Celestial Opposition / Dream Maker / Solstice Sleigh / Zaz'Zak's Realmspike）へ無料で変身。ミッド: ブーツが Tier3 に強化。ボット/サポートのクエスト達成で追加アイテム枠 | [Wiki: World Atlas](https://wiki.leagueoflegends.com/en-us/World_Atlas) / [Runic Compass](https://wiki.leagueoflegends.com/en-us/Runic_Compass) / [Bounty of Worlds](https://wiki.leagueoflegends.com/en-us/Bounty_of_Worlds) / [Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends)) |
| 3. 最初の帰還（first back） | お金が貯まったら拠点に戻り、部品アイテムとポーション等を買う。**「first back」はコミュニティ用語で、公式の定義は未確認**。Recall は 0.5秒の詠唱＋8秒のチャネル（割り込まれる） | [Wiki: Recall](https://wiki.leagueoflegends.com/en-us/Recall) |
| 4. 最初の完成アイテム | 神話級廃止後も、最初に完成させるアイテムがビルドを決める、という解説（二次情報） | [dodge.gg](https://www.dodge.gg/en-US/lol/news/best-mythic-items-2026) |
| 5. コア2〜3個＋ブーツ | 統計上、2〜3個目までは固定に近く、4個目から選択肢が分かれる（下記の例） | [lolalytics](https://lolalytics.com/lol/ezreal/build/?lane=bottom) |
| 6. 4〜6個目 | 相手構成や状況で選ぶ。例: タンクが多ければ貫通、MR が多ければ魔法貫通、回復が多ければ回復阻害（Oblivion Orb → Morellonomicon）、暗殺者対策に Zhonya's | [ARAMonly: AP Lucian](https://www.aramonly.com/guide/lucian/ap-build/)（ARAM 向けガイド。考え方の例）/ 既存ノート Q2 |

- 【事実】サポートクエストの必要ゴールドは World Atlas のページでは「400ゴールド」、Runic Compass のページでは「800ゴールド」と書かれ、食い違う（別段階の値の可能性。未確認）。
- 【事実】Bloodsong は V26.12 でスターターアイテムのグループに移った。「スターター1個とスペルブレード1個」までという制限がある。 — [Wiki: Bloodsong](https://wiki.leagueoflegends.com/en-us/Bloodsong)
- 【事実】アイテムの階層（Basic→Epic→Legendary）、ブーツ、6枠、神話級の導入と廃止は [lol_itemization.md](../research_notes/ビルド多様性%20デッキ構築設計/lol_itemization.md) を参照。

### 5.2 通常のビルド（ADC ルシアン）

lolalytics Patch 16.20（Emerald+）の ボット ルシアン（勝率 50.68%、172,893 ゲーム）:

| 段階 | 内容 | 出典 |
|---|---|---|
| スターター | Doran's Blade ＋ Health Potion（51.35%） | [lolalytics](https://lolalytics.com/lol/lucian/build/?lane=bottom) |
| 1〜2個目 | Essence Reaver → Navori Flickerblade。ブーツは Gluttonous Greaves | 同上 |
| 4個目 | Infinity Edge（55.95%、70,212ゲーム）／ The Collector | 同上 |
| 5個目 | Lord Dominik's Regards（60.38%）／ Black Cleaver ／ Immortal Shieldbow | 同上 |
| 6個目 | Guardian Angel（60.82%）／ LDR ／ Mercurial Scimitar | 同上 |

- 【推論】後ろの枠ほど勝率が高いのは、試合が長く続いて6個揃う側（有利側）が選ばれた選択バイアスで、アイテム自体が強いという証拠ではない。

### 5.3 同じチャンピオンがビルドで分かれる例（lolalytics Patch 16.20）

| チャンピオン | レーン別の割合 | 例1（主流） | 例2（別ビルド） | 分かれる理由（係数） |
|---|---|---|---|---|
| エズリアル（Ezreal） | ボット 94.3% / ミッド 2.9% | ボット（勝率47.56%、224,113G）: Doran's Blade → Trinity Force → Manamune → Gluttonous Greaves → Endless Hunger / Spear of Shojin → … AD+マナ型 | ミッド（勝率44.83%、6,862G）: Hextech Gunblade → Lich Bane → Sorcerer's Shoes → Rabadon's / Shadowflame … AP 寄り | 係数の詳細は未取得（AD と AP の両係数を持つキット。[Wiki: Ezreal](https://wiki.leagueoflegends.com/en-us/Ezreal) 未確認） — [lolalytics ボット](https://lolalytics.com/lol/ezreal/build/?lane=bottom) / [ミッド](https://lolalytics.com/lol/ezreal/build/?lane=middle) |
| ケイル（Kayle） | トップ 77.7% / ミッド 19.5% | トップ（勝率53.18%、45,857G）: Nashor's Tooth → Rabadon's Deathcap → Dusk and Dawn / Guinsoo's Rageblade → Shadowflame / Lich Bane / Void Staff … **オンヒット＋AP** | ミッド（勝率51.2%、11,533G）: 同じく Nashor's Tooth → Rabadon's Deathcap … | Q は追加AD 60% ＋ AP 50%、E のオンヒットは追加AD 10% ＋ AP 20%、R は追加AD 100% ＋ AP 70%。Lv6/11/16 で形態が変わる（既存ノート Q1）— [lolalytics トップ](https://lolalytics.com/lol/kayle/build/?lane=top) / [ミッド](https://lolalytics.com/lol/kayle/build/?lane=middle) |
| マルファイト（Malphite） | トップ 79.0% / ミッド 8.9% / ジャングル 8.4% / サポート 3.5% | トップ（勝率53.58%、148,145G）: Doran's Ring → Sunfire Aegis → Frozen Heart → Thornmail / Jak'Sho … **タンク**。キーストーンは Summon Aery | ミッド（勝率53.23%、16,609G）: Grasp ＋ Sunfire Aegis → Thornmail → Frozen Heart / Stormsurge → Zhonya's / Shadowflame → Rabadon's … **タンク＋AP**。サポート（勝率47.8%）: Zaz'Zak's Realmspike → Malignance → … | E は AP 60% ＋ 防具 40%、Q は AP 60%、R は AP 90%、パッシブのシールドは最大HP 10%（既存ノート Q1）— [トップ](https://lolalytics.com/lol/malphite/build/?lane=top) / [ミッド](https://lolalytics.com/lol/malphite/build/?lane=middle) / [サポート](https://lolalytics.com/lol/malphite/build/?lane=support) |
| ヴァルス（Varus） | ボット 70.4% / トップ 23.4% / ミッド 5.5% | ボット（勝率49.55%、54,172G）: Doran's Bow → Statikk Shiv → Guinsoo's Rageblade → Terminus **オンヒット/クリ型** | ミッド（勝率48.21%、4,248G）: Statikk Shiv → Dusk and Dawn → Terminus / Nashor's Tooth → Shadowflame / Zhonya's / Rabadon's … **AP/オンヒット混合** | Q は追加ADのみ（ポーク）、W のオンヒットは追加AD 15% ＋ AP 25%、Blight は AP 100%毎+1.3%最大HP、R は AP 100%（既存ノート Q1）— [ボット](https://lolalytics.com/lol/varus/build/?lane=bottom) / [ミッド](https://lolalytics.com/lol/varus/build/?lane=middle) |

注記: lolalytics のページ抽出では、アイテムの勝率とアイテム名の対応が曖昧な箇所があった（各ページの注記）。アイテムの AP/AD 分類は筆者の一般知識に基づく【推論】で、ページに書かれているものではない。

---

## 6. オフメタ（定番から外れたビルド）

設計者の着眼: LoL では1体のチャンピオンが複数の勝ち方（ポーク特化/近距離、AD/AP）を持ちうる。アイテムを買うことでファイターがサポートに変わることもあり、オフメタは「面白い部分」。以下は、事実として確認できた範囲だけを書く。

### 6.0 先に押さえるべき事実

- 【事実】オフメタは統計上は弱い傾向がある（下記の勝率）。Riot の Phreak（2021）は、別ビルドを「選べる」ことは良いが「強制」は良くない、と述べた（既存ノート Q1 の引用）。
- 【事実】Riot の公式パッチ解説でも、ルシアンのミッドは「ほぼ全ての帯域で非常に弱い」と評価されている（Phroxzon、パッチ26.19、二次情報経由）。 — [Insider Gaming](https://insider-gaming.com/lol-patch-26-19-wants-a-lucian-mid-meta-for-worlds-2026/)
- 【事実】オフメタの統計ページは、サンプルが小さい（ゲーム数が数百〜数千）ことが多い。勝率の差は参考値にとどめる。

### 6.1 AP ルシアン（AP Lucian）

| 項目 | 普段の ルシアン（ボット ADC） | AP ルシアン（オフメタ） |
|---|---|---|
| レーン・役割 | ボット 91.0% / ミッド 6.9% / トップ 2.0%（[lolalytics](https://lolalytics.com/lol/lucian/build/?lane=bottom)）。ADC が本職 | ミッド/トップで見られる。**SR での AP の役割別割合は未確認**（統計ページに AP ビルドの区分がない） |
| ルーン | プレスアタック（ミッドでも使用率 85.8%）＋ 栄華（冷静沈着、血脈、慈悲系）＋ 天啓（魔法の靴ほか）（[op.gg ミッド](https://www.op.gg/champions/lucian/build/mid)） | ARAM 向けガイド: 覇道（魂の収穫）＋ 栄華（[ARAMonly](https://www.aramonly.com/guide/lucian/ap-build/)）。神話級期の古いガイド: 魂の収穫＋血の味わい＋Eyeball Collection＋至極の賞金首狩り、サブ栄華（冷静沈着・迅速）（[LoLSolved「KOREAN ONE SHOT」](https://www.lolsolved.gg/Lucian/guide/AP-LUCIAN)、日付なし）。2026年の AP 型は「秘儀の彗星＋覇道」とする記述あり（metasrc 26.20、検索結果の要約経由でページ本文は取得不可） |
| コアアイテム | Essence Reaver → Navori Flickerblade → Gluttonous Greaves → Infinity Edge → LDR → Guardian Angel（[lolalytics](https://lolalytics.com/lol/lucian/build/?lane=bottom)） | Luden's Echo を最初に（ポーク型メイジとして遊ぶ）、タンク対面は Liandry's Torment、MR 積みには Void Staff、回復対策は Oblivion Orb → Morellonomicon、暗殺者対策は Zhonya's Hourglass（[ARAMonly](https://www.aramonly.com/guide/lucian/ap-build/)。**ARAM 向けで SR の保証はない**）。別ガイド（パッチ26.6表記）の終盤候補: Sorcerer's Shoes / Horizon Focus / Void Staff / Luden's Echo / Rabadon's / Shadowflame（検索結果の要約）。古いガイドは Night Harvester（神話級）/ Lich Bane / Demonic Embrace などを使用 |
| スキル上げ順 | Q 先上げ → E → W（W は Lv1 と終盤）（[lolalytics](https://lolalytics.com/lol/lucian/build/?lane=bottom)） | **W 先上げ**（Lv1,3,5,7,9）→ E → Q（[LoLSolved](https://www.lolsolved.gg/Lucian/guide/AP-LUCIAN)）。ARAM ガイドも W を最初に上げる |
| 勝ち筋・使うスキル | パッシブ Lightslinger（スキル後の通常攻撃で2発目、AD 50〜60%）、E の CD が Lightslinger のヒットごとに短縮（1秒、チャンピオンには2秒）、Q は追加AD 100% — [Wiki: Lucian](https://wiki.leagueoflegends.com/en-us/Lucian) | **W（Ardent Blaze）は AP 90%** で唯一の大きな AP 係数（基礎 75〜215）。**R（The Culling）は AP 15% ＋ AD 25%**（ミニオンには2倍）。Q とパッシブは AP 係数なし（Vigilance のオンヒットも AD 15%）。ARAM ガイドは「E で距離を詰めて Q で爆発」「W の星型の爆発を狙う」と説明 — [Wiki: Lucian](https://wiki.leagueoflegends.com/en-us/Lucian) |
| 強い時間帯 | 統計上は4個目以降に勝率が伸びる（5.2 の選択バイアスに注意） | **未確認**。ARAM ガイドは Luden's 最優先のため「1個目」がピーク（【推論】Q・パッシブが AP を使えないので、アイテムが増えるほど通常攻撃が弱く見える） |
| 弱点 | — | Q・パッシブ・通常攻撃が AP を使えず、AD 型のコアを捨てる。R は AP スケールだが物理ダメージなので魔法貫通が効きにくい（LoLSolved の指摘）。R の弾数はクリ率で増える（Wiki）ため、AP ビルドでは減る（【推論】）。ミッドのルシアン全体が弱い（勝率 43.26%/41.85%、D 帯） |
| 使い手 | — | プロ/ストリーマーの採用例は**見つからず（未確認）**。2015年に NerfPlz が「Weird Picks #14: Mid Lane AP Lucian」と題した記事を出している（[リンク](https://www.nerfplz.com/2015/05/weird-picks-14-mid-lane-ap-lucian.html)、本文は取得できず未確認）。ミッドルシアン自体は2021年のプロで人気だった（Riot が弱体化。[Dot Esports](https://dotesports.com/league-of-legends/news/riot-reveals-plans-lucian-changes-ap-mana-mythic-buffs-league-patch-11-13)） |

要点: AP ルシアンが成り立つ理由は、W に AP 90% という本格的な係数がある点だけ。その代わりキットの半分（Q・パッシブ・通常攻撃）が使えなくなる。

- 【推論】キットの中に「どのステータスで伸びるか」が複数あるため、**別の軸に全振りしても1スキルは強くなる**。ただし他のスキルが死ぬので、全体として弱くなる。
- 【事実】Wiki によれば、AP 係数を持つスキルは W と R のみで、Q・E・パッシブは AP を持たない。 — [Wiki: Lucian](https://wiki.leagueoflegends.com/en-us/Lucian)

### 6.2 サポート リー・シン（Support Lee Sin）

| 項目 | 普段の リー・シン（ジャングル） | サポート リー・シン（オフメタ） |
|---|---|---|
| レーン・役割 | ジャングル 95.9%、サポート 1.7%、トップ 1.4%（[lolalytics](https://lolalytics.com/lol/leesin/build/?lane=support)）。クラスは Diver（過去は Fighter・Assassin）（[Wiki: Lee Sin](https://wiki.leagueoflegends.com/en-us/Lee_Sin)） | 同じ統計でサポートは4,590ゲームのみ（pick 率 0.23%）。**勝率45.1%**（ジャングルは 50.69%、pick 13.13%、S-） |
| ルーン | キーストーン候補4つ（PTA / リーサルテンポ / フリート / 征服者）。どれが主流かは統計ページで判別不能（[lolalytics](https://lolalytics.com/lol/leesin/build/?lane=jungle)） | op.gg: 電撃＋栄華のページが 46.05%（勝率 40.39%）、征服者＋覇道が 15.03%（勝率 42.41%）（レイアウトが読みにくい注記あり）（[op.gg](https://www.op.gg/champions/leesin/build/support)）。サモナー: Flash ＋ Ignite（lolalytics 勝率 45.39%） |
| スターター・コア | ジャングルペット（Scorchclaw Pup）＋ ポーション → Eclipse → Black Cleaver → Mercury's Treads → Guardian Angel など（[lolalytics](https://lolalytics.com/lol/leesin/build/?lane=jungle)） | World Atlas（クエスト）→ **Bloodsong（スペルブレードのサポートアイテム）** → Hubris → Voltaic Cyclosword → Black Cleaver / Sundered Sky → Serylda's Grudge / Edge of Night / Death's Dance（[lolalytics](https://lolalytics.com/lol/leesin/build/?lane=support)）。ブーツは Plated Steelcaps（40.82%）か Ionian Boots（26.71%）（op.gg） |
| スキル上げ順 | Q 先上げ → W → E（[lolalytics](https://lolalytics.com/lol/leesin/build/?lane=jungle)） | lolalytics: Q → E → W。op.gg: Q → W → E の並び。**情報源で食い違う** |
| 勝ち筋・使うスキル | Q（ソニックウェーブ）で印を付けて Q2 で飛びつく、W で味方か自分に飛んでシールド、E で範囲ダメージ、R で吹き飛ばし（[Wiki: Lee Sin](https://wiki.leagueoflegends.com/en-us/Lee_Sin)） | 実測のダメージの約78.5%が物理（lolalytics の Lee Sin Stats より筆者計算。Physical 15,002 / Magic 2,347 / True 1,756）。Bloodsong は「スキル後の次の通常攻撃に基礎AD 100%の追加物理ダメージ＋被ダメージ+8%（近接）」（[Wiki: Bloodsong](https://wiki.leagueoflegends.com/en-us/Bloodsong)）— Lee Sin のパッシブ（スキル後2回の通常攻撃で攻撃速度とエネルギー）と噛み合う【推論】 |
| 強い時間帯 | lolalytics 上は S- 帯（ジャングルの勝率 50.69%）。時間帯別は未取得 | **未確認**（時間帯別の統計は取得できず） |
| 弱点 | — | 勝率は5.6ポイント低く、サンプルも小さい（ビルドごとに数十〜数百ゲーム）。【推論】サポートの標準的な視界・保護役割を果たしにくい。Lee Sin は魔力ではなくエネルギーを使うのでマナ問題はない（Wiki のコスト表より）が、W のシールド（AP 80%）を活かすアイテム構成は主流にならない |
| 使い手 | — | 2014年の Mobafire ガイドが、サポート リー・シンで最も有名なのは Mata と述べたと検索結果にある（ガイド本文は取得不可、二次情報）。**2026年のプロでの採用は確認できず**（検索範囲内） |

なぜ成り立つか（事実と推論の切り分け）:

- 【事実】Lee Sin の W「Safeguard」は味方へ飛び、味方チャンピオンに着地するとその味方と自分にシールド（60〜240 ＋ AP 80%）。味方がミニオンやワードなら自分のみ。W2「Iron Will」は自分に全吸収（V26.04 でライフスティール＋スペルヴァンプから変更）。 — [Wiki: Lee Sin](https://wiki.leagueoflegends.com/en-us/Lee_Sin)
- 【事実】Q のダメージは追加AD 90%（印のある相手には最大180%まで、減ったHPに応じて増加）。R は追加AD 200%＋衝突ダメージ。つまり**ダメージスキルは全て AD スケール**で、AP を持つのは W のシールドだけ。 — [Wiki: Lee Sin](https://wiki.leagueoflegends.com/en-us/Lee_Sin)
- 【推論】サポートでも Lee Sin が成立するのは、**AD 係数で伸びるキット**に、サポートクエストの完成品として「AD を使うスペルブレード（Bloodsong）」が用意されているから。ロールを決めるのはキャラクターではなくアイテム枠と目的（クエスト）、という構造になっている。
- 【事実】サポートの完成品は5択で、Bloodsong はその1つ（[Wiki: Bounty of Worlds](https://wiki.leagueoflegends.com/en-us/Bounty_of_Worlds)）。他の4つ（Celestial Opposition / Dream Maker / Solstice Sleigh / Zaz'Zak's Realmspike）は効果未取得で、AD 型の受け皿かは未確認。ただしマルファイト サポートは Zaz'Zak's Realmspike を使っている（[lolalytics](https://lolalytics.com/lol/malphite/build/?lane=support)）。

### 6.3 その他の有名な例（短く）

| 例 | 普段 → オフメタ | 主なアイテム/ルーン（統計） | なぜ成り立つか | 出典 |
|---|---|---|---|---|
| パンテオン サポート（Pantheon） | トップ → サポート。試合の 38.2% がサポート（トップは 40.8%）。勝率 49.98%、ゲーム数 65,927 | 電撃（勝率 52.46%）、Bloodsong → Umbral Glaive → Voltaic Cyclosword / Sundered Sky、Boots of Swiftness | W（Shield Vault）で 1秒のスタン。Q は追加AD 115% ＋ AP 50%。E は正面からのダメージを無効化しながら攻撃するチャネル（Wiki）。**ヒールもシールドも出さず、圧力で勝つ**というコミュニティ解説あり（2020年の NerfPlz、検索結果の要約経由で本文は未確認） | [lolalytics](https://lolalytics.com/lol/pantheon/build/?lane=support) / [Wiki: Pantheon](https://wiki.leagueoflegends.com/en-us/Pantheon) / [NerfPlz](https://nerfplz.com/2020/08/fotm-report-support-pantheon-surging.html) |
| セナ（Senna） | サポート 91.9% / ボット 7.2%。2019-11-10 に実装、役割は「ボットとサポート」、クラスは射手＋エンチャンター | サポート: エアリー、Bloodsong → Black Cleaver → Statikk Shiv（勝率 52.76%）。ボット: Doran's Helm → … Manamune / Infinity Edge（勝率 51.73%） | パッシブ（霧のスタック）が AD・射程・クリを伸ばす。サポートでも成長でき、キャリーにもなる。開発時から「サポートの射手」という新しい役割を作る意図だった、とする記述あり（Riot の設計者 August、二次情報。[Upcomer](https://upcomer.com/senna-league-of-legends-newest-champion-gets-behind-the-scenes-look/) は検索結果の要約経由で本文未確認） | [lolalytics サポート](https://lolalytics.com/lol/senna/build/?lane=support) / [ボット](https://lolalytics.com/lol/senna/build/?lane=bottom) / [Wiki: Senna](https://wiki.leagueoflegends.com/en-us/Senna) / [Liquipedia](https://liquipedia.net/leagueoflegends/Senna) |
| シャコ（Shaco） | ジャングル 76.4%、サポート 21.4%。**ジャングルの主流が AP**（勝率 52.44%、A-） | ジャングル: Blackfire Torch → Liandry's → Imperial Mandate / Shadowflame → Rabadon's / Cryptbloom。サポート（勝率 49.54%）: Zaz'Zak's Realmspike / Blackfire Torch → Imperial Mandate | 既存ノートにあるように、Two-Shiv Poison（魔法ダメージ）が AD/AP 両ビルドで最優先で上がる。AP ビルドは AP 全振りで勝つ | [lolalytics ジャングル](https://lolalytics.com/lol/shaco/build/?lane=jungle) / [サポート](https://lolalytics.com/lol/shaco/build/?lane=support) / [lol_itemization.md](../research_notes/ビルド多様性%20デッキ構築設計/lol_itemization.md) |
| ケイル（Kayle） | トップ AD/オンヒット風 → オンヒット＋AP の混成。トップ勝率 53.18% | Nashor's Tooth → Rabadon's → Dusk and Dawn / Guinsoo's → Shadowflame / Lich Bane | Q・E・R が AD と AP の両係数を持つ（5.3 参照） | [lolalytics](https://lolalytics.com/lol/kayle/build/?lane=top) |
| ヴァルス（Varus） | ボット ADC → トップ 23.4% / ミッド 5.5% | ボット: Statikk Shiv → Guinsoo's → Terminus。ミッド: AP 寄り | スキルごとに担当軸が違う（Q=AD、W=オンヒット＋AP、R=AP） | [lolalytics](https://lolalytics.com/lol/varus/build/?lane=bottom) / [ミッド](https://lolalytics.com/lol/varus/build/?lane=middle) |
| エズリアル（Ezreal） | ボット AD → ミッド AP 寄り（2.9%、勝率 44.83%） | Hextech Gunblade → Lich Bane → Sorcerer's Shoes | AD と AP の両方に係数があるキット（詳細未確認） | [lolalytics](https://lolalytics.com/lol/ezreal/build/?lane=middle) |
| マルファイト（Malphite） | タンク（トップ 79.0%）→ AP ミッド/サポート | 5.3 参照 | E が防具 40% ＋ AP 60%。防御を積んでもダメージが出る | [lolalytics](https://lolalytics.com/lol/malphite/build/?lane=middle) |
| ケイトリン サポート（Caitlyn、T1 Keria） | ADC → サポート（2023年、シーズン13） | ヘイルブレード＋血の味わい＋Zombie Ward＋Treasure Hunter（当時） | 射程の長い2人（Gumayusi の Varus と組む）でレーン序盤の優位を取る。終盤は弱く、機動力のある相手に弱い | [Sportskeeda](https://sportskeeda.com/esports/how-play-off-meta-caitlyn-support-like-t1-keria-league-legends-season-13)（本文は取得できず、検索結果の要約経由。**未確認**） |

### 6.4 まとめ: どんな設計が複数ビルドを支えるか

【事実と推論の混在。根拠は上の各表】

1. **1つのスキルに複数の係数**: Kayle の Q（AD 60% ＋ AP 50%）、Lucian の R（AD 25% ＋ AP 15%）、Varus の W（AD 15% ＋ AP 25%）。どちらの軸で買っても「そのスキルは強くなる」。
2. **オンヒットと%HPのパッシブ**: Kayle の E、Varus の W は、攻撃回数を増やすだけで伸びる。攻撃速度・オンヒット系ビルドが成立する。
3. **防御ステータスを攻撃に変換**: Malphite の E は防具の40%を攻撃に使う。
4. **ユーティリティが特定のステータスに依存しない**: Pantheon の W（スタン）、Lee Sin の W（シールドは AP だが突進は無関係）など、CC や突進は装備に左右されない。だからロール（役割）を変えても働く。
5. **マナではなくエネルギー等のリソース**: Lee Sin はエネルギーで動くので、サポートでもマナ枯渇しない（コスト表より）。
6. **ロール専用のアイテム枠**: World Atlas → Bounty of Worlds → 5択（Bloodsong 等）は、チャンピオンではなく**アイテム枠が役割を決める**仕組み。AD の殴り合い型でも、Bloodsong を選べばサポートの金策を使ったまま戦える。
7. **閾値で変化するキット**: Kai'Sa（装備ステータス100で進化）、Kayn（受けた/与えたダメージで形態）。ビルドの結果がキットに反映される。
8. **適応型（Adaptive）のルーン**: Riot が2017年に述べた通り、AD/AP のどちらにも振れる汎用ステータスがビルドの違いを吸収する。ただしカイ＝サの進化判定では数えない。

ミッドゲームでの役割変更【推論】:

- 係数の違いで**最初の1個**（Luden's / Essence Reaver / Bloodsong）が方向を決める。4個目以降は状況に応じた選択（貫通、回復阻害、耐久）になる。
- 一度方向が決まると、他のスキルの係数は「死に予算」になる（AP ルシアンの Q）。だから**オフメタはキットの一部だけを使う戦い方**になりやすい。

---

## 7. デッキ構築ローグライクに持ち込むときの要点

事実から導ける範囲のみ（有効性は未検証）。

1. **開始時に1つの大きな選択（キーストーン）で戦い方の型を決める**。17個を「型」で分けると重複しない（長期戦、バースト、ポーク、機動、CC連動、支援）。
2. **小さな選択（通常ルーン、シャード）で味付けを足す**。メイン1＋サブ2のように、軸＋味付けの二層にする。
3. **成長は「数えられる」形にする**（魂、レジェンド、チャイム、Mark）。節目（25/125/225、5チャイムごと）を作る。
4. **成長の入り口は2種類用意する**: 行動で伸びる（キル、拾う）と時間で伸びる（強まる嵐）。後者は追い上げ用。
5. **上限なしの成長は難しい**（Riot は2011年から課題と認識）。入り口を限定する（チョ＝ガスは非エピック6スタックまで）か、節目で段階化する。
6. **係数を複数持たせて同じカードを別ビルドにする**が、主従をはっきりさせる（Lucian の R のように、片方が小さな係数）。
7. **役割はカードではなく「枠」で決められる**。サポートクエスト→5択のように、選択肢の枠を用意すると、ファイターでもサポートになれる。
8. **オフメタは統計上弱くてよい**（Lee Sin サポート 45.1% 対 ジャングル 50.69%）。「許される・面白い」ことと「強い」ことは別。主役にしない。
9. **成長が目に見える演出**（チョ＝ガスの巨大化、ミープの増加）は愛着を生む【推論】。カードの見た目が変わる成長を考える。
10. **勝っている側がさらに伸びる設計は、追い上げ手段とセット**にする（魂の収穫＋強まる嵐）。

---

## 8. 未確認・限界

- 【未確認】AP ルシアンの**現行 SR での勝率・採用率・使い手**。AP ビルドを区分した統計ページが見つからず、記述は ARAM 向けガイドと古い（神話級期の）ガイド、2015年の記事タイトルのみ。
- 【未確認】サポート リー・シンの**プロでの採用**（2014年の Mata の記述は二次情報の1行のみ）。Mobalytics / mobafire / metasrc / u.gg は取得できず、lolalytics と op.gg のみで書いた。
- 【未確認】V25.S1.1 の正確な日付、Eyeball Collection の後継の対応、サポートクエストの必要ゴールド（400/800の食い違い）、ベイガー W のクールダウン短縮、エズリアルの現行係数、他の4つのサポート完成品の効果。
- 【未確認】Riot の Runes Reforged の原本ブログ（2017年）を直接は取得できず、Surrender at 20 の転載経由。2018年1月の振り返りも検索結果の要約経由。
- lolalytics の抽出ではアイテムの対応付けが曖昧な箇所がある。勝率は Emerald+ のみ。サンプルが小さいページ（100ゲーム未満）の値は参考外。
- 本文中の【推論】は筆者による解釈で、Riot の公式見解ではない。
