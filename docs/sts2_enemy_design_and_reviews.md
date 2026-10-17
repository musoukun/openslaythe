# Slay the Spire 2 の敵設計とレビュー・掲示板の声（事実集）

> 調査日: 2026-10-18。目的は「StS2 は *プレイヤーのカードを伸ばさせない* 方向（1ターンの使用制限、薄いデッキへの罰、遅いビルドを置いていく敵）で難易度を上げているのでは」という仮説の材料を、出典つきで一度だけ集めること。
> 難易度の全体像・レビュー爆撃の経緯・他作品との比較は既存ノート [sts2_difficulty_power_fantasy.md](../research_notes/ビルド多様性%20デッキ構築設計/sts2_difficulty_power_fantasy.md) にあるので、ここでは重複させず、**敵の個別仕様・掲示板の生の声・公式発言**に絞る。
> 凡例: 「未確認」＝ソースで裏が取れていない。「推定」＝状況証拠からの当て推量。

## 0. 読む前の注意

- 敵データの主な出典は [slaythespire.wiki.gg の Slay_the_Spire_2 名前空間](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Enemies)。ファン編集の wiki なので、**数値は版（ベータ/本線）でずれる**。ページによっては「Beta content」の注記が残っており（Soul Fysh / Mecha Knight / Queen / Axebot / Entomancer / Louse Progenitor / Exoskeleton）、2026-06-19 の v0.107.1 で「ベータ変更を本線に統合」されたと別ページに書かれているため、注記が古いだけの可能性がある（**現行本線との一致は未確認**）。
- wiki の変更履歴にある 2024〜2025年の日付は EA（2026-03-05）前の内部開発版の記録。
- 「対策としてプレイヤーが言っていること」欄は、wiki のヒント欄（コミュニティ記述）と Steam 掲示板の発言を混ぜている。どちらかは出典欄で区別する。
- 日本語名は [Game8 のボス一覧](https://game8.jp/slaythespire2/779921)・[エリート一覧](https://game8.jp/slaythespire2/779920)・[敵DB（shunshu-labo）](https://flex.shunshu-labo.org/en/sts2_app/enemies/) にあるものだけ記載。**無いものは「日本語名未確認」**。
- 幕の呼び名: Act1 = Overgrowth（繁茂の地）/ Underdocks（地下水路）の二択、Act2 = Hive（魔窟）、Act3 = Glory（栄光の路）。
- 確認できたボス（2026-10 時点の wiki）: Act1 = Ceremonial Beast / The Kin / Vantom（Overgrowth）、Waterfall Giant / Soul Fysh / Lagavulin Matriarch（Underdocks）。Act2 = The Insatiable / Knowledge Demon / Kaiser Crab。Act3 = Queen / Test Subject / Aeonglass（A10 では2体目が追加）— [wiki: Bosses](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Bosses)。
- StS1 の Time Eater（1ターン12枚制限）への言及が掲示板に多いが、**StS2 の wiki に Time Eater のページは無い**（404）。掲示板の「Time Eater」は StS1 との比較と思われる（StS2 に存在するかは未確認）。

## 1. 日本語YouTubeサムネの4体（画像は参照できないため、キャプションから推定）

> 画像そのものを見ていないので、**外見の一致は確認できていない**。「キャプションの意味」と「wiki の仕様」が合う順に候補を並べた。確定ではない。

### 1-a. 大盾とレイピアの重装騎士 ／ 「やる気出すな」

| 項目 | 内容 |
|---|---|
| 第一候補（推定・低確度） | **Lagavulin Matriarch**（ラガヴーリン・メイトリアーク）— Act1 Underdocks ボス |
| 仕組み | HP 222（A8で233）。開始時 **Plating 12**（毎ターン終了時にブロック獲得、始動ターンごとに-1）と **Asleep 3**（3ターンか、ブロックを抜けたダメージで起床。起床時に Plating を失う）。起床後は Slash 19 → Disembowel 9×2 → Slash2 12＋ブロック12 → **Soul Siphon**（プレイヤーの筋力-2・敏捷-2を**永続**で奪い、自分は筋力+2）の4手周回。 |
| 「やる気出すな」との対応 | 筋力・敏捷（＝強化）を毎周奪う。ダメージ・ブロックの**1回ごと**に効くので多段カードほど弱くなり、Bury / Impervious のような一撃は影響が小さい。 |
| 出典 | [wiki: Lagavulin Matriarch](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Lagavulin_Matriarch) |
| 他の候補 | **The Lost**（Act3 通常。Debilitating Smog で筋力-2を奪い自分に+2、倒すと返す）/ **Hunter Killer**（Act2 通常。Tender: カードを1枚使うたび、そのターンの筋力と敏捷をX失う）/ **Globe Head**（Act3 通常。Galvanic: パワーカードを使うとX点自傷）/ **Test Subject**（Act3 ボス。第1形態でスキルを使うたび筋力獲得）— いずれも「強化・手数を罰する」系。外見が重装騎士かは**未確認**。 |

### 1-b. 緑のツタが絡んだ塊、赤く光る核・目 ／ 「行動するな」（「どの行動もウザイから何も…」）

| 項目 | 内容 |
|---|---|
| 第一候補（推定） | **Vine Shambler**（ヴァインシャンブラー）— Act1 Overgrowth 通常敵 |
| 仕組み | HP 61（A8で64）。Swipe 6×2 → **Grasping Vines**（8ダメージ＋**Tangled（Entangled）**を1付与）→ Chomp 16 の3手周回。Entangled は wiki の抜粋で「Entangled カードは追加で1エナジー要る」。Deadly Poison / Inferno のような"攻撃カードでないダメージ源"は影響を受けない（＝Attack のコスト+1と読めるが、**正確な文言は未確認**）。 |
| キャプションとの対応 | カードを使うほどコストで損をする＝「行動するな」。 |
| 出典 | [wiki: Vine Shambler](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Vine_Shambler)（日本語名は [shunshu-labo](https://flex.shunshu-labo.org/en/sts2_app/enemies/)） |
| 他の候補 | **Slithering Strangler**（絞蛇, Act1 Overgrowth）— Constrict でプレイヤーに「ターン終了時にXダメージ」（使うたび+3）。カード使用は制限しない。/ **Ceremonial Beast**（儀式の獣, Act1 ボス）の Ringing「このターンは1枚しか使えない」— 「行動するな」の意味には最も近いが、外見は獣・骨。 |

### 1-c. 青いトゲの魚 ／ 「イカサマ野郎」（「手札を見て行動を変える」）

| 項目 | 内容 |
|---|---|
| 候補 | **Soul Fysh**（ソウルフィッシュ）— Act1 Underdocks ボス（ご指摘の推定どおり） |
| 仕組み | HP 211（A8で221）。**固定の5手周回**: Beckon（状態異常カード Beckon を2枚混入: 山札1・捨て札1）→ De-Gas 16 → Gaze 7＋Beckon1枚 → **Fade（Intangible 2）** → Scream 13＋Vulnerable 3。**Beckon**（1コスト）は**ターン終了時に手札にあると6HP失う**（ガイドは"ブロック不可"）。 |
| 「手札を見て行動を変える」の裏取り | **確認できず（未確認）**。wiki・[slaythespire2.gg](https://slaythespire2.gg/enemies/soul-fysh)・[games.gg ガイド](https://games.gg/slay-the-spire-2/guides/slay-the-spire-2-how-to-beat-soul-fysh/) はいずれも「手札内容による分岐はない、固定ループ」。動画の言う「手札を見て」は、Beckon が**手札に残ったときだけ罰する**挙動か、別の敵の可能性。 |
| プレイヤーの対策（wiki/ガイド） | Beckon を使わずに処理（廃棄＞捨て）。Fiend Fire / Prepared / Hidden Daggers / BEGONE! など。Doom は Intangible を貫通。低コストで組むと Beckon にエナジーを食われにくい。 |
| 出典 | [wiki: Soul Fysh](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Soul_Fysh)（"Beta only" 注記あり）、Game8 の日本語評は「5ターンに1回霊体化、HPを失う状態異常『喪失』」— [Game8](https://game8.jp/slaythespire2/779921) |
| 備考 | Aeonglass を「Soul Fysh の Beckon の劣化版」とみる声がある（Steam 掲示板, 5月）— [Aeonglass & Doormaker](https://steamcommunity.com/app/2868840/discussions/0/839501596191799934/) |

### 1-d. 大きな翼の緑の鳥 ／ 「単打やめろ」（多段が要りそう）

| 項目 | 内容 |
|---|---|
| 第一候補（推定） | **Thieving Hopper**（泥棒バッタ）— Act2 Hive 通常敵。翼で飛ぶ・緑系という推定だが**外見は未確認**。※追記（サムネを見た所見）: 絵は大きな翼と曲がったくちばしを持つ緑の鳥で、バッタではない。外見からは次点の **Byrdonis** のほうが近い |
| 仕組み | HP 79（A8で84）。固定列: **Thievery**（17ダメージ＋山札か捨て札から**カード1枚を盗む**）→ **Flutter**（自身に Flutter 5: **Attack から受けるダメージ-50%、Attack ダメージを5回当てると Stun**）→ Hat Trick 21 → Nab 14 → Escape（盗んだカードごと逃走）。**Escape Artist 5**（5ターンで逃走を試みる）。 |
| 「単打やめろ」との対応 | Flutter は**回数**を数える＝多段・複数枚で崩すのが正解。一撃は 50% 減で無駄になる。倒せば盗んだカードは返る。 |
| 出典 | [wiki: Thieving Hopper](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Thieving_Hopper)（[slaythespire2.gg](https://slaythespire2.gg/enemies/thieving-hopper) は Escape Artist を4ターンと記載＝版ずれ） |
| 次点 | **Byrdonis**（ビャードニス）— Act1 Overgrowth エリート。HP 81-84（A8で90）、Swoop 17 ↔ Peck 3×3 の交互、**Territorial**（ターン終了時に筋力獲得）で長引くほど Peck の総ダメージが伸びる。掲示板で"green Ostrich"と呼ばれている敵がこれかは**推定**。「単打」を罰する仕様は wiki に無い。— [wiki: Byrdonis](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Byrdonis)、呼称の出典 [Does every enemy have to scale?](https://steamcommunity.com/app/2868840/discussions/0/798967032930473086/) |
| 参考 | **単打が不利になる仕様の一覧は §2-E**（Vantom / Inklet / Flutter / Gardener など）。逆に**多段が不利**な敵（Entomancer, Lagavulin Matriarch）もあり、方向は敵ごとに違う。 |

## 2. カードの使い方を制限・罰する敵の一覧

> 数値は A0 基準（括弧内は高アセンションの値）。列「対策としてプレイヤーが言っていること」の【wiki】はヒント欄、【Steam】は掲示板。

### 2-A. 1ターンに使える枚数・種類を縛る

| 名前 | 幕・種別 | 仕組み | 何を罰するか | 対策としてプレイヤーが言っていること | 出典 |
|---|---|---|---|---|---|
| **Living Fog**（日本語名未確認） | Act1 Underdocks・通常 | 初手 Advanced Gas で **Smoggy**＝「このターン Skill は1枚だけ」（重ならない）。以降 Bloat（Gas Bomb 召喚）と Super Gas Blast を交互。Gas Bomb は HP7・爆発8。 | Skill 中心のデッキ（毒・オーブ型が負けうる） | 【Steam】phantom は Bound ボスは追加ドローで回避できるが、Skill 1枚制限の通常敵は不公平と述べた（要約）。【wiki】対策の記載なし | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Living_Fog)、[Steam: Can only play 1 X per turn](https://steamcommunity.com/app/2868840/discussions/0/806845425982209124/) |
| **Ceremonial Beast**（儀式の獣） | Act1 Overgrowth・ボス | HP 252。Phase1: Plow（18＋筋力2、毎ターン）。HP が150（A9で160）を切ると Stun＋筋力喪失。Phase2: Beast Cry（**Ringing: このターンは1枚しか使えない**）→ Stomp 15 → Crush 17＋筋力3。 | 自動プレイ（Hellraiser, Mayhem）、カード生成（Infernal Blade 等）、Echo Form、手数型全般 | 【wiki】次ターンブロック（Dodge and Roll 等）、Barricade、Beast Cry の日に Weak を撒く。【Steam】BiosTheo は「第2形態で1枚に縛られ、他のAct1戦より明らかに重い」と述べた（要約）。ドロー札が主な解とする声は Queen の thread 側にある | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Ceremonial_Beast)、[Steam: better way to increase difficulty](https://steamcommunity.com/app/2868840/discussions/0/798966340583159532/)、[Steam: Act 1 WAY too hard](https://steamcommunity.com/app/2868840/discussions/0/802341195824217371/) |
| **Queen**（クイーン） | Act3・ボス（Torch Head Amalgam と2体） | HP 400（A8で419）。Puppet Strings で **Chains of Binding 3**＝毎ターン最初に引いたX枚が **Bound**（Bound は1ターンに1枚しか使えない）。You're Mine で全員に Frail/Weak/Vulnerable 99。Amalgam を先に倒すと Queen が Enrage。 | 手札を回して複数枚使うデッキ。Bound 札を引くと実質枚数が減る | 【Steam】ドロー札（Fiddle, Iron Club 等の Act3 の古代遺物）で Bound されない札を増やす（birdhouse, faxfire）。Meinnhart は"追加の敵（Amalgam 等）より先にボスを倒せばデバフ自体が付かない"と助言（Bound ボスのスレ）。Konebred は、それでも「このアーキタイプを組め」になると批判 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Queen)、[Steam](https://steamcommunity.com/app/2868840/discussions/0/798966340583159532/) |
| **Knowledge Demon**（知識の悪魔） | Act2 Hive・ボス | HP 379（A8で399）。Curse of Knowledge: 各プレイヤーが**2択のデバフを選ぶ**（デッキには入らず即時・ゲームから除外）。Set1 = Disintegration（ターン終了時6ダメ）or Mind Rot（ドロー-1）、Set2 = Disintegration 7 or **Sloth（1ターンに最大3枚）**、Set3 = Disintegration 8 or Waste Away（エナジー-1）。以降 Slap 17 / Knowledge Overwhelming 8×3 / Ponder 11＋回復30＋筋力2 を周回。 | 枚数・ドロー・エナジー。**毎回、制限を飲むか固定ダメージを飲むかを選ばせる** | 【wiki】Disintegration は Footwork / Feel No Pain で受ける、Sloth は Impervious / Ice Lance、Waste Away は Pyre、Mind Rot は Runic Pyramid。【Steam】Scribbly は「3枚制限を飲むくらいなら固定ダメージ」と発言、同氏は3枚制限が Silent・Necrobinder・Regent・多くの Ironclad/Defect を"ハードカウンター"すると主張（主観）。Blastom は遅いデッキで"ドローとエナジーを絞る選択"で勝った | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Knowledge_Demon)、[Steam](https://steamcommunity.com/app/2868840/discussions/0/798966340583159532/)、[Steam: 遅いデッキが罰せられるスレ（Blastom の発言）](https://steamcommunity.com/app/2868840/discussions/0/798967297092918959/) |
| **Doormaker**（ドアメーカー）＝**削除済み** | Act3・ボス（2026-05-08 の v0.105.0 で Aeonglass に置換） | 最終形（v0.101.0〜v0.103.0 の調整後）: **Hunger**＝Attack/Skill を使うと廃棄、**Scrutiny**＝追加ドロー不可、**Grasp**＝カードを使うたびエナジー-1。固定順で Hunger 30 → Scrutiny 24 → Grasp 10×2＋筋力3。 | 薄いデッキ、ドロー回し、廃棄で消えるStrike/Defend、0コスト・多枚数 | 【Steam】「適応せよ、ボスは事前に分かる」（Jevmen, Zvy）、「最も組み甲斐のあるボス」（FIGBird）。批判側は「薄く回すデッキを罰する」（xmanu23）。DeMasked は「1〜2回限りの効果にせよ」 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Doormaker)、[Steam: kills the motivation](https://steamcommunity.com/app/2868840/discussions/0/798967628136754847/)、[Steam: Exhausting Your Cards Rocks](https://steamcommunity.com/app/2868840/discussions/0/798967628136831723/) |
| **Knight Gang**（騎士のギャング） | Act3・エリート | **Spectral Knight** の Hex＝生存中は**全カードが Ethereal**、**Magi Knight** の Dampen＝生存中は**全カードがダウングレード**（Nightmare 生成札は対象外）。Flail Knight は筋力3ずつ。 | カードを溜めて使うデッキ、アップグレード前提のデッキ | 【Steam】Bradhandler「高ダメージの騎士を先に倒す」。DeMasked の集団は Ethereal 付与側を先に狙う。game8は「順に倒してデバフを解除」 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Knight_Gang)、[Game8](https://game8.jp/slaythespire2/779920)、[Steam](https://steamcommunity.com/app/2868840/discussions/0/798967628136831723/) |

### 2-B. エナジー・コスト・手数に課税する

| 名前 | 幕・種別 | 仕組み | 何を罰するか | 対策としてプレイヤーが言っていること | 出典 |
|---|---|---|---|---|---|
| **Vine Shambler**（ヴァインシャンブラー） | Act1 Overgrowth・通常 | Grasping Vines で Entangled（カード追加コスト＝§1-b） | 高コスト化で動けなくなる | 【wiki】Deadly Poison / Inferno は影響なし | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Vine_Shambler) |
| **Hunter Killer**（ハンターキラー） | Act2 Hive・通常 | HP 121。開幕 Tenderizing Goop で **Tender**＝カードを使うたび、そのターンの筋力と敏捷をX失う（効果解決後に引かれる。連鎖カードは全体で枚数分）。Bite 17 / Puncture 7×3。 | 1ターンにたくさん使うデッキ | 【wiki】記載なし（未確認） | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Hunter_Killer) |
| **Infested Prism**（寄生されたプリズム） | Act2 Hive・エリート | HP 161（A8で171）。**Vital Spark 2（A9で3）**: Skill は全て **Tainted X**＝Skill を使うと、そのターンに受ける Attack ダメージがX増える。Jab 15 → Radiate 11＋ブロック16 → Whirlwind 5×3 → Pulsate 8＋ブロック20＋Vital Spark。 | 安い Skill の連打（ブロック札連打） | 【wiki】Skill でない（Iron Wave 等）ブロックを使う、高コスト Skill を1回だけ使う。毒・No Escape は被ダメージが増えるので弱い。※Game8 は別の説明（攻撃でエナジー獲得）＝v0.106.0 の再設計前の記述の可能性、**不一致は未確認** | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Infested_Prism)、[Game8](https://game8.jp/slaythespire2/779920) |
| **Globe Head**（日本語名未確認） | Act3 Glory・通常 | HP 148。**Galvanic 6（A9で8）**＝パワーカードに **Galvanized**＝使うとX点自傷（ブロックで防げる）。Shocking Slap 13＋Frail → Thunder Strike 6×3 → Galvanic Burst 16＋筋力2。 | パワー（育成札）を使うこと自体 | 【wiki】Rupture / Inferno / Buffer は B<6 だと自傷。Buffer で相殺可 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Globe_Head) |
| **Owl Magistrate**（日本語名未確認） | Act3 Glory・通常 | HP 234。Scrutiny 16 → Peck 4×6 → Judicial Flight（**Soar: 受ける Attack ダメージ-50%**）→ **Verdict 33＋Vulnerable 4**。変更履歴上、Scrutiny 付きのカードは**使うと使用者に3ダメージ**（廃棄は外された）。 | 手数、特に Soar 中の攻撃 | 【wiki】記載なし。Scrutiny 状態の細かい仕様は**未確認** | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Owl_Magistrate) |
| **Aeonglass**（永遠の砂時計） | Act3・ボス（Doormaker の後任, v0.105.0〜） | HP 512（A8で535）。Ebb 22＋ブロック33 → Eye Lasers 11×2 → Increasing Intensity（Wither を捨て札へ、筋力+2+X、山の Wither を全アップグレード）。**Withering Presence**＝**6枚使うごとに Wither が手札に入る**。**Wither**＝使用不可、ターン終了時に手札にあると3ダメージ（A9で6）。Artifact 3。 | 手数（6枚ごとの課税）と、薄いデッキ、シヴ型 | 【wiki】Stoke / GUARDS!!! / Flak Cannon で一括除去、Prepared で捨てる、Purity で最大3枚廃棄。【Steam】「Soul Fysh の Beckon の劣化版」「状態異常札でエナジーを税金にするのは退屈」（lackOfBetterTitle）。Steam 否定レビュー（508人が参考）は「デッキ構築を圧迫、カード制限が主因」 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Aeonglass)、[Steam thread](https://steamcommunity.com/app/2868840/discussions/0/839501596191799934/)、[否定レビュー上位](https://steamcommunity.com/app/2868840/negativereviews/?browsefilter=toprated) |
| **The Insatiable**（貪りの獣） | Act2 Hive・ボス | HP 321（A8で341）。開幕 Liquify Ground で **Sandpit**（プレイヤーごとにカウントダウン、0で**即死**。Fairy in a Bottle / Lizard Tail でも救えない）＋ **Frantic Escape を6枚混入**。Thrash 8×2 → Lunging Bite 28 → Salivate 筋力+2。 | 長期戦（タイマー死）。Frantic Escape の使用コストが逃げの代償（Game8: 使うごとにエナジー増） | 【wiki】Iteration と相性が良い。Flak Cannon は Frantic Escape を消すので危険。Poison は食われる前に発火 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:The_Insatiable)、[Game8](https://game8.jp/slaythespire2/779921) |

### 2-C. 状態異常・呪いカードを山に混ぜる（薄いデッキほど痛い）

| 名前 | 幕・種別 | 仕組み | 何を罰するか | 対策としてプレイヤーが言っていること | 出典 |
|---|---|---|---|---|---|
| **Phrog Parasite**（寄生カエル） | Act1 Overgrowth・エリート | HP 61-64。Infect（**Infection 3枚を捨て札へ**）と Lash 4×4（A9で5×4）の交互。倒すと **Wriggler 4体**（それぞれ Wriggle で Infection 1枚＋筋力2）。Infection は使用不可・ダメージ札（"3ダメージ"は履歴の推定＝**未確認**）。 | 序盤の薄いデッキ（山が小さいほど混入率が高い） | 【wiki】早く倒す（Perfected Strike, Backstab, Defile）、毒/Doom でWrigglerの出現を遅らせる、Compact / Flak Cannon / Burning Pact で除去。【Steam】「序盤エリートのせいでコンプしない」「大きい山(約40枚)で薄まる」（ben）vs「この時点で山は薄い」（phantom） | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Phrog_Parasite)、[Steam: my biggest complaint](https://steamcommunity.com/app/2868840/discussions/0/806846033424309545/) |
| **Entomancer**（エントマンサー） | Act2 Hive・エリート | HP 145（A8で165）。**Personal Hive**＝**Attack で被弾するたびに Dazed を山札へ**（ヒット単位）。Beeeees! 3×7（A9で×8）→ Spear! 18 → Pheromone Spit（Hive+1・筋力+1、Hive3なら筋力+2）。 | **多段攻撃**（ヒット数ぶん Dazed が増える） | 【wiki】一撃の大ダメージ（Bludgeon, Bury）か非攻撃ダメージ（Snakebite, Inferno, No Escape）を使う。Feel No Pain / Compact で Dazed を得に変える | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Entomancer) |
| **Soul Fysh**（ソウルフィッシュ） | Act1 Underdocks・ボス | §1-c。Beckon を毎周混入。 | 手札に残したBeckon | §1-c | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Soul_Fysh) |
| **Vantom**（ヴァントム） | Act1 Overgrowth・ボス | Dismember 27（A9で30）で **Wounds 3枚を捨て札へ**。 | 山札の質 | 【wiki】Stoke / BEGONE! で Wounds 除去 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Vantom) |
| **Test Subject**（実験体） | Act3・ボス（3形態） | 第2形態 **Painful Stabs**＝ブロックされなかった攻撃ダメージを受けるたび Wounds を捨て札へ。第3形態 Burning Growl で Burn 3枚（A9で5枚）。 | 防御が薄い手番、長期戦 | 【Steam】3ターン以内に倒す／Weak・筋力低下で受ける（roobs）、「もっとスケーリングを取れ」（Zu） | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Test_Subject)、[Steam](https://steamcommunity.com/app/2868840/discussions/0/662737213850818049/) |
| **Mecha Knight**（メカナイト） | Act3・エリート | HP 300（A8で320）。Charge 25 → Flamethrower 8＋**Burn 4枚を手札へ** → Windup（ブロック15・筋力+5）→ Heavy Cleave 35 を周回。Artifact 3。 | 手札の圧迫、デバフ前提のデッキ | 【wiki】Burn を意識、Artifact に最初のデバフを吸わせる | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Mecha_Knight) |
| **Slimed Berserker**（日本語名未確認） | Act3 Glory・通常 | HP 261〜266。Vomit Ichor で **Slimed 10枚を捨て札へ**。Furious Pummeling 4×4、Leeching Hug（Weak3・筋力+3）、Smother 30。 | 山の質（量で押す） | 【wiki】記載なし | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Slimed_Berserker) |
| **Fabricator / Noisebot / Chomper / Haunted Ship / Eye With Teeth / Myte** | Act3 / Act2 / Act1 通常 | Noisebot: Dazed 2枚（山・捨て）／Chomper（チョンパー）: Screech で Dazed 3枚／Haunted Ship: Haunt で Dazed 5枚＋Weak 3／Eye With Teeth（牙をむく眼）: Distract で毎ターン Dazed 3枚（倒しても翌ターン復活）／Myte（マイト）: Toxic 2枚を**手札へ** | 小さい山、手札の枠 | 【Steam】「ターンごとに2枚、ほとんど廃棄されずに戦闘終盤は山の約60%が敵の混入札」（Zerccies）。各キャラに除去手段あり（ekisman） | 各 wiki ページ、[Steam](https://steamcommunity.com/app/2868840/discussions/0/806846033424309545/) |

### 2-D. 強化・パワー・ステータス（筋力・敏捷）を罰する／奪う

| 名前 | 幕・種別 | 仕組み | 何を罰するか | 対策としてプレイヤーが言っていること | 出典 |
|---|---|---|---|---|---|
| **Lagavulin Matriarch** | Act1 Underdocks・ボス | §1-a。Soul Siphon が筋力・敏捷を永続-2。 | 筋力/敏捷スケーリング、多段 | 【wiki】眠っている3ターンでパワーを仕込む（Demon Form 等）、単発の大ダメージ（Bury）を選ぶ。毒は起こしてしまう | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Lagavulin_Matriarch) |
| **The Lost / The Forgotten** | Act3 Glory・通常ペア | Lost: Debilitating Smog で筋力-2を奪い自分に+2。Forgotten: Miasma で敏捷-2を奪う。倒すと返す。 | 筋力/敏捷 | 【wiki】記載なし。倒せば戻る | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:The_Lost) |
| **Test Subject** 第1形態 | Act3・ボス | **Enrage**＝**Skill を使うたび**敵が筋力獲得。HP100と低い（A9で111）。 | Skill 連打 | 【wiki】Skill を控える。【Steam】3ターン以内に倒す | §2-C と同じ |
| **Hunter Killer / Globe Head / Infested Prism** | §2-B | カード使用ごとに筋力敏捷の消耗・パワー自傷・Skill で被ダメ増 | 手数・パワー・Skill | §2-B | §2-B |
| **Terror Eel**（テラーウツボ）（分類外: 永続デバフ） | Act1 Underdocks・エリート | HP 140（A8で150）。HP が半分（70）になると Stun → Terror＝**Vulnerable 99（戦闘中ずっと）**。Crash 16 / Thrash 3×3＋Vigor 6 の交互（3ターン目以降 Crash は22）。 | 高HPのまま粘る展開 | 【wiki】Stun の間に押し込む | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Terror_Eel) |

### 2-E. ダメージの上限・多段/単打で別解を要求する

| 名前 | 幕・種別 | 仕組み | 有利/不利になるのは | 対策としてプレイヤーが言っていること | 出典 |
|---|---|---|---|---|---|
| **Vantom** | Act1・ボス | HP 173。**Slippery 9**＝次の9回の HP 減少は**1しか減らない**。 | **多段・毒・DoT が有利、単打は不利** | 【wiki】Conflagration / Lunar Blast 等の多段、毒（1ターン1スタック消す）、Inferno | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Vantom) |
| **Inklet**（インクレット）×3 | Act1・通常 | HP 11-17。Slippery 1。 | 多段 | 【wiki】記載なし | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Inklet) |
| **Thieving Hopper** | Act2・通常 | Flutter: 50%減、5回で Stun（§1-d）。 | 多段 | §1-d | §1-d |
| **Phantasmal Gardener**（幻影蟲, Game8 表記） | Act1 Underdocks・エリート×4体 | HP 26-31。**Skittish 6**＝各ターン**最初に受けた攻撃で**ブロック6を得る。Flail 1×3 など。 | 1体に1ヒットずつ単発で当てる攻撃 | 【wiki】Sow / Dagger Spray など全体多段、非攻撃ダメージ（Negative Pulse, Flame Barrier, Noxious Fumes）、Sunder | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Phantasmal_Gardener) |
| **Skulking Colony**（蠢く群生体） | Act1 Underdocks・エリート | HP 75（A8で80）。**Hardened Shell 20**＝**1ターンに失えるHPは20まで**（プレイヤーのターン開始時・敵のターン開始時にリセット）。Zoom 14×2 → Inertia 9＋筋力 → Piercing Stabs 7×2。 | 大ダメージの一撃、1ターン集中 | 【wiki】毒＋攻撃で敵のターン開始時に再度削る（最大40/ラウンド）、Thorns 系 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Skulking_Colony)、[Game8](https://game8.jp/slaythespire2/779920) |
| **Exoskeleton** | Act2・通常 | **Hard to Kill**＝受けるダメージを**1ヒット9まで**に制限（Doom/End of Days は貫通）。 | 大ダメージの一撃 | 【wiki】記載なし | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Exoskeleton) |
| **Entomancer** | Act2・エリート | §2-C。**多段がDazedを増やす**。 | **多段が不利、単打が有利** | 【wiki】Bludgeon / Bury | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Entomancer) |
| **Lagavulin Matriarch** | Act1・ボス | Soul Siphon は1ヒットごとに効く。 | **多段が不利、単発が有利** | §2-D | §2-D |
| **Bygone Effigy**（古の偶像）（逆の例） | Act1 Overgrowth・エリート | HP 127（A8で132）。**Slow**＝カードを1枚使うたび、そのターンに受ける Attack ダメージ+10%。起床後は筋力10＋Slashes 13。1ターン目は眠り。 | **枚数を使うほど有利**（罰ではなく報酬） | 【wiki】Shiv や Soul で Slow を稼ぐ、Bludgeon で起床前に倒す | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Bygone_Effigy) |

### 2-F. 時間（遅いプレイ）や位置を罰する

| 名前 | 幕・種別 | 仕組み | 何を罰するか | 出典 |
|---|---|---|---|---|
| **Waterfall Giant**（滝の巨人） | Act1 Underdocks・ボス | HP 240（A8で250）。ほぼ全行動で **Steam Eruption** が溜まり、倒すと無敵→**次ターン終了時に蓄積分のダメージで爆発**。Pressure Gun は使うたび+5。 | 長引く戦闘、最後のターンにブロックが無い手札（Strike過多）。Mega Crit は v0.101.0 でHP-10、v0.104.0 で回復を弱体化 | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Waterfall_Giant)、[Steam: fun choice](https://steamcommunity.com/app/2868840/discussions/0/839500962846540207/)（MonoAIBA が「倒しても死ぬ」と批判） |
| **Byrdonis / Corpse Slug / Fuzzy Wurm Crawler / Snapping Jaxfruit など** | Act1 通常・エリート | 筋力を毎ターン加算（Territorial, Ravenous, Inhale, Energy Orb） | 長引く戦闘（"Tetris が加速する"という比喩, paincanbefun） | 各 wiki、[Steam](https://steamcommunity.com/app/2868840/discussions/0/798967032930473086/) |
| **Kaiser Crab** | Act2・ボス（2体） | プレイヤーは Surrounded。**カードを使うと使った相手の方を向く**。背後からの攻撃は+50%。ランダム対象の自動プレイ（Hellraiser, Sly, Stampede）で向きが変わる。片方を倒すと残りが筋力+6・ブロック99。 | 単体対象カードの使い方、自動プレイ | [wiki](https://slaythespire.wiki.gg/wiki/Slay_the_Spire_2:Kaiser_Crab) |

### 2-G. 掲示板の言う"嫌な"パターンの傾向（上の表からの整理）

- **枚数・種類の縛り**（Smoggy, Ringing, Bound, Sloth, Hunger）は Act1 通常〜Act3 ボスまで**全幕に配置**されている。
- 縛りは **「引く／使う／消費する」の3軸**に分散: 使用枚数（Smoggy, Ringing, Bound, Sloth）、ドロー（Mind Rot, Scrutiny）、エナジー・コスト（Waste Away, Grasp, Entangled, Beckon, Wither）、廃棄（Hunger, Ethereal）。
- **ボスの縛りは「選べる」ものと「強制」のものが混在**: Knowledge Demon（選択）は掲示板の不満がある一方で議論の中心が「どれを飲むか」。Doormaker（強制）は撤去された。
- **多段/単打の方向は敵ごとに逆**。

## 3. レビュー・掲示板の不満の整理

> 「」内の日本語は**要約**であり原文の引用ではない（原文の引用は英語の短い断片のみ・15語未満）。すべて Steam 掲示板（app 2868840）の要約。日付は 2026年。スレッドは本文先頭15件前後のみ読めたものが多く、**スレ全体の傾向とは限らない**。

### 3-1. 敵のスケールが速い（全敵が筋力を積む）

- 不満: 「Str scaling on every mob is lazy design」（Zirn, 3/25）。数値を大きくするだけで面白い仕組みが無く、特定アーキタイプに寄る、戦闘が"レース"になる、という主張。— [thread](https://steamcommunity.com/app/2868840/discussions/0/798965318966962580/)
- 不満: 「Does every enemy have to scale?」（Peaches, 4/13）。StS1 の全敵が筋力を積んだわけではなく、StS2 は遅い守備が罰せられるという主張。— [thread](https://steamcommunity.com/app/2868840/discussions/0/798967032930473086/)
- 反論: スケールは「カードゲームのランプ」であり、5ターン目と1ターン目が同じ火力なら調整が悪い（Missingno.）。DPS チェックとして必要（zero）。Tetris が速くなるのと同じ（paincanbefun）。カード側も伸びるので敵も伸びないと退屈（BaconX）。
- 数字: Steam 否定レビュー（432人が参考, 9/10）「パッチごとに敵がパワークリープ」— [否定レビュー上位](https://steamcommunity.com/app/2868840/negativereviews/?browsefilter=toprated)
- 反証的な公式統計: Mega Crit によると A0 の平均勝率は 16%（StS1 は 9%）、全体 25%、A10 約17%— [Neowsletter May 2026](https://www.megacrit.com/news/2026-5-22-neowsletter-issue-22/)

### 3-2. 遅い／守備的なビルドが罰せられる

- 不満: Block ＋ Doom のデッキが Act2 ボスのHPと回復に打ち負けた（Shao）。「Act2 の前にデッキが完成している」のに勝てない、A10 で他のデッキを成り立たせてほしい。— [thread](https://steamcommunity.com/app/2868840/discussions/0/798967297092918959/)
- 不満: 「Act1 のボスは前作より遅いデッキを罰する」（phantom, 6/9）。— [thread](https://steamcommunity.com/app/2868840/discussions/0/563659290304322907/)
- 反論: 「遅いデッキは悪いデッキ、問題は一貫性」（Ray）、「堅守にも火力が要る」（Zarkawi）、「前作にもスケーリング戦はあった」（Zuul, Lamasu）、「StS1 の Champ は遅いプレイが効くボス」（Songbird）。※このスレは Hexaghost / Champ / Donu and Deca など **StS1 のボス**との比較が混在している。
- 数字: Steam 否定レビュー（245人が参考, 7/9）「敵が遅いデッキを罰し、面白さよりフラストレーションを増やす」。
- 同方向のプレイヤーの対処: 「守りは敵のスケールを上回るときだけ成立」（Julez, Blur と Sly を挙げた）。

### 3-3. カード使用制限（"Can only play 1 X per turn"）

- 不満: Skill 1枚制限の敵と、Bound（3枚のうち1枚）のボスはアンチファン（ryuflare, 3/11）。毒 Silent や Defect のオーブでも負ける。— [thread](https://steamcommunity.com/app/2868840/discussions/0/806845425982209124/)
- 不満: 「制限は難易度を上げる悪い方法」（Konebred）。「負けから学び、組んだカードから価値を絞り出したいのに、使えない」。WoW のボスがスキルをロックするのと同じ、「このアーキタイプを組まなければ負け」（Konebred）。— [thread](https://steamcommunity.com/app/2868840/discussions/0/798966340583159532/)
- 反論: 「プレイが下手なだけ」（DeduceTheSus）、ボスは事前に分かるので準備（hospitalman）、ドロー系遺物で緩和（birdhouse, faxfire）、Bound は枚数ドローで回避（phantom）。
- 数字: 「Doormaker は薄い／ドロー回しデッキを罰する」（Steam 否定レビュー 267人, 4/23）「デッキの構築方法が何通りも潰される」「Slay the Spire のひどい MOD のよう」。
- 数字: 「Aeonglass はデッキ構築を抑圧、他の最終ボスよりずっと強い」（Steam 否定レビュー 508人, 7/3）。

### 3-4. 状態異常カードの混入

- 不満: 敵が状態異常を入れすぎ、戦闘終盤は山の約60%が混入札。除去手段が足りない（Zerccies, 3/17）。— [thread](https://steamcommunity.com/app/2868840/discussions/0/806846033424309545/)
- 反論: 意図的な設計。Act1 エリートは早く倒せ（junkevil, Missingno.：「ここは粘れない戦闘」）。各キャラに除去手段がある（ekisman）。大きい山で薄める（ben）。
- 論点が割れる箇所: 序盤エリート（Phrog Parasite）は山にまだカードが少なく除去も無い（Finvaara, phantom）。
- 関連: 「エリートはゴミで山を埋める。シャッフル運とカードの偏りで勝敗が決まる」（CatShark, 6/10）— [thread](https://steamcommunity.com/app/2868840/discussions/0/563659290304322907/)

### 3-5. エネルギー不足

- 不満: エナジー生成がほぼ必須で、デッキが高速化する（MonoAIBA）— [thread](https://steamcommunity.com/app/2868840/discussions/0/839500962846540207/)。上位の否定レビュー（481人, 3/21, 中国語の翻訳）は「エナジーの遺物は前作より出にくい」「エリートが大幅強化されたのにスターターは強化されず、焚き火で回復を選ぶことになる」と主張。
- 反論: ドラフトで足りないものに合わせて構築するのがゲーム（FIGBird）。ゲーム内に Ancient（古代遺物の選択肢）があり前作より多様（Eruda の肯定レビュー, 3/11）。
- 公式: エナジー不足について Mega Crit の直接発言は見つからず（**未確認**）。

### 3-6. 回復不足

- 不満: Reaper / Bandage Up が無く、回復が RNG と休憩所頼み（MonoAIBA）。「休むか強化かの二択でスノーボールになる」（CatShark）。
- 反論: StS1 より休む方が有効（mstang84）、ボス/エリート前に休む戦略は有効（Fadeway）。
- 公式: 回復量についての発言は **未確認**。Waterfall Giant の回復は v0.104.0 で弱体化（Siphon 15→10）。

### 3-7. 1幕が重い

- 不満: 序盤の3〜4戦で運が決まる、ホールウェイ戦闘で 30 ダメージ（Sonnenbank, 5/27）、A9 以降は「カーブストンプされる」（Risenzealot, 5/16）、「Act1 が A0 でも前作の A10 並み」（BiosTheo, 3/6）。
- 反論: A9 は「前作の A19 並みの難度ジャンプ」だから下げて遊べ（MoogleHunter, AbigailMcD19）、「難しいモードは難しいのが仕様」（Missingno.）、「Act1 は良い札を数枚取れば易しい」。
- 公式: v0.104.0 で低アセンションの Act1 敵 HP を下げ、高アセンションを上げた（Giovannetti「base difficulty is quite hard」）— §4。

### 3-8. 楽しい選択が間違いになる

- 不満: 「面白い札を取るとデッキが弱くなる罠が多い」「A0 の StS2 は StS1 の A10+ 級」（MonoAIBA）— [thread](https://steamcommunity.com/app/2868840/discussions/0/839500962846540207/)
- 反論: 学習と実験がこのゲームの本質（FIGBird）、低難度では楽しい選択も通る（paincanbefun）、「意図が気に入らないことは反楽しいとは別」（zero）。MonoAIBA 本人も後に「高難度でも楽しい選択は正しくありうる」と軟化。
- 近い声: 「Test Subject にはもっとスケーリングを取れ」（Zu）に対し、そこまで強いデッキなら敵の数字は無意味という皮肉（Rune）— [thread](https://steamcommunity.com/app/2868840/discussions/0/662737213850818049/)

### 3-9. 戦闘が遅い

- StS2 の Steam 掲示板で「戦闘が遅い／アニメが長い」を主題にしたスレは**今回の検索では見つからなかった（未確認）**。
- 関連しうる事実: Mega Crit は β パッチの頻度を週次から隔週に落とした（理由は"ペースがきつい"）— [Neowsletter May 2026](https://www.megacrit.com/news/2026-5-22-neowsletter-issue-22/)。戦闘速度の話ではない。

### 3-10. その他（運 / 数値チェックの戦闘）

- 運: 「A9+ はスロットマシン」（Swaggertin）、「スキルが効かなくなり RNG だけが残る」（Reshy, 5/27）— 反論は「それは RNG ではなく HP を減らす戦闘」（Decadence）。— [hallway fights thread](https://steamcommunity.com/app/2868840/discussions/0/662737213850669857/)
- 戦闘が「数字チェック」: Steam 否定レビュー最上位（1,369人, 5/5）「多くの戦闘は即座の数値チェック」。
- 肯定側: A10 を Ironclad でクリアして満足（Burak Tezateser, 1,168人, 3/8）、「バランスの問題はあるが簡単ではない」（Eruda, 259人）。難易度を主題にした肯定レビューは少数で、芸術・コンテンツ・協力プレイの称賛が中心。— [肯定レビュー上位](https://steamcommunity.com/app/2868840/positivereviews/?browsefilter=toprated)

### 3-11. Steam レビュースコアの推移（取得できた点だけ）

| 時点 | スコア | 出来事 | 出典 |
|---|---|---|---|
| 2026-03-19 | 97%（Overwhelmingly Positive） | EA 2週間後 | [Kotaku 2026-03-20](https://kotaku.com/slay-the-spire-2-steam-review-bomb-balance-patch-prepared-doormaker-2000680603) |
| 2026-03-20 | 83%（Very Positive、約6万件）、一晩で約1.1万件の否定 | β v0.100.0（Prepared 弱体、Doormaker 強化） | 同上 |
| 2026-04-17〜22 | 全期間 66% / 直近 48%、5日で21,000件超の否定 | Major Update #1（v0.103.2）で Doormaker リワークほか | [Yahoo(転載) 2026-04-22](https://tech.yahoo.com/gaming/articles/slay-spire-2-plummets-66-164841860.html)、[games.gg 2026-04-26](https://games.gg/news/slay-the-spire-2-steam-reviews/) |
| 2026-10-18（取得時） | 全英語 91%（Very Positive、71,029件）/ 直近30日 72%（Mostly Positive、3,718件） | Aeonglass 以後 | [Steam ストア](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) |

- 4月と10月の**中間（5〜9月）の推移は未確認**。
- 数値の不一致（3月の否定件数 4,800 / 8,500 / 10,000+ など）は既存ノートに整理済み。

## 4. Mega Crit の公式発言（Neowsletter・パッチ周辺）

| 時期 | 発言（要旨） | 出典 |
|---|---|---|
| 2026-03-13 | 「Balancing the game will be a constant journey」。データとフィードバックで決め、本線への反映は準備できたとき、頻繁な更新は公開β。 | [Neowsletter #20](https://www.megacrit.com/news/2026-3-13-neowsletter-issue-20/) |
| 2026-03-19〜20 | β v0.100.0 の目的は「make infinites harder to achieve」。「This one has a huge balance pass」。Doormaker は10枚目のドローを消費する形に強化。 | [Kotaku](https://kotaku.com/slay-the-spire-2-steam-review-bomb-balance-patch-prepared-doormaker-2000680603) |
| 2026-03-27 | v0.101.0 で Prepared / Borrowed Time / Capture Spirit を元に戻す。「Progress will not be linear」（Giovannetti, sts2front 経由）。ヘッダー: 「No change is necessarily permanent」（PC Gamer 見出しのみ）。Doormaker の行動の乱数を減らす弱体、序盤エリートの出現階を1つ後ろにずらす（Neow を1階に数える）、**A6 の Gloom は "難しいが面白くない" として再設計予定**。Prepared は Sly との相性が強すぎるので別の方法で調整する方針。 | [Automaton(日本語)](https://automaton-media.com/articles/newsjp/slay-the-spire-2-20260327-432680/)、[sts2front](https://www.sts2front.com/tips/v0101-patch-revert-analysis/)、[PC Gamer(見出し)](https://www.pcgamer.com/games/card-games/mega-crit-responds-to-the-panic-over-slay-the-spire-2s-1st-balance-pass-saying-these-changes-are-the-first-of-many-no-change-is-necessarily-permanent/) |
| 2026-04-10〜17 | v0.103.0 で Living Fog と Doormaker を弱体（具体的な数字は未確認、editorial の記述）。「fair but still punishing」を目標とする旨は sts2.gg の記事の表現で、Mega Crit の直接発言かは**未確認**。Major Update #1（v0.103.2）で Doormaker リワークをβから本線へ。A6 の Gloom は Inflation に（untapped の検索結果要約のみ、本文403で**未確認**）。 | [sts2.gg](https://sts2.gg/guides/april-2026-patch-guide)、[電ファミ(日本語)](https://news.denfaminicogamer.jp/news/260417y)、[sts2.gg patch notes](https://sts2.gg/patch-notes) |
| 2026-04-17 | 「reworking/balancing content so that all of the cards and items feel interesting and viable!」。エンドレスモードは「Probably not」（ランが長いほどデッキ構築が面白くなくなる）。 | [Neowsletter #21](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/) |
| 2026-04-24 | Giovannetti がベース難易度を「quite hard」と認める。低アセンションの Act1 敵のHPを下げ、高アセンションは上げる（Scrolls of Biting / Owl Magistrate / Slimed Berserker、Vantom、Waterfall Giant の回復）。"低/高の差は小さく広げる"。Doormaker は統計上「good place」。 | [eTeknix](https://www.eteknix.com/slay-the-spire-2-difficulty-rebalanced-in-latest-beta-patch/) |
| 2026-05-22 | 勝率: 総ラン2.4億・勝ち6,050万＝全体25%、A0平均16%（StS1 は9%）、A10 約17%（StS1 A20 は3%）。**Doormaker 撤去**: 「provided some interesting micro-decision-making situations」だが「a bit more complex than what we want」。後任 Aeonglass。β頻度を隔週に。 | [Neowsletter #22](https://www.megacrit.com/news/2026-5-22-neowsletter-issue-22/) |
| 2026-06-19 | Doormaker の着想について Casey「I was playing too much Deadlock」（Q&A）。Bestiary 追加。 | [Neowsletter #23](https://www.megacrit.com/news/2026-6-19-neowsletter-issue-23/)、[games.gg](https://games.gg/news/slay-the-spire-2-deadlock-boss/) |
| 2026-07-17 | Aeonglass の制作過程（砂時計＋回るリング、Wither デバフ）。難易度/バランスの話題なし。 | [Neowsletter #24](https://www.megacrit.com/news/2026-7-17-neowsletter-issue-24/) |
| 2026-08-14 | Casey「Ascension 10 is close to the highest difficulty we'll have」、A20 を埋めるのは苦行。エンチャントのスタック禁止の理由は"単一カードの雪だるま化が増える"から、そして**「We want our players to experience deckbuilding rather than cardbuilding!」**。実験的ゲームモードを開発中、別 Act2 と新キャラが優先。 | [Neowsletter #25](https://www.megacrit.com/news/2026-8-14-neowsletter-issue-25/) |
| 2026-09-25 | 難易度・バランスの話題なし（"secret features, game modes, content" の作業再開のみ）。 | [Neowsletter #26](https://www.megacrit.com/news/2026-9-25-neowsletter-issue-26/) |

- 一次資料の注意: 公式パッチノート本文（Steam ニュース）は今回の取得ではページ本文が取れず、**数値の一次確認は未確認**。ここでの記述は Neowsletter 本文、報道、ファンサイトの要約に依拠している。
- 「Casey」＝ Casey Yano、「Giovannetti」＝ Anthony Giovannetti（Mega Crit 共同代表）。
- 「カード数で押す」ではなく「適応させる」ための敵という公式の言い回し（"counter-pick"など）は**見つからず（未確認）**。

## 5. 本作が避けたいこと／取り入れてよいこと（事実から導ける範囲）

**避けたいこと**

1. **序盤の通常敵に「このターンは Skill 1枚」のような種類縛りを常時載せる** — Living Fog は Act1 通常敵で Skill を1枚に制限し、掲示板で最も不満が出て、v0.103.0 で弱体化された（§2-A, §3-3）。
2. **ボスで「ドロー・エナジー・廃棄」を同時に絞る複合ロック** — Doormaker は3フェーズすべてが"デッキそのものを罰する"と批判され、Mega Crit も複雑すぎるとして撤去した（§3-3, §4）。
3. **強制 exhaust / 強制ダウングレードのような"選べない"損失** — 「自分で選ぶ廃棄は良い、ボスに強制されるのは嫌」（DeMasked）。Knight Gang の Hex / Dampen も同型（§2-A）。
4. **デッキが育つ前の序盤エリートに、山を薄くすると損をする混入札（Infection 型）を置く** — 「後半なら対処できるが序盤は詰む」（Finvaara）（§3-4）。
5. **特定アーキタイプへの"ハードカウンター"になる制限（3枚制限 / 1枚制限）を回避手段なしで置く** — 「このアーキタイプを組め、さもなくば負け」（Konebred）（§3-3）。ドロー札・次ターンブロックなど回避手段の有無で評価が割れている。
6. **全敵が筋力を積む"レース"一辺倒** — 「lazy design」批判（Zirn）。一方で擁護も多く、スケールそのものより"遅い守備しか許さない"ことへの不満が実態（§3-1, §3-2）。
7. **難しさをベース難度に焼き込む** — Mega Crit 自身が A0 を「quite hard」と認め、低アセンションを緩和した（§4）。

**取り入れてよいこと**

8. **「制限を飲むか、固定ダメージを飲むか」を選ばせる形（Knowledge Demon 型）** — 毎回2択で、必ず"制限なしのダメージ案"が含まれ、デッキに入らない一時デバフ。「3枚制限が特定タイプのハードカウンター」という批判はあるが（Scribbly）、議論の中心は「どれを飲むか」で、Doormaker のように撤去はされていない（§2-A）。
9. **一撃型と手数型を交互に有利/不利にする敵の混在** — Entomancer・Lagavulin Matriarch・Exoskeleton は一撃が有利、Vantom・Inklet・Thieving Hopper・Phantasmal Gardener は多段が有利。本作の「物理（手数）／竜炎（一撃）」の二軸と直接かみ合う（§2-E）。
10. **「手札に残ると痛い」札（Beckon / Wither）は、廃棄・捨て・低コスト処理で解けるようにする** — Soul Fysh と Aeonglass のどちらも、wiki の対策欄は除去手段の列挙が中心。
    なお「枚数を使うほど敵が脆くなる」逆向きの例（Bygone Effigy の Slow）には、今回読んだ範囲で目立った不満は見つからなかった（**苦情の有無は未確認**）。手数型の報酬設計の参考になりうる。

## 6. 今回確認できなかったこと（まとめ）

- サムネの敵4体の外見との一致（画像未参照）。特に 1-a / 1-b / 1-d は推定。
- Soul Fysh が「手札内容を見て行動を変える」という記述。
- Entangled / Scrutiny / Smoggy などのパワー・アフリクション本文の正確な文言（wiki の個別ページが取得できず、敵ページの抜粋のみ）。
- 公式パッチノート本文（Steam ニュース）の一次確認、v0.100.0 の敵側の具体的な変更点。
- 2026-05〜09 の Steam スコア推移。
- 「戦闘が遅い」を主題にした StS2 掲示板スレ。
- エナジー不足・回復不足への Mega Crit の直接発言。
- Living Fog・Globe Head・Owl Magistrate・Slimed Berserker などの日本語名。
- Reddit の生の声（今回は Steam 中心）。
