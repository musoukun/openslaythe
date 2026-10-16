# 装備・ステータススケーリングで「1人のキャラの戦い方」を変える仕組み（AD vs AP 概念）— カードゲーム／カード系ローグライク／ARPG からの調査ノート

調査日: 2026-10-16。検索で確認できた情報のみ Cited Findings に記載。訓練知識ベースで未検証のものは Gaps に「未検証」と明記して分けた。情報源の多くは 2013〜2022 年のレビュー／フォーラム記事であり、その後のパッチで変更されている可能性がある（各所に年代を注記）。

---

## Q1. 装備がデッキに介入するカードゲーム／カードローグライク（Card Hunter, Gordian Quest, Trials of Fire, Hand of Fate, Across the Obelisk, Monster Slayers ほか）

### Takeaway
装備とデッキの関係は大きく3型に分かれる: (a) **装備＝カード供給源**（Card Hunter、Trials of Fire: 装備するとその装備固有のカードがデッキに入り、外すと消える）、(b) **装備＝カード＋ソケット＋ステータス**（Gordian Quest: 付属カード、色付きソケット、STR/INT/DEX による装備制限）、(c) **装備＝数値補正のみ**（Monster Slayers: 攻撃力・防御・耐性を変える）。「同じキャラが装備でビルドを変える」体験を最も直接作れているのは (a) 型。

### Cited Findings
**Card Hunter（Blue Manchu, 2013）— 「アイテムがカードを持っている」型の代表**
- 各装備品が戦闘中に使えるアクションカードを持っており、装備品のカードの集合がそのままデッキになる。カードには出どころのアイテム名が表示され、アイテムにカーソルを合わせると付属カードがハイライトされる — [Quarter to Three: Card Hunter deck-building mechanics](https://www.quartertothree.com/fp/?p=25913)
- 装備スロットはレベルアップで解放される — [Game Informer](https://gameinformer.com/games/card_hunter/b/macintosh/archive/2013/06/26/tactical-rpg-fun-on-your-browser.aspx)
- **Power Token による装備コスト制**: Lv7 で最初の minor（青）トークン、Lv14 まで毎レベル1個で minor 計8個、Lv15 で1つが major（黄）トークンになり上位装備を解禁。上位トークンは下位の代用が可能。トークンスロットは約12、同時使用は最大8 — [Quarter to Three](https://www.quartertothree.com/fp/?p=25913)
- **クラス別スロット**: Mage は robe / arcane / staff、Fighter は武器スロット3つ、Cleric は divine スロットを持つ。加えて **種族スロット** があり、Elf は機動・速度系、Human は味方を動かす／ドローさせる指揮系、Dwarf はブロック追加・押し出し耐性などの頑強系カードが入る — [Quarter to Three](https://www.quartertothree.com/fp/?p=25913)
- 敵に合わせて装備を選ぶのがデッキ構築そのもの。例: 魔法使い相手には Shimmering Armor を持つ防具、スケルトン相手には打撃武器 — [Quarter to Three](https://www.quartertothree.com/fp/?p=25913)
- カード種別は Armor / Attack / Block / Boost / Drawback / Assist / Movement / Utility。レアリティは Common〜Epic で、カード品質はレアリティ連動 — [Giant Bomb](https://giantbomb.com/wiki/Games/Card_Hunter)

**Gordian Quest（Mixed Realms）— 「付属カード＋ソケット＋ステ制限」型**
- 開発者の説明として、装備は「装備中だけデッキに追加されるカード」を付けている場合があり、スキルを修正・追加することもある。クラフトでビルドに合わせて装備を改造できる — [Steam コミュニティ議論](https://steamcommunity.com/app/981430/discussions/0/5350815203281065209)（検索スニペット経由。2020–21 年の Early Access 期）
- 装備部位: 武器、防具、帽子、マント、手袋、靴、指輪、ベルト、アミュレット、augment、ポーション。MMO 風レアリティ — [GamingTrend レビュー](https://gamingtrend.com/reviews/gordian-quest-review-deckbuilding-dungeons-and-dice/)
- 装備には色付きソケットが固定数あり、ジェムで主ステータスや毒・fury・focus などの効果を追加。一部の装備には「特定の攻撃／防御カード用スロット」（既に埋まっているか空き）がある — [GamingTrend](https://gamingtrend.com/reviews/gordian-quest-review-deckbuilding-dungeons-and-dice/)
- **Strength / Intelligence / Dexterity の3ステが装備可能な武器・防具・アクセサリを決める**（ステ＝装備制限）。ステはスキルグリッドのポイントで上げる。グリッドのノードは fury、HP、新スキルカード、ステ+1 など。各クラス3専門グリッド — [GamingTrend](https://gamingtrend.com/reviews/gordian-quest-review-deckbuilding-dungeons-and-dice/)
- Steam ガイドの見解: レジェンダリ効果を除けば、装備効果で最重要なのはカードドローと AP — [Steam コミュニティ](https://steamcommunity.com/app/981430/discussions/0/2793873197761790021)（検索スニペット経由）

**Trials of Fire（Whatboy Games）— 「装備がカードを足す＋重複時はステに変換」型**
- 各キャラはクラス固有のコアデッキ9枚とカードプールを持ち、装備がそのプールに追加する — [Edge 誌 (PressReader)](https://www.pressreader.com/australia/edge/20210422/284197993554292)
- 装備するとカードがデッキに入る。例: Legendary の Glass Plating は3枚のカードを追加 — [CardGamer](https://cardgamer.com/games/digital-card-games/trials-of-fire-the-genre-bending-roguelike-deckbuilder/)
- **重複ルール**: 既に別の装備から得ているカードを新装備が付与する場合、カードを重ねて追加する代わりにステータスが上がる。Epic/Legendary はHP・アーマーなどのステ上昇＋強力カード — [CardGamer](https://cardgamer.com/games/digital-card-games/trials-of-fire-the-genre-bending-roguelike-deckbuilder/)
- アイテムは特定キャラ固定ではないが、スロット構成はクラス依存（戦士と魔法使いで装備選択肢が違う）— [CardGamer](https://cardgamer.com/games/digital-card-games/trials-of-fire-the-genre-bending-roguelike-deckbuilder/)
- Steam ページ記載: Skill Card 345、Item 220、Legendary Item 42。戦闘外で武器・アイテム・装備を入れ替え／強化できる — [Steam store](https://store.steampowered.com/app/1038370)
- 手札のカードを右クリックで Willpower（汎用リソース）に変換でき、他キャラのカードのコストや移動に使える — [CardGamer](https://cardgamer.com/games/digital-card-games/trials-of-fire-the-genre-bending-roguelike-deckbuilder/)

**Hand of Fate 2（Defiant Development）— 「装備＝アクション戦闘の能力」型**
- 武器は力押しのものから魔法的なものまで。Artefact は戦闘中に発動する特殊能力を与え、魔法武器は固有の力を持つ。防具は純防御からアビリティ／攻撃を強化するものまで — [Hand of Fate wiki (BreezeWiki ミラー)](https://breezewiki.discard.no/handoffate/wiki/Cards)
- 武器スタイルは3つ（剣盾、軽武器二刀、両手重武器）。全武器に固有の武器アビリティ — [GameRevolution](https://www.gamerevolution.com/originals/12887-hand-of-fate-2-is-just-as-impressively-designed-as-the-original)（検索スニペット経由）
- 新リソース「Fame」が上位装備の装備条件 — [Game-Wisdom](https://game-wisdom.com/analysis/hand-of-fate-2)（検索スニペット経由）

**Monster Slayers（Nerdook）— 「装備＝数値＋一部カード」型**
- 武器・防具はダメージ出力と耐性だけでなく、デッキ内のカードも変える — [PC Invasion](https://www.pcinvasion.com/?p=145030)（検索スニペット経由）
- 装備はダメージ出力と防御に反映。一部クラスは初期装備でステ強化。商人から装備とカードを買える — [Gaming Nexus](https://gamingnexus.com/Article/5407/Monster-Slayers)
- 1ターン3ドロー・3AP・マナ生成の構造 — [Gaming Nexus](https://gamingnexus.com/Article/5407/Monster-Slayers)
- ダンジョン中は装備変更できないというユーザー報告あり（非公式）— [Quarter to Three フォーラム](https://forum.quartertothree.com/t/monster-slayers-a-deck-building-roguelike/129051)

**Across the Obelisk（Dreamsite Games）**
- アイテムに Weapon / Jewelry / Accessory などの区分があり、高 Madness 難度では装備が「Cursed（上位版）」で落ちることがある。氷エリアの Rat King が武器スロットのユニーク品を、そのキャラの Jewelry と最大HP12を代償に強化する（いずれもユーザー投稿）— [Steam 議論](https://steamcommunity.com/app/1385380/discussions/0/6063574907526224250), [Steam 議論](https://steamcommunity.com/app/1385380/discussions/0/3108026928579681896)
- ペットも装備枠扱いで状態異常付与などを行う（例: DLC のペット Inky が Wet/Poison/Dark を付与、Rifty が敵バフ解除）— [Nuuvem DLC ページ](https://www.nuuvem.com/pe-en/item/across-the-obelisk-the-sahti-collection), [Nintendo](https://nintendo.com/games/detail/across-the-obelisk-amelia-the-queen-70050000046772-switch)
- 「500以上のカードとアイテムを選択・クラフト・強化」 — [Nuuvem](https://www.nuuvem.com/cn-en/item/across-the-obelisk-sigrun-the-valkyrie)

**Slay the Spire mod**
- 「The Blackbeard」（キャラ mod）: Weapon が中心メカニクス。各 Weapon は Attack と Durability を持ち、最大10本装備、耐久0で破壊。Defect のオーブシステムを流用してキューイング — [smods カタログ](https://catalogue.smods.ru/?p=149535)
- StS の mod 利用には通常 ModTheSpire / BaseMod（一部 StSLib）が必要 — [Steam 議論](https://steamcommunity.com/app/646570/discussions/0/2521353993637700608)

### Inferences
- **「装備＝カード供給源」型（Card Hunter / Trials of Fire）は StS 型デッキビルダーへの接ぎ木が最も自然**。装備を拾う＝デッキに数枚のカードが入る、外す＝抜ける、なのでカード報酬と同じパイプラインで処理でき、「物理剣を拾ったら斬撃カードが増える」「杖を拾ったら魔法カードが増える」とビルドが目に見えて変わる。
- Trials of Fire の「重複はステに変換」ルールは、同じ装備を2つ持ったときのデッキ汚染・ゴミ化を防ぐ安い解決策として流用価値が高い。
- Card Hunter の Power Token は「強い装備を全部盛り」を防ぐ予算制。StS 型ではエネルギーやスロット数で代替できる。
- Gordian Quest の「ステ＝装備制限」は RPG らしいが、StS 型（1キャラ・1ラン完結）では制限より「スケーリング」として使う方が分かりやすい（推測）。
- AtO の「Jewelry を捧げて武器強化」のような**装備間トレードオフイベント**は、既に実装済みの「?」イベントと相性が良い。

### Gaps
- Card Hunter の1アイテムあたりのカード枚数・総デッキ枚数は今回の情報源で確認できず（訓練知識では「1アイテム概ね2〜3枚、キャラごとに約36枚」だが**未検証**）。公式 wiki（cardhuntria 系）は今回取得していない。
- Across the Obelisk の正確な装備スロット構成（Weapon / Armor / Jewelry / Accessory / Pet の5枠）、およびアイテム自体が「カードとして手に入り、使うと装備される」仕組み、「+X 火属性ダメージ」系の属性ボーナスは訓練知識ベースで**未検証**（wiki.gg は 401、Fandom は 402 で取得不可）。
- Roguebook、Floppy Knights、Dream Quest、Ratropolis、Dungeon Drafters、Fights in Tight Spaces、Nowhere Prophet、Downfall、Packmaster は時間制約で未調査。
- Hand of Fate 1/2 の装備がデッキ（イベントカード）にどう関わるか、および Blessing の詳細は確認できず。
- StS1 に装備スロット系 mod が実在するかは確認できず（The Blackbeard は「武器をオーブ的に扱う」キャラ mod）。

---

## Q2. 二系統（物理 vs 魔法）スケーリングの実装例 — StS / Hearthstone / Gordian Quest ほか

### Takeaway
最もシンプルで実績のある分割は **「カード種別タグ × 加算ステータス」**: StS は Strength（Attack にのみ加算）/ Dexterity（Block）/ Focus（Orb）、Hearthstone は Spell Damage（スペルのダメージにのみ加算、ミニオン・武器攻撃・ヒーローパワーは対象外）。「AD vs AP」はタグで対象を絞った加算値2本で再現できる。

### Cited Findings
- **StS の Strength**: 1ポイントにつき Attack のダメージ+1。多段攻撃は1ヒットごとに加算。負の Strength で減少するが1ヒットあたり0未満にはならない — [Slay the Spire Wiki (wiki.gg) Strength](https://slaythespire.wiki.gg/wiki/Strength)
- **演算順**: Strength は乗算効果より「前」に適用。Strength 2 で Vulnerable の敵に Strike → (6+2)×1.5=12（6×1.5+2=11 ではない）。乗算側は Weak、Wrath、Divinity、Phantasmal Killer、Pen Nib、Slow など — [StS Wiki Strength](https://slaythespire.wiki.gg/wiki/Strength)
- Vigor、Accuracy、Strike Dummy、Wrist Blade は Strength と同様の加算で積み重なる — [StS Wiki Strength](https://slaythespire.wiki.gg/wiki/Strength)
- **対象の限定**: Strength が効くのは Attack カードのみ。Combust、Corpse Explosion、Electrodynamics など非 Attack ダメージ、レリック・オーブのダメージ、HP 損失には効かない — [StS Wiki Strength](https://slaythespire.wiki.gg/wiki/Strength)
- **Hearthstone の Spell Damage**: 手札の対象スペルのカードテキストの数値を動的に書き換える（+2 で Fireball が「8ダメージ」表示）。回復には効かない。ヒーローパワー、断末魔、雄叫び、疲労、戦闘ダメージは対象外。複数ソースは加算で積み重なり、乗算効果（Prophet Velen）より前に適用。ランダム分割系（Arcane Missiles）はミサイル数が増える。発生源は紫のキラキラで識別 — [Hearthstone Wiki Spell Damage](https://hearthstone.wiki.gg/wiki/Spell_Damage)
- **Gordian Quest**: STR / INT / DEX の3ステが装備可能な武器・防具・アクセサリを決める — [GamingTrend](https://gamingtrend.com/reviews/gordian-quest-review-deckbuilding-dungeons-and-dice/)
- **Monster Slayers**: 装備が「ダメージ耐性とダメージ出力」を変える（=属性/耐性を装備側に持たせる）— [PC Invasion](https://www.pcinvasion.com/?p=145030)（検索スニペット経由）
- **Card Hunter**: 打撃武器がスケルトンに有効、Shimmering Armor が呪文に有効など、ダメージタイプ×防具相性でビルド選択を促す — [Quarter to Three](https://www.quartertothree.com/fp/?p=25913)

### Inferences
- 実装最小形: カードに `tags: ["attack","physical"]` / `["spell","fire"]` を持たせ、ダメージ計算を「基礎値 + Σ(タグに合う加算ステ) → × Σ乗算」の固定パイプラインにする。StS と Hearthstone の両方が「加算は乗算より前」で統一されており、この順序を最初に決めておけば装備追加で計算が壊れにくい。
- 「AD vs AP」のゲーム体験的な肝は、**同じ加算値がどのカードに乗るかを装備が決める**こと。例えば「Might（物理加算）」と「Arcana（魔法加算）」の2ステを用意し、剣装備は Might+2、杖装備は Arcana+2 とするだけで、プレイヤーは報酬画面で「今は物理カードを取るべきか魔法カードか」を考え始める。
- Hearthstone の「回復には効かない」「ランダム分割は回数が増える」のような例外ルールは、最初から決めておかないと後で調整コストが高い。対象外リスト（HP 損失、DoT tick、反射ダメージなど）を明文化しておくのが良い。
- 毒/DoT や Thorns（反射）は StS でも Strength の対象外であり、独立したスケーリング軸（毒の付与量、反射量）として扱う方が分かりやすい（StS の Strength 対象外リストからの推測）。

### Gaps
- Griftlands（交渉/戦闘の2デッキ）、Darkest Dungeon の Trinket、Fear & Hunger については今回調査できず。
- StS の Dexterity（Block への加算、Frail は乗算 0.75）と Focus（オーブへの加算）は訓練知識では既知だが今回の取得ページに記載がなく**未検証**。

---

## Q3. ARPG の教訓 — ビルドを定義するユニーク装備の楽しさと問題点（Diablo 3/4、Path of Exile、Grim Dawn、Last Epoch、Hades II）

### Takeaway
「スキルの挙動そのものを変える装備」はビルドの起点として強力だが、(1) 特定装備がないとビルドが成立しない**装備依存**、(2) フルセットボーナスが他の選択肢を消す**メタの固定化**、(3) 効果がゲーム内で説明されない**読解負荷**、という問題が繰り返し報告されている。Diablo 4 開発陣はセットを防具スロットから切り離し、2/2/2 の混在を許す方向で対処したと報じられている。

### Cited Findings
- **Diablo 4 Aspect**: 条件付きで発動する装備ボーナスで、種類によって付けられる装備部位が決まる — [PC Gamer](https://pcgamer.com/diablo-4-aspect-locations)。Codex of Power はダンジョン攻略で Aspect を解放し、プレイヤーにビルド選択の制御を与える仕組み（2022 年配信の情報）— [MP1st](https://mp1st.com/?p=206079)
- **Diablo 3 のセット問題（D4 開発陣の Discord Q&A を報じた記事）**: D3 ではセットが防具スロットに紐づいており、6部位ボーナスを揃えないと大きなダメージを失うため、ビルドが強制的に感じられた。D4 ではセットを Talisman にソケットする Charm に移し、防具スロットと競合させず、2/2/2 のような混在も可能にする。記事自身もエンドゲームで機能するかは不明と注記 — [Icy Veins](https://www.icy-veins.com/d4/news/diablo-4-devs-explain-how-sets-will-avoid-diablo-3s-biggest-mistake/)（検索スニペット経由。本文は 403 で取得不可、日付未確認）
- プレイヤー批判: D3 後期のセット6部位ボーナスが単一スキルを強化するだけになり、各クラスのプレイスタイルを1つに狭めている（プレイヤー意見）— [Blizzard フォーラム](https://us.forums.blizzard.com/en/d3/t/genuinely-dont-think-one-set-buffing-one-skill-is-the-best-idea/11940)
- **Grim Dawn の装備依存（2019 コミュニティガイド）**: エンドゲームビルドの多くは特殊な変換（conversion）に依存しており低レベルへ落とせない、「a large chunk of endgame builds is pretty much impossible to downshift」。武器依存の DoT ビルドは代替品が存在しない。スキル挙動を変える装備は稀でガイドでは3例のみ、コメント者はもっと欲しいと要望。Spellscourge の Devastation のように効果がゲーム内で説明されず外部情報なしでは分からない、という指摘 — [Crate フォーラム](https://forums.crateentertainment.com/t/gear-dependency-of-builds-in-grim-dawn/89839)
- Grim Dawn では武器・コンポーネント・アミュレットに「物理→属性」のグローバル変換があり、スキル側の変換と組み合わせる。変換後のスキルが非変換版の約75%のダメージになることがある、とのガイド記述 — [Crate フォーラム (検索スニペット)](https://forums.crateentertainment.com/t/gear-dependency-of-builds-in-grim-dawn/89839)
- Grim Dawn の変換とダメージボーナスの適用順序についてはプレイヤー間でも見解が割れている（変換→ボーナス説、スキル行のボーナスは変換前説）— [Steam 議論](https://steamcommunity.com/app/219990/discussions/0/2425614361139871459)
- Grim Dawn 公式: 装備から得るスキル（Item Skills）は Active と Auto-Cast の2種類 — [Grim Dawn 公式ガイド](https://www.grimdawn.com/guide/character/item-skills/)
- **Path of Exile**: 2021 年、Chris Wilson が Reddit でサポートジェムのマナコスト増加について説明（Expedition のバランス変更）— [Reddit (rtrace ミラー)](https://reddit.rtrace.io/r/pathofexile/comments/op73wg/some_thoughts_from_chris)。PoE2 のサポートジェム設計について「数値より効果の精神（spirit）が大事」というプレイヤー意見 — [PoE 公式フォーラム](https://www.pathofexile.com/forum/view-thread/3637820)

### Inferences
- **楽しさの源泉**: 「拾った瞬間に戦い方が変わる」こと。Diablo の Aspect / Grim Dawn の変換 / Card Hunter の装備カードはどれも「数値+5%」ではなく「挙動が変わる」装備でビルドの起点になっている。デッキビルダーでも「装備1つでカードのタグが変わる（例: 全 Attack が Fire 扱いになる）」程度の大胆さがあると、AD→AP の転換を体験として演出できる。
- **装備依存の回避**: ローグライクは1ラン完結なので「その装備が出ないとビルド不成立」はむしろ変動比率の面白さになり得るが、ビルドの「核」を装備1つに集中させると出なかったランが単調になる。Diablo 4 の 2/2/2 混在のように、**部分的なシナジーでも報酬がある**設計（2個で小効果、3個で大効果、混ぜてもOK）が安全。
- **読解負荷**: Grim Dawn の「効果がゲーム内で説明されない」問題は、カードゲームでは致命的。装備がカードを変える場合、変わった後の数値・タグをカード上に直接表示すること（Q4）が必須。
- **計算順の曖昧さ**: Grim Dawn の変換順序がプレイヤー間で議論になっているのは、加算／変換／乗算の順序が見えないため。小規模プロジェクトでは「変換」は導入しない、または「タグの付け替え」に限定するのが安全。

### Gaps
- Last Epoch（スキルごとのスキルツリー）、Hades II（Boon/Arcana/Aspect の武器変化）は時間制約で未調査。
- Diablo 公式の itemization GDC 講演、PoE のサポートジェム設計の一次ソース（Chris Wilson の講演・インタビュー）は見つからず。
- Icy Veins 記事の日付・対象拡張（Talisman/Charm 系）は本文取得不可のため未確認。

---

## Q4. UX / 可読性 — スケーリングをカード上でどう見せるか

### Takeaway
業界標準は「手札のカードテキストの数値を、補正後の値に動的に書き換えて表示する」こと。Hearthstone の Spell Damage は公式にこの挙動で、発生源も視覚的にマークされる。

### Cited Findings
- Hearthstone: Spell Damage は「手札の対象スペルのカードテキストに印字された数値を動的に修正する」。値は常時更新され、発生源が場に出た瞬間に適用。Spell Damage 発生源には紫のキラキラ表示 — [Hearthstone Wiki](https://hearthstone.wiki.gg/wiki/Spell_Damage)
- Card Hunter: 各カードに出どころのアイテム名が表示され、アイテムを選択すると付属カードがハイライトされる（装備→カードの因果を可視化）— [Quarter to Three](https://www.quartertothree.com/fp/?p=25913)
- StS: Warped Tongs の強化カードで Strength/Dexterity 補正値の表示が誤っていたバグ修正がパッチノートにある（＝StS も補正後数値をカードに表示している）— [StS Wiki Strength](https://slaythespire.wiki.gg/wiki/Strength)
- Grim Dawn: スキル変化系装備の効果がゲーム内で十分説明されず、外部情報が必要という不満 — [Crate フォーラム](https://forums.crateentertainment.com/t/gear-dependency-of-builds-in-grim-dawn/89839)

### Inferences
- 推奨 UI: (1) カード数値は常に補正後を表示し、基礎値より高ければ緑・低ければ赤（StS 流。色の仕様は今回ソース未確認なので Gaps 参照）。(2) カードに「出どころ装備」アイコンを小さく表示（Card Hunter 流）。(3) ホバーで「6 + 物理2 = 8」の内訳ツールチップ。(4) 装備にホバーすると、影響を受ける手札のカードを光らせる。
- タグ変換系装備（例: 全 Attack を Fire に）を入れる場合、カードのタグ表示（枠色・アイコン）も変えないとプレイヤーは気付けない。

### Gaps
- StS で補正後ダメージが緑/赤で表示される仕様は一般に知られているが、今回の取得ページには記載がなく**未検証**。
- Monster Train、Across the Obelisk などのツールチップ設計の具体例は未調査。

---

## 装備レイヤー設計の選択肢

（Key question: 小規模 Godot プロジェクトで最も安く実装できるのはどれか。既存の StS 風デッキビルダー＋レリック＋「?」イベントがある前提）

### Takeaway
最安で効果が大きいのは **A「装備＝スロット制限付きレリック」** と **B「装備＝カード供給源（1〜3枚追加）」** の組み合わせ。C「二系統ステ（Might/Arcana）」を足せば AD/AP の分岐が数値的にも成立する。D「タグ変換」とE「ソケット」は面白いが計算順・UI のコストが高いので後回し推奨。

### Cited Findings
- 装備＝カード供給源は Card Hunter（装備のカード集合がデッキ）と Trials of Fire（装備でカード追加、重複はステ変換）で実証済み — [Quarter to Three](https://www.quartertothree.com/fp/?p=25913), [CardGamer](https://cardgamer.com/games/digital-card-games/trials-of-fire-the-genre-bending-roguelike-deckbuilder/)
- 加算ステ×タグ限定は StS の Strength（Attack のみ、乗算より前）と Hearthstone の Spell Damage（スペルのみ、乗算より前、表示は動的書き換え）で実証済み — [StS Wiki](https://slaythespire.wiki.gg/wiki/Strength), [Hearthstone Wiki](https://hearthstone.wiki.gg/wiki/Spell_Damage)
- ソケット＋ステ制限は Gordian Quest が採用 — [GamingTrend](https://gamingtrend.com/reviews/gordian-quest-review-deckbuilding-dungeons-and-dice/)
- 変換（物理→属性）は Grim Dawn が採用しているが、適用順の混乱と装備依存の問題が報告されている — [Steam 議論](https://steamcommunity.com/app/219990/discussions/0/2425614361139871459), [Crate フォーラム](https://forums.crateentertainment.com/t/gear-dependency-of-builds-in-grim-dawn/89839)
- セットを部位から切り離し混在可にする方向（D4）— [Icy Veins (スニペット)](https://www.icy-veins.com/d4/news/diablo-4-devs-explain-how-sets-will-avoid-diablo-3s-biggest-mistake/)

### Inferences（比較表）

| 案 | 仕組み | ビルド分岐の強さ | 実装コスト（Godot 小規模） | 長所 | 短所 |
|---|---|---|---|---|---|
| **A. 装備＝スロット制限付きレリック** | 既存レリック（パッシブ効果）に `slot: weapon/armor/accessory` を付けるだけ。同スロットは1つまで、拾ったら入替選択 | 中 | **最小**（既存レリック基盤＋入替 UI） | 「何を捨てるか」の選択が生まれる。既存コード流用 | 単体ではカードが変わらないので「戦い方が変わる」実感は弱め |
| **B. 装備＝カード供給源** | 装備に1〜3枚のカードを紐付け、装備中はデッキに入り外すと抜ける（Card Hunter / Trials of Fire 型）。重複はステ+1に変換 | **強**（デッキの中身が物理/魔法に寄る） | 小〜中（デッキ再構築処理、カードに `source_gear` 参照、出どころ表示） | 拾った瞬間に手札が変わるので体験が直接的。カード報酬と同じパイプライン | 装備入替でデッキが大きく揺れる。強化済みカードの扱い（外したら消える?）を決める必要 |
| **C. 二系統加算ステ（Might / Arcana ＋ Guard / Venom）** | カードにタグ（physical / spell / block / poison）、計算は「基礎 + 該当ステ → ×乗算」で固定。装備がステを付与 | 強（数値で AD/AP が分かれる） | 小（ダメージ計算1関数＋カード表示の動的数値） | StS/HS で実証済みの分かりやすさ。A/B と自然に併用可 | 対象外ルール（DoT tick、反射、HP損失）を先に決める必要。数値表示 UI 必須 |
| **D. タグ変換装備** | 「全 Attack を Fire 扱いにする」「Block 獲得時に同量の Thorns」等、カードの分類・挙動を書き換える build-defining 装備 | **最強**（1個でビルドが反転） | 中〜大（タグの動的付け替え、表示更新、計算順の明文化） | 「拾った瞬間に戦い方が変わる」ARPG 的快感 | Grim Dawn 的な計算順の混乱・装備依存。レア枠に数個だけにすべき |
| **E. ソケット / ジェム** | 装備に色付きソケット、ジェムでステや毒付与を追加（Gordian Quest 型） | 中 | 大（2層のアイテム管理＋UI） | カスタマイズ欲・自己表現を満たす | 1ラン完結のローグライクでは情報量過多。読む量が増える |

- 推奨の段階導入（スモールステップ）: **Step1** = C の計算パイプライン（タグ＋加算ステ）とカード上の動的数値表示 → **Step2** = A（武器/防具/装飾の3スロットで、各装備はステ付与のみ）→ **Step3** = B（武器だけはカード1〜2枚を供給）→ **Step4** = D をレア装備数個で試す。各ステップ単体でプレイ可能。
- 4ビルドの例（全て C+A+B で表現可能）:
  - 物理クリティカル: 武器「双剣」= Might+1、斬撃カード2枚供給。装飾「研ぎ石」= Attack の多段ヒット+1。
  - 魔法バースト: 武器「杖」= Arcana+2、Fireball カード1枚供給。装飾「魔導書」= spell タグのカードを使うたびに次の spell +3（D 寄り）。
  - タンク/Thorns: 防具「棘鎧」= Guard+2、Block 獲得時に Thorns 付与（D）。
  - 毒/DoT: 武器「毒の短剣」= Venom+1（毒付与量に加算）、毒付与カード2枚供給。
- 自己表現・見せたくなる要素としては、装備の見た目をヒーローのスプライトに反映（武器差し替え）すると「自分のビルド」がスクショで伝わる（推測。見た目反映のコストは別途）。

### Gaps
- 各案の実装コストは本調査者の推測であり、既存コードベース（Godot プロジェクト）の構造を確認していない。
- Godot 向けの装備システム実装のベストプラクティス（Resource ベースの設計等）は本調査の範囲外で未調査。
- 「装備で戦い方を変えるデッキビルダー」の商業的成功事例（販売数・レビュー評価）は収集していない。
