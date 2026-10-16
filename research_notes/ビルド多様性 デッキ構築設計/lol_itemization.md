# League of Legends のアイテム設計とビルド多様性（Slay the Spire 型ローグライクへの翻訳用ノート）

調査日: 2026-10-16。数値は League of Legends Wiki（wiki.leagueoflegends.com）の現行ページ（V26.x 表記）から取得。パッチで変わるため「仕組みの例」として読むこと。
歴史的システムの区別: **Mythic（神話）アイテムは 2020年末の Preseason 2021（パッチ 10.23 期）〜 2023年末まで存在し、V14.1（2024 シーズン開始）で廃止**。

---

## Q1. ステータス軸と「レシオ（ratio）」で同じキットが別ビルドになる仕組み

### Takeaway
LoL のスキルは「基礎値 + 各ステータスへの係数（例: +55% bonus AD +20% AP）」で書かれ、どの係数を太くするかはアイテム側が決める。複数の軸に意味のある係数を持つ、または「%最大HP」「オンヒット」「閾値で進化」のように特定ステータスでスイッチが入るキットは、AD / AP / オンヒット / タンクなど複数ビルドが成立する。Riot は「別ビルドを“選べる”のは良いが“強制”は駄目」という立場。

### Cited Findings
**ステータスの基本仕様**
- Armor の軽減式: 物理ダメージ × 100 / (100 + Armor)。「Armor 1 点ごとに実効HPが 1% 増える」線形モデルで逓減しない（例: HP1000・Armor25 → 実効HP1250）— [LoL Wiki: Armor](https://wiki.leagueoflegends.com/en-us/Armor)
- 防御貫通の適用順: ①固定値アーマー減少 → ②%アーマー減少 → ③%アーマー貫通 → ④固定値貫通（Lethality）。%貫通は高アーマー相手に強く、Lethality（固定値）は低アーマー相手に強い（例: 40%貫通は Armor200 なら −80、Armor50 なら −20）。貫通は 0 未満にできない — [LoL Wiki: Lethality](https://wiki.leagueoflegends.com/en-us/Lethality)
- Lethality の履歴: V6.22 で導入時は対象レベル依存、V7.14 で使用者レベル依存（62.22%〜100%）、**V14.1 でレベル依存が廃止**され常に満額 — [LoL Wiki: Lethality](https://wiki.leagueoflegends.com/en-us/Lethality)
- Ability Haste（旧CDR の置き換え, Preseason 2021）: 旧CDRは指数的（10%CDR=発動回数+11%、40%=+66%、50%=+100%）で 40% 上限が必要だった。Ability Haste は「1点あたりの価値が一定」の線形モデル（10 AH = 10% 多く発動）で上限を撤廃。換算は 1:1 にしない（1:1 だと単純ナーフになるため） — [Riot: Preseason 2021 Champion Class Item Goals (2020-08-07)](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/)
- 同記事で Riot はメイジについて「Ability Haste をビルド上の判断にしたい（Haste 特化ビルドも、Haste を捨てるビルドも可能に）」と述べる — [Riot: Preseason 2021 Champion Class Item Goals](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/)

**オフステータス係数の意図（Riot 発言）**
- Riot の Ask Riot（2018）で、Kennen W の AD 係数や Ashe R の AP 係数は「チャンピオンが別のビルドタイプ・プレイスタイルを探れるようにする」ための“小さなフック”であり、完全な AP スケーリング手段ではないと説明（検索結果スニペット経由。元URLは現在リダイレクトされ本文未確認） — [Ask Riot: Bilgewater and Balance (nexus, 2018)](https://nexus.leagueoflegends.com/en-us/2018/05/ask-riot-bilgewater-and-balance/)
- Riot Phreak（2021, Reddit）: 「別ビルドを選べるようにするのは良いこと。別ビルドを強制するのは良くない」「AP 係数は Doran's Ring スタートや、Baron バフ・味方の Moonstone の恩恵にも意味を持たせる」「悲観的に見れば AP ビルド側のプレイテストは相対的に少ない」「AP Twitch は長らく勝率が低かった。プレイスタイルの習得に時間がかかったのだろう」「判断基準は、BAN率で見てフラストレーションがないか、勝率で見て妥当な選択が罰されていないか」 — [devtrackers: PhreakRiot comment](https://devtrackers.gg/leagueoflegends/p/8b373a16-riot-s-boner-for-build-diversity-is-hindering-their-ability-to-properly-balance-old-champs)

**具体例（現行Wiki数値）**
- **Kai'Sa（閾値で“進化”するハイブリッド）**: パッシブ「Second Skin」の各基本スキルが、アイテム由来の AD / AP / 攻撃速度で進化する。Q は AD 100（レベルで 100→56 に低下）で進化しミサイル 6→12 発、W は **AP 100（アイテム由来）** で進化しプラズマ付与 2→3・チャンピオン命中時 CD 75% 返還、E は攻撃速度 100%（レベルで 100%→70%）で進化し 0.5 秒透明化。Adaptive Force は進化判定に数えない。Q は bonus AD 55% + AP 20%（ミサイル1発）、W は AD 130% + AP 45%、パッシブ炸裂は「対象の失った HP の 15% + AP100 毎 6%」、R シールドは AD と AP の両係数 — [LoL Wiki: Kai'Sa](https://wiki.leagueoflegends.com/en-us/Kai%27Sa)
- **Kayle（レベルで形態が変わる + 両係数）**: パッシブ Divine Ascent が Lv6 で遠隔化（射程 525）、Lv11 で Exalted 時に通常攻撃が炎の波（bonus AD 10% + AP 25%）、Lv16 で射程 625・Zeal 永続。E のオンヒットは bonus AD 10% + AP 20%、E 起動は失った HP の 8〜10% + AP100 毎 1.5%、Q は bonus AD 60% + AP 50%、R は bonus AD 100% + AP 70% — [LoL Wiki: Kayle](https://wiki.leagueoflegends.com/en-us/Kayle)
- **Varus（1キットに3つの“入口”）**: Q は bonus AD のみ（最大 120% bonus AD）＝Lethality ポーク、W のオンヒットは bonus AD 15% + **AP 25%**、Blight 炸裂は対象最大HPの 3〜5%/スタック **+ AP100 毎 1.3%**（＝攻撃速度・オンヒットで積む）、R は **AP 100%** のみ。パッシブの bonus AD/AP は「総 bonus 攻撃速度」に比例 — [LoL Wiki: Varus](https://wiki.leagueoflegends.com/en-us/Varus)
- **Kog'Maw（%HPオンヒット vs AP 砲台）**: W は通常攻撃に対象最大HPの 3〜6% + AP100 毎 1.5% の魔法ダメージ（ミニオン/モンスターに 100 上限、建物には無効）。Q は AP 90%、E は AP 65%、R は bonus AD 75〜150% と AP 35〜90% の両係数 — [LoL Wiki: Kog'Maw](https://wiki.leagueoflegends.com/en-us/Kog%27Maw)
- **Malphite（防御ステータスが攻撃になる）**: E は AP 60% + **Armor 40%**、W は AP 20〜30% + Armor 15%、Q は AP 60%、R は AP 90%（Armor 係数なし）、パッシブのシールドは最大HP 10% — [LoL Wiki: Malphite](https://wiki.leagueoflegends.com/en-us/Malphite)。→ タンクビルドでも E/W が Armor でダメージを出し、AP ビルドでは R/Q が一撃型になる。コミュニティガイドは AP 型を「Luden's → Stormsurge のガラスキャノン、R を使ったら一方通行」と表現 — [esports.net: Is Malphite AP or AD](https://www.esports.net/news/lol/is-malphite-ap-or-ad)
- **Shaco**: ガイドでは Two-Shiv Poison（魔法ダメージ）を AD/AP 両ビルドで最優先上げ、AP 型は「よりチーム依存で 1v1 が弱い」と整理 — [検索スニペット: op.gg / Mobafire ガイド群](https://op.gg/nl/lol/champions/shaco/build)（コミュニティ情報・古いパッチ含む）
- 歴史的なハイブリッドアイテム論: 元 Riot デザイナー Xypherous（2013, フォーラム）は「特化したハイブリッドアイテムは、そのキャラをハイブリッドアイテム専用に縛る。アイテムが弱ければキャラは使えず、強ければ OP になる」と主張 — [Surrender at 20: Xypherous talks hybrid itemization (2013)](https://www.surrenderat20.net/2013/05/xypherous-talks-hybrid-itemization-and.html)（公式ブログではない）

### Inferences
- 複数ビルドを成立させるキットの型は少なくとも4つに分類できる: ①**両係数型**（Kayle/Kai'Sa: 全スキルに AD と AP 両方）、②**スキルごとに担当軸が違う型**（Varus: Q=AD, W=攻速/AP, R=AP。どれを伸ばすかでメインスキルが変わる）、③**%HP/オンヒット型**（Kog'Maw W, Varus W: 攻撃回数を増やすだけでスケールするため攻速ビルドが成立）、④**防御→攻撃変換型**（Malphite E: Armor 係数）。
- Kai'Sa の「閾値で進化」は、連続値の係数ではなく**離散的なスイッチ**でビルドの方向を可視化する仕組み。プレイヤーは「今回は W を進化させる」という明確なビルド目標を持てる。
- Riot Phreak の「選べるが強制しない」は、オフ係数を“主役にならない程度の小さなフック”に留める（Ashe R の AP 係数）方針と整合する。

### Gaps
- Ezreal、Twisted Fate、Corki、Teemo、Jax、Akali、Gwen、Sion の現行係数と各ビルド（例: Ezreal の AP/Tear ビルド、TF のオンヒット、Sion の HP スタック型、Jax/Gwen のオンヒット）の“出現経緯”は今回の調査で一次資料を取得できなかった。
- Kai'Sa が「進化」システムを持つに至った設計意図（2018 リリース時の Riot 発言）は未確認。
- Ask Riot（2018）の原文は URL がリダイレクトされ、検索スニペット経由でのみ確認。
- Armor/MR の具体的な“カウンタービルド”（Grievous Wounds 等）は Q2 参照。

---

## Q2. アイテム構造（素材→完成品→旧Mythic、ブーツ、ゴールド、コア+状況アイテム、カウンタービルド）と Mythic 導入/廃止の理由

### Takeaway
LoL は「Basic（単一ステータス）→ Epic（中間品・小効果）→ Legendary（完成品・ユニーク効果）」の3段レシピ、6枠、ブーツ1足、同名/同グループのユニーク制限で構成される。2020年に「各チャンピオンに複数の選択肢」を狙って 1人1個の Mythic を導入したが、2023年に Riot 自身が「約50%のチャンピオンしか満足していない」「全員を満たすには約30%多くのアイテムが必要」「アイテムがキットを上書きしすぎ」と結論し、V14.1 で廃止。以後は「明確なユニーク効果1つ・ステータス3つまで」のシンプルなアイテムへ。

### Cited Findings
**現行の構造**
- ティア: Starter（序盤用・基本は素材にならない）/ Basic（単一ステータス）/ Epic（より高いステータスや新効果、上位 Legendary の“劣化版”を持つものも）/ Legendary（Basic と Epic を組み合わせたもの、最大の効果）/ Boots / Consumables — [LoL Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends))
- インベントリはメイン6枠 + トリンケット1枠。ロールクエスト達成で追加枠（Bot/Support） — [LoL Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends))
- 制限: 同じ Legendary は1個まで。ユニーク効果の重複不可、異なるアイテム間の共有効果も重複不可、「アイテムグループ」内で1個まで。条件達成で自動変身するアイテムもある — [LoL Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends))
- ブーツは1足のみ。Tier1 で移動速度25、Tier2（購入アップグレード）で45、Tier3 は Midlane クエスト達成で Tier2 が強化 — [LoL Wiki: Item](https://wiki.leagueoflegends.com/en-us/Item_(League_of_Legends))
- カウンタービルドの例（回復阻害）: Riot は 2020 年「回復が増えすぎて Grievous Wounds が“状況に応じた選択”から“デフォルトの選択”になった」と問題視し、回復を削り GW を極端な回復役により鋭く効くよう調整すると宣言 — [Riot: Preseason 2021 Champion Class Item Goals](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/)
- Tenacity（行動妨害耐性）について Riot は「プレイヤーに“この試合はハードCCが多いか？”と問わせたい」と記述（＝カウンター用ステータスは“相手を見て判断する質問”を作るためのもの）。ノックアップ時間短縮案は PBE で取り下げ — [Riot: Preseason 2021 Champion Class Item Goals](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/); [Inven Global (2020-10-18)](https://www.invenglobal.com/articles/11900/riot-games-talks-approach-to-league-of-legends-2021-preseason-item-changes)
- ジャングルアイテムは「追加投資不要のスターター」にして、すぐ本来のビルドに移れるようにする方針 — [Riot: Preseason 2021 Champion Class Item Goals](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/)

**Mythic（2020末〜2023末, 歴史的システム）**
- 仕様: Mythic は他アイテムの素材にならない完成品で、Legendary より高ステータス、**同時に1個のみ装備可**。各 Mythic は「所持 Legendary 1個ごとに小さなステータスボーナス」を与える Mythic パッシブを持ち、一部は Ornn の Masterwork で上位版に強化可能。**V14.1 でカテゴリごと廃止** — [LoL Wiki: Mythic item](https://wiki.leagueoflegends.com/en-us/Mythic_item)
- 導入時（Preseason 2021）の目標: 「アイテムが満足感を持ち、試合ごとに変化と最適化の余地を生み、異なるプレイスタイルを支え、直感的であること」。Mythic は 1人1個の排他アイテムで、通常最初に買う。**全チャンピオンに複数のビルド選択肢**を目標に、ガードレールとして「どの Mythic も購入率 75% を超えない」「各チャンピオンに購入率 3% 以上の Legendary が 10 個以上」を設定。アイテムの約1/3 新規・1/3 変更・1/3 据え置き — [Riot Axes: /dev: Midseason and Mythics (2023-04-28)](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- うまくいった点（Riot Axes の振り返り）: 最初の Legendary+ 購入の分散は Mythic 以前より増えた（ただし Kraken Slayer / Immortal Shieldbow は利用者の 85% 超が購入）。Eclipse・Heartsteel・Galeforce など“かっこいい”アイテムが「RPG 的な成長ループ」を支えた。「Mythic 1つ・ブーツ1つ・残りは好きな Legendary」で分かりやすくなった。排他性のおかげで「一緒に買うと強すぎる」アイテム同士を分離でき、バランスしやすかった — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- うまくいかなかった点: 最適化と選択を優先した結果、ワクワクしないアイテムを買うことになった（Morgana/Fiddlesticks にとって Zhonya は“キットを定義する”アイテムなのに Liandry が買われた。Unholy Grail は“完璧すぎ”て削除）。幅広い層向けの汎用 Mythic は出力を盛りすぎ（Goredrinker, Riftmaker）。Duskblade・Prowler's Claw・Everfrost のような“行動パターンを歪める”アイテムが不満を生んだ。排他性ゆえ新 Mythic の設計コストが高く、2年半経っても揃わなかった。**プレイヤーの約68%が推奨アイテムを主な導線にしていた**ため 75% 上限は困難 — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- 2023 Midseason の方針転換: Mythic を「状況対応」ではなく「ビルドを定義する高出力・高満足度の capstone」へ。75% 目標を捨て、「毎試合同じ Mythic を買うことになっても満足度を最優先」 — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- 廃止理由（Riot Phroxzon, 2023-09-14）: ①Fighter のようにサブクラス（diver / juggernaut / skirmisher 等）が多いクラスを「4つのアイテムで満たすのは極めて難しい」、カバーには約10個の Mythic が必要。②Mythic は Legendary 枠を奪い、全員満足には**約30%多いアイテム**が必要で学習コストが上がる。③「**約50%のチャンピオンは Mythic に満足**」していたが残り半分は合っていなかった。④ダッシュ等アイテム付与の出力を前提に新チャンピオンを作る設計負債。⑤多くのチャンピオンに対応するため Mythic が複数メカニクス/ステータスを抱え複雑化。⑥1個制限のバランス上の利点はコストに見合わない — [Riot Phroxzon: Quick Gameplay Thoughts: Addressing Mythics](https://www.leagueoflegends.com/en-sg/news/dev/quick-gameplay-thoughts-addressing-mythics/)
- 廃止後の方針: 「明確な目的を持つシンプルなアイテムは学習の障壁を下げる」。可能なら「**明確なユニーク効果1つ・ステータス最大3つ**」。各アイテムに約5人以上の利用者。「Legendary のユニーク効果でさえチャンピオンのゲームプレイを上書きしすぎている」ので弱める。旧 Mythic は Legendary 化時に弱体化、スタック可能になるのでアイテム全体の出力を下げる。アイテムが単純化しキットが際立てば「プレイヤーはより柔軟にビルドを組める」 — [Riot Phroxzon: Quick Gameplay Thoughts: Addressing Mythics](https://www.leagueoflegends.com/en-sg/news/dev/quick-gameplay-thoughts-addressing-mythics/)
- 発表は 2023年8月28日の Dev Update（Brightmoon / Meddler）。Galeforce 等の一部はショップから削除 — [Earlygame: Riot Is Removing Mythic Items](https://earlygame.com/lol/lol-riot-is-removing-mythic-items-this-is-why)（二次情報）
- それ以前にも Phroxzon は Rod of Ages 削除（Season 11）について「それを欲しがるチャンピオンにとって強すぎて、他の選択肢を検討させなかった」と説明 — [GGRecon: Riot Explains Why Certain Items Have Been Removed](https://www.ggrecon.com/articles/riot-explains-why-certain-items-have-been-removed-from-lol)（二次情報）

### Inferences
- Mythic の失敗は「排他スロット（1個制限）× 少数のアイテムで多数のキャラを満たす」構造的な問題。排他スロットにはバランス上の利点（強い組み合わせを分離）があるが、**排他スロット用のプールは“全クラス×サブクラス”分の数がないと半分のキャラが不満になる**。
- 「Mythic パッシブ（Legendary 1個ごとにステータス+）」は、ビルドの“軸”を最初に決めさせ、後の購入でその軸を強化させる仕組み。ローグライクのレリック/キーストーンにそのまま対応する。
- Riot の2023年の結論は「アイテムは単純に、個性はキット（キャラ）側に」。デッキ構築に置き換えると「レリックは単純な増幅器に留め、勝ち筋のユニークさはカード（キャラのキット）側で出す」。
- 推奨アイテム利用率 68% は「多くのプレイヤーは提示された選択肢に従う」ことを示す。報酬画面で何を“提示するか”がビルド多様性を実質的に決める。

### Gaps
- 2024シーズン（V14.1）で新設されたアイテムグループ（例: Lifeline 系、Last Whisper 系など）と各グループの具体的メンバーは今回取得したページに記載がなく未確認。
- Mythic 導入時の原本 dev blog（2020年9月頃のアイテム刷新告知）本文は取得できず、Riot Axes の 2023 年振り返り経由で目標を確認した。
- ゴールド経済（ゴールド/分、素材の“組み合わせ料金”の具体値）は未調査。
- 2024年以降（2025〜2026）にアイテム設計方針が再変更されたかは未確認。

---

## Q3. Riot が掲げたアイテム設計目標（意味のある選択・唯一解の回避・可読性・クラス別アーキタイプ）

### Takeaway
Riot の公式目標は一貫して「“必須購入（must-buy）”を減らし、トレードオフのある選択を作る」「クラスごとに固有のアイテム群」「アイテムの目的を明確に（何でも得意なアイテムを作らない）」。2023年以降はそこに「満足感（キットを定義する気持ちよさ）」「単純さ」が優先項目として加わった。

### Cited Findings
- クラス別目標（2020-08-07, Summoner's Rift チーム）—[Riot: Preseason 2021 Champion Class Item Goals](https://www.leagueoflegends.com/en-us/news/riot-games/preseason-2021-champion-class-item-goals/):
  - **Marksman**: 「must-buy が多すぎる」。必須を減らして状況選択を開き、DPS を一部犠牲にする自衛手段を追加、1アイテム目でより戦えるようにしつつ終盤キャリーは維持。AD+Armor アイテムやスペルキャスター系 ADC 向けの選択肢を補う。
  - **Mage**: 「1アイテム目に明確なトレードオフがない」。1アイテム目に状況的な目的を与え、砲台メイジ用の“夢の”アイテムを作る。Ability Haste をビルド判断に。
  - **AP Fighter / AP Assassin**: 序盤にダメージ+耐久のハイブリッド・マナ不要の選択肢、後半はタンクか純 AP に移れるように（AD Fighter と同様）。
  - **AD Fighter**: Sterak's / Death's Dance 以外の、物理/魔法の脅威別の防御選択肢。Black Cleaver・Trinity Force を尖らせ、序盤枠に競合アイテムを追加して序盤の判断を作る。
  - **AD Assassin**: 「買う順番」以外の状況選択を追加。終盤ニーズを他クラスから借りるか専用アイテムにするかを決める。
  - **Tank**: チーム戦略（スプリットプッシュ対策、エンゲージ、キャリー護衛）に応じた選択肢、複数の AP 型に対応する MR 選択肢、ユーティリティ、終盤 capstone を1〜2個。
  - **Enchanter**: 「少数のアイテムが他を圧倒」「有効アイテムのプールが浅すぎる」。アクティブを1〜2個程度に減らし、「何でも得意」ではない明確な目的を与える。
- 導入時の数値目標: Mythic 購入率 75% 以下、チャンピオンごとに購入率 3% 以上の Legendary 10個以上 — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- 2023年の優先順位変更: 「満足感」を最優先、同じ Mythic を毎試合買っても良い — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- 2023年9月: 「ユニーク効果1つ・ステータス3つまで」、1アイテムあたり約5人以上の利用者、アイテム効果がキットを上書きしない — [Riot Phroxzon: Addressing Mythics](https://www.leagueoflegends.com/en-sg/news/dev/quick-gameplay-thoughts-addressing-mythics/)
- Riot Phreak の判断基準: 代替ビルドは「BAN率（不満）」と「勝率（妥当な選択が罰されていないか）」で見る — [devtrackers: PhreakRiot](https://devtrackers.gg/leagueoflegends/p/8b373a16-riot-s-boner-for-build-diversity-is-hindering-their-ability-to-properly-balance-old-champs)

### Inferences
- Riot の目標には緊張関係がある: 「選択の多様性（75%上限）」vs「満足感（キットを定義する1個を毎回買いたい）」。2023年の結論は満足感寄り。つまり**“毎回同じコア + 状況で変わる周辺”は失敗ではなく、むしろ満足度の源泉**。
- 「何でも得意なアイテムを作らない」「目的を明確に」は、汎用的に強いレリック/カードが全ビルドに入って多様性を潰す問題（ローグライクでも頻出）への直接の処方箋。
- 数値ガードレール（最大購入率、有効選択肢の最低数）はローグライクでもテレメトリで同様に設定できる（例: 特定レリックのピック率上限、各キャラで勝率に寄与するカードが N 枚以上）。

### Gaps
- Riot August（チャンピオンデザイナー）、Meddler、Riot Repertoir 個人のビルド多様性に関する一次発言は今回特定できなかった（Meddler は 2023-08 Dev Update の発表者として二次情報で確認のみ）。
- GDC での Riot のアイテム設計専用の講演は見つからなかった（後述 Q6）。

---

## Q4. ハイブリッドスケーリングの落とし穴（AD キャラの AP 係数の罠、パワーバジェット）

### Takeaway
ハイブリッドは「両方の係数に予算を割くので、片方だけ積むと弱い／専用ハイブリッドアイテムがあると強すぎる」の二択に陥りやすい。Riot は代替ビルドを“小さなフック”として許容しつつ、勝率・BAN 率で監視する。代替ビルドはプレイテスト量が少なく、プレイヤーの習熟にも時間がかかる。

### Cited Findings
- 特化ハイブリッドアイテムはキャラをそのアイテムに縛り、弱ければ死に、強ければ OP — [Xypherous (2013), Surrender at 20 経由](https://www.surrenderat20.net/2013/05/xypherous-talks-hybrid-itemization-and.html)
- 代替ビルドは相対的にプレイテストが少ない。AP Twitch は習熟に時間がかかり長く低勝率 — [devtrackers: PhreakRiot](https://devtrackers.gg/leagueoflegends/p/8b373a16-riot-s-boner-for-build-diversity-is-hindering-their-ability-to-properly-balance-old-champs)
- Ashe R の AP 係数は「完全な AP スケーリング手段ではなく小さなフック」 — [Ask Riot (2018) 検索スニペット](https://nexus.leagueoflegends.com/en-us/2018/05/ask-riot-bilgewater-and-balance/)
- AD LeBlanc（Statikk Shiv / Trinity Force / Hullbreaker）が強すぎてナーフされた事例 — [Riftfeed: Riot Can't Balance LeBlanc](https://riftfeed.gg/lol-news/lol-riot-cant-balance-leblanc)（二次情報・検索スニペットのみ）
- Mythic 期の汎用アイテムは「広い層に対応するため出力を盛りすぎ」バランス問題化（Goredrinker, Riftmaker） — [Riot Axes: /dev: Midseason and Mythics](https://www.leagueoflegends.com/en-us/news/dev/dev-midseason-and-mythics/)
- Kai'Sa は進化判定に Adaptive Force（AD/AP どちらにもなる汎用ステータス）を数えない — [LoL Wiki: Kai'Sa](https://wiki.leagueoflegends.com/en-us/Kai%27Sa)

### Inferences
- **パワーバジェットの分配問題**: スキル1つの総パワーを AD 係数と AP 係数に分けると、純ビルドでは係数の半分が“死に予算”になる。一方、両方を同時に満たすアイテムがあると両係数がフルに働き突出する。Kai'Sa の「進化は各ステータス100」は“どれか1〜2本に絞らないと進化しない”ので、全部取り（ハイブリッドの過剰効率）を抑える設計とも読める（設計意図の公式確認はなし）。
- Adaptive Force を進化に数えないのは「どちらにでもなる汎用ステータスで閾値を安く満たす抜け道」を塞ぐ処置と解釈できる。
- ローグライクでは、ハイブリッドカード（例: 攻撃と防御の両方をスケール）は“両方を伸ばすレリック”と組むと過剰になる。カードの係数をどちらかに主従付けるのが安全。

### Gaps
- Riot が Kai'Sa / Varus / Kayle のハイブリッド係数を調整した際の公式な理由説明（パッチノートの開発者コメント）は未取得。
- 「AP 係数の罠」についての近年（2024〜2026）の Riot 発言は見つからなかった。

---

## Q5. TFT のアイテム／エンブレム（ローグライクのドラフトにより近い類例）

### Takeaway
TFT は「素材2個 → 完成品1個」「1ユニット最大3アイテム」「Spatula + 素材 → エンブレム（ユニットに特性を付与）」という単純な合成表で、毎試合ランダムに落ちる素材から構成（comp）を即興で組ませる。Riot TFT チームは「チーム構成の可能性を減らす仕組みは入れない」を原則とし、エンブレムが“ゲームを歪める”強さになった反省から「その特性の最良の使い手の出力を上限とする」バランス枠を作った。

### Cited Findings
- アイテム種別（概算ゴールド価値）: Component（〜8g, 基礎ステータス）/ Completed（〜12g, 素材2個で作成、ステータス+通常は効果）/ Radiant（〜30g, 完成品の強化版）/ Artifact（〜18g, 稀で強力な効果）/ Support（〜18g, 味方強化・敵弱体）/ Spatula・Frying Pan（素材と合成で **Emblem＝持ち主に特性を付与**、Spatula/Pan 2個で Tactician's Item＝出撃ユニット数+1）。1チャンピオン最大3アイテム。入手源は Encounter、Loot Orb、Augment、Carousel など — [LoL Wiki: TFT:Item](https://wiki.leagueoflegends.com/en-us/TFT:Item)
- Spatula 単体はステータスを持たず、他アイテムと合成して特性エンブレムになる — [Tacter: Spatula guide](https://tacter.com/tft/guides/tft-spatula-guide-best-team-comps-set-13-53e60515)（コミュニティ）
- Dragonlands（Set 7）振り返り（Riot TFT Dev Team）— [TFT: Dragonlands Learnings](https://teamfighttactics.leagueoflegends.com/en-us/news/dev/dev-teamfight-tactics-dragonlands-learnings):
  - 前2セットのエンブレムは「非変革的」だったため Set 7 では意図的に変革的に振ったが「明らかにやりすぎ、ゲームが損なわれた」（Revel Daeja, Dragonmancer Nunu, Assassin Olaf, Cavalier Yasuo, Warrior Graves, Astral Emblem）。
  - 新ルール: 「各エンブレムについて、その特性の最良の使い手を把握し、他の全ユニットはその出力を下回るか、わずかに上回る程度にする」。
  - 原則: 「チーム構成の可能性を減らすことは決してしたくない」「チーム結果のバリエーションを減らすのが正解なことはまず（ほぼ）ない」。
  - 「Dragon は1体まで」は「大きな間違い」で構成の多様性を制限。「Scalescorn は Dragon と併用不可」はショップに“死にロール”を生んだ。
  - Augment の差別化が多様性の負担を大きく担っていた。小さな形で変化を増やすシステムを今後も追加。
  - 終盤のアイテム配布問題: AP 構成なのに「剣2本とクローク」が出る苛立ち、「相手は Shroud を得たのに自分はまた Sunfire」。解決として Item Anvil（Stage 4-7 で必ず素材 Anvil、5-7・6-7 で完成品 Anvil）を恒久導入し「プレイヤーに主体性を与え、ビルドに沿わせる」。ただし「完全な Armory（選択式）は“forcing（毎回同じ構成を強行）”を招く」ので避ける。
  - セット固有の二次メカニクスで、恒久化候補の仕組みを試験する。

### Inferences
- TFT の構成多様性は「ランダムに落ちる素材」×「小さな合成表」×「エンブレムによるキャラ特性の書き換え」の掛け算で生まれる。素材の偏りが毎試合異なるので、同じユニットでも“その試合で作れる完成品”に合わせて構成が変わる。
- 「選択肢を完全に与えると forcing が起きる、ランダムだけだと苛立つ」→ Anvil は“ランダムの中で何個か選ぶ”中間解。StS のカード報酬（3枚から1枚）と同型。
- 「特性を付与するエンブレム」は、デッキ構築なら「カードに別アーキタイプのタグを付与する」「キャラに別キャラのカードプールを開放する」仕組みに相当。上限ルール（最良の使い手の出力を超えない）がそのままバランス指針になる。
- 「X とは併用不可」ルールが死にドローを生んだ反省は、ローグライクの“排他レリック”設計に直接当てはまる。

### Gaps
- 現行セット（Set 15〜18 期）での素材の種類数と合成表の正確な数は Wiki 本文から明示的に取得できなかった（画面構成からは 8 種＋Spatula/Frying Pan と推測されるのみ）。
- Mortdog（TFT リードデザイナー）個人のアイテム設計発言は今回見つからなかった。
- Thieves' Gloves、Reforger、Magnetic Remover など“アイテムの再配分”系の仕様と設計意図は未調査。

---

## Q6. Riot のアイテム設計に関する GDC 講演・ポストモーテム

### Takeaway
アイテム設計に特化した Riot の GDC 講演は見つからなかった。実質的なポストモーテムは公式 dev ブログ（2023-04 Riot Axes「Midseason and Mythics」、2023-09 Riot Phroxzon「Addressing Mythics」、TFT「Dragonlands Learnings」）。

### Cited Findings
- 確認できた Riot の GDC 講演はプレイヤー行動（Kimberly Voll, 2018）、チャンピオン制作フレームワーク（Jeremy Lee, 2017）、Dominion ポストモーテム（2012）、デザイン/バランス哲学（2015, Ryan "Morello" Scott）、Greg Street のバランス講演など。Geoff Marsi（TFT/LoL/R&D、サンドボックス系設計）が GDC 講演者として登録されているが題目は未確認 — [GDC: Riot player behavior 2018](https://www.gdconf.com/news/get-tips-riot-design-player-behavior-gdc-2018); [GDC 2017: how Riot creates champs](https://gdconf.com/news/come-gdc-2017-see-riot-creates-league-legends-champs); [MMOBomb: Greg Street balance philosophy at GDC](https://www.mmobomb.com/news/greg-street-discusses-riots-balance-philosophy-league-legends-gdc); [GDC schedule: Geoff Marsi](https://schedule.gdconf.com/speaker/marsi-geoff/82020)
- Mythic 期（2021年1月）の Riot「Quick Gameplay Thoughts」に「約20%のチャンピオンが“Mythic hardbinding”閾値を超えた」との記述があると報じられている — [Sportskeeda（検索スニペット）](https://www.sportskeeda.com/esports/riot-dev-provides-quick-gameplay-thoughts-league-legends-current-state-future-plans-season-11)（本文取得不可・二次情報のため要確認）

### Inferences
- アイテム設計の一次的な“設計判断の記録”としては、上記 dev ブログ群が最も信頼できる素材。

### Gaps
- GDC Vault を直接検索していないため、アイテム専用講演が存在しない確証はない。
- 「Mythic hardbinding」の定義・閾値の一次資料は未確認。

---

## デッキ構築ローグライクへの翻訳ヒント

### Takeaway
LoL/TFT から移植しやすいのは「係数（スケーリング軸）をキャラのカード側に複数持たせ、どの軸を太らせるかを報酬（レリック/装備）で決めさせる」構造と、「選択肢の多様性を数値ガードレールで監視する」運用。Riot の失敗（Mythic）からは「排他スロットは数が要る」「アイテムがキットを上書きしすぎない」を学べる。

### Inferences（移植可能なメカニズム。各項目の根拠は上記 Q1〜Q5 の出典）
1. **カードに複数のスケーリング係数を持たせる（Kayle/Kai'Sa 型）**: 例「ダメージ 6 + 筋力×1.0 + 呪力×0.5」。どのステータスを上げるレリック/装備を拾うかで同じカードの役割が変わる。ただしオフ係数は“小さなフック”に留め（Ashe R の AP 係数）、主係数をはっきりさせる（Q1, Q4）。
2. **スキル（カード群）ごとに担当軸を分ける（Varus 型）**: 攻撃カード A は筋力、多段カード B は“攻撃回数”、大技 C は呪力でスケール。何を伸ばすかで「主役カード」が入れ替わり、同じヒーローで別のデッキになる（Q1）。
3. **閾値で“進化”するカード（Kai'Sa 型）**: 「呪力が 10 以上なら追加効果」「このランで攻撃カードを 15 枚プレイしたら変身」など離散スイッチにすると、ビルド目標が可視化されドーパミンの山が作れる。閾値判定に“何でもなる汎用ステータス”を数えないことで抜け道を防ぐ（Q1, Q4）。
4. **%HP・回数比例ダメージ（Kog'Maw/Varus W 型）**: 固定値でなく「敵最大HPの x%」「1ターンの攻撃回数 × y」でスケールするカードは、ダメージ量を積まない“手数ビルド”を成立させる。ボス（高HP）に強くなるので、雑魚戦とボス戦で評価が変わる二面性も生む（Q1）。
5. **防御ステータスを攻撃に変換（Malphite E 型）**: 「Block の値に比例してダメージ」系。タンクビルドが勝ち筋を持つ（StS の Body Slam と同型）（Q1）。
6. **ビルドの“軸”レリックは排他1枠＋後続でボーナス（旧 Mythic パッシブ型）**: 「この軸レリックは1つだけ。以後同タグのレリックを拾うたびに+1」。ただし Riot の教訓として、排他枠の候補が少ないとキャラの半分が不満になる（約50%）ので、**キャラ×アーキタイプ分の候補を用意できないなら導入しない**（Q2）。
7. **レリック/装備は「ユニーク効果1つ・ステータス3つまで」**: 個性はカード（キャラのキット）側に置き、装備は増幅器に徹する。「何でも得意な装備」は全ビルドに入って多様性を潰す（Q2, Q3）。
8. **素材合成表（TFT 型）**: 道中で拾う“素材”2つで完成装備になる小さな合成表（例: 8素材 → 36通り）。素材のランダムな偏りがランごとの方向性を決め、プレイヤーは手持ちに合わせて構成を即興する。終盤は「完成品から選ぶ」救済（Anvil）で苛立ちを抑えるが、完全な選択式は forcing を招く（Q5）。
9. **特性付与アイテム（Emblem 型）**: 「カードに別アーキタイプのタグを付ける」「キャラに別系統のカードプールを開く」。強さ上限は「その特性の本来の最良の使い手の出力を超えない」で設定（Q5）。
10. **多様性を数値で監視**: 「どのレリックもピック率 75% を超えない」「各キャラに勝率に寄与する選択肢が N 個以上」「代替ビルドは勝率（罰されていないか）と不満度で評価」。ただし“毎回取りたいコア”自体は満足感の源泉なので、コアの存在は許容し周辺（状況選択）で多様性を出す（Q2, Q3）。
11. **カウンター型の選択を“質問”として出す**: Tenacity の「この試合はハードCCが多いか？」のように、次の階層の敵（エリート/ボス）の性質を事前に見せ、「回復阻害が要るか」「防御が要るか」を判断させる。ただし Grievous Wounds の教訓として、対象の脅威が全戦闘に蔓延すると“デフォルト購入”になり選択が消える（Q2）。
12. **「X とは併用不可」の排他ルールは慎重に**: TFT の Dragon 1体制限・Scalescorn は「死にロール」を生み多様性を減らした。排他にするなら報酬テーブルから除外して“死に選択肢”を提示しない（Q5）。

### Gaps
- 上記はすべて LoL/TFT の仕組みからの類推であり、デッキ構築ローグライクでの有効性は未検証（プロトタイプでの確認が必要）。
