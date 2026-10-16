# 現行コードベース調査: Petal Fallout (openslaythe) のシステム構成と「ビルド多様性」拡張ポイント

調査日: 2026-10-16 / 対象: `D:/develop/openslaythe` (HEAD = `671fab6`) / 読み取りのみ・変更なし
出典表記は `パス:行番号`。すべてローカルファイル。

---

## 1. プロジェクト構造・データ定義方式・コンテンツ数

### Takeaway
Godot 4.6 / GDScript のプロジェクトで、土台は DesirePathGames/Slay-The-Robot (MIT)。ゲームデータは JSON でも .tres でもなく、**autoload の `GlobalProdDataGenerator.gd` (3529行) の中で GDScript から `XxxData.new()` してフィールドを代入し `Global.register_rod()` する方式**が本番で使われている。登録済みのコンテンツは、カード34枚・アーティファクト(レリック)25個・消耗品(ポーション)4個・敵9体・キャラ1人と少ない。

### Cited Findings
- エンジンは Godot 4.6、プロジェクト名は "Petal Fallout"、メインシーンは `res://scenes/Root.tscn` — `project.godot:15-19`, `README.md:5`
- 土台は DesirePathGames/Slay-The-Robot (MIT)。git 履歴では guladam/deck_builder_tutorial から差し替えている — `docs/PLAN.md:3`, `git log` (`6d4cb0c Switch base to DesirePathGames/Slay-The-Robot (MIT)`)
- autoload は Signals, Scenes, Scripts, FileLoader, Random, Global, GlobalTestDataGenerator, GlobalProdDataGenerator, ActionHandler, ActionGenerator, DebugLogger, HandManager, SoundManager, StatsHandler, Vfx, DevAutoPilot, PerfOverlay の17個 — `project.godot:29-45`
- 主なフォルダ: `autoload/` (シングルトン)、`data/` (データクラス: `prototype/` `readonly/` `mutable/` `filters/`)、`scripts/` (`actions/` `action_interceptors/` `artifacts/` `card_decorators/` `status_effects/` `validators/` `run_modifiers/` `ui/` `content/`)、`scenes/`、`external/` (画像・音・mod)、`docs/`、`tools/` (Codex 用アートと i18n のパイプライン) — `git ls-files` の結果
- データのスキーマは `Global.SCHEMA` 表で管理している。readonly 系 (RestAction / StatusEffect / Consumable / CardDecorator / Act / Event / EventPool / Dialogue / ActionInterceptor / Color / Keyword / Character / Animation / RunModifier / RunStartOption / CardPack / ArtifactPack / ConsumablePack / CustomUI / CustomSignal) と prototype 系 (Enemy / Card / Artifact / Player) に分かれる — `autoload/Global.gd:18-46`
- 起動時は `GlobalProdDataGenerator.generate_production_data()` だけを呼ぶ。`GlobalTestDataGenerator.generate_test_data()` はコメントアウトされている。そのあと `FileLoader.load_read_only_data()` で外部(mod)データを読み、`ArtOverrides.apply()` で画像を割り当てる — `autoload/Global.gd:175-189`
- 生成の順番: rest_actions → consumables → status_effects → action_interceptors → enemies → events → dialogue → acts → colors → keywords → VFX → characters → player_data → run_modifiers → run_start_options → custom_ui/signals → artifacts → card_decorators → cards → 各種 pack — `autoload/GlobalProdDataGenerator.gd:7-39`
- 本番の定義数 (`= XxxData.new(` の出現数): CardData 34、ArtifactData 25、ConsumableData 4、EnemyData 9、CharacterData 1、PlayerData 4、EventData 9、StatusEffectData 26、ActionInterceptorData 20、CardDecoratorData 5、RestActionData 6、ActData 3、RunModifierData 12、CardPackData 7、ArtifactPackData 6 — `autoload/GlobalProdDataGenerator.gd` に grep をかけて数えた
  - カード34枚の内訳: basic attack / basic block (キャラ色ごとにループで生成するが、キャラが1人なので2枚) — `:2378-2423`、白の `card_energy_next_turn` 1枚 — `:2426-2448`、緑31枚 — `:2451-3416`
  - 敵: `enemy_1`〜`enemy_4`、ミニボス2体、ボス1体、ミニオン2体 — `:2013-2229`
  - 消耗品: heal / block / damaging / multi_damaging の4種で、すべて白・COMMON — `:354-424`
  - イベント: 戦闘用 EventData 8個とダイアログ1個 (`event_pick_something`) が `:1161-1231` にある。さらに「?」マス用のオリジナルイベント10個が `scripts/content/EventContent.gd:12-24` で作られ、`event_pool_act_1_dialogue` に入る — `:1261-1267`
- 例外的にイベントだけはコード分割されており、`scripts/content/EventContent.gd` (266行) に static 関数で定義されている — `scripts/content/EventContent.gd:1-24`
- JSON の外部データは mod の仕組み (`external/mods/example_mod/cards/card_modded_card.json`, `characters/character_red.json`) にしかない。本体のデータは GDScript に書かれている — `git ls-files`, `autoload/Global.gd:186-188`

### Inferences
- 新しいデータ種 (例: EquipmentData) を足すときは、`Global.SCHEMA` に1行加え、`GlobalProdDataGenerator` に `add_equipment()` を加える、という既存の型にそのまま乗れる。ただし生成ファイルはすでに3529行あるので、イベントと同じように `scripts/content/XxxContent.gd` へ切り出すのが、既存の前例 (EventContent) にも沿っていて自然。
- コンテンツが少ない (ドラフト対象の緑カード29枚、実質的なレリックは十数個) ため、ビルドの幅を出すにはシステムより先にコンテンツ量がボトルネックになる。

### Gaps
- `FileLoader.load_read_only_data()` が外部 JSON で本体データを上書きしているかは追っていない (`external/data/mod_info.json` の中身は未確認)。
- 敵それぞれの HP・インテントの数値は読んでいない。

---

## 2. カードモデル (フィールド・効果の実行・数値の補正・ダメージ種別)

### Takeaway
カードは `CardData` (PrototypeData) で表し、数値は `card_values` 辞書に、効果は `card_play_actions` (Action スクリプトのパス → パラメータ辞書の配列) にデータ駆動で持たせている。実行は ActionHandler のアクションキュー経由で、**筋力のようなバフは「Action Interceptor」が `damage` などの値を shadow 値として書き換える**仕組みで実装されている。ダメージ種別 (物理/魔法) の概念は存在しない。ダメージを強化するのは `status_effect_damage_increase` (筋力相当) だけで、ブロックを強化するもの (敏捷相当) はない。

### Cited Findings
- 主なフィールド: `card_energy_cost` と一時上書き用の3種 (`_until_played` / `_until_turn` / `_until_combat`)、X コスト — `data/prototype/CardData.gd:15-24`。`card_type` は ATTACK / SKILL / POWER / STATUS / CURSE — `:39-41`。`card_rarity` は BASIC / COMMON / UNCOMMON / RARE / GENERATED — `:44-46`
- 数値は `card_values: Dictionary` に入れ、説明文中の `[damage]` などが置換される — `:88-93`
- 効果フックは play / discard / end_of_turn / exhaust / draw / retain / right_click / initial_combat / add_to_deck / remove_from_deck / transform_in_deck の11種 — `:102-117`。プレイ条件は `card_play_validators` — `:120`
- **`card_tags: Array[String]`** (任意のタグ。ValidatorCardTag で絞り込める) が定義されている — `:142-144`。ただし本番データでは1枚も使っていない (`GlobalProdDataGenerator.gd` 内に `card_tags` の出現0件)
- アップグレード: 初回だけ `card_first_upgrade_property_changes` と `card_first_upgrade_value_changes` を適用し、毎回 `card_upgrade_value_improvements` を加算する。`card_upgrade_amount_max` の既定は1 — `:148-164`, `:339-354`
- **カードデコレーター (エンチャント) のスロット**: `card_decorators` 辞書。`CARD_MAX_DECORATOR_SLOTS = 1`。デコレーターを付けると値の加算、プロパティの変更、アクションの前後挿入、キーワードの追加が起きる — `:131-137`, `:389-428`
- 値の解決順は Action の values → CardPlayRequest.card_values → CardData.card_values → **`PlayerData.player_values`** → 既定値 — `scripts/actions/BaseAction.gd:167-194`
- `player_values` は「action value 階層の最後」に置かれる拡張用の辞書として PlayerData に用意されている — `data/prototype/PlayerData.gd:23-26`
- Interceptor の仕組み: `BaseAction._intercept_action()` が対象ごとに `ActionInterceptorProcessor` を作り、親 (行動側) と対象 (被弾側) に登録された interceptor を priority 順に適用して shadow 値を更新する — `scripts/actions/BaseAction.gd:228-248`, `scripts/action_interceptors/ActionInterceptorProcessor.gd:25-46`, `:59-137`
- 筋力相当の `InterceptorDamageIncrease` は、`status_effect_damage_increase` のチャージ分だけ `damage` を加算する — `scripts/action_interceptors/InterceptorDamageIncrease.gd:6-18`。Weaken は ×0.75 — `scripts/action_interceptors/InterceptorWeaken.gd:22-33`
- Interceptor の定義は20種あり、`ACTION_ATTACK` を対象にするのは damage_increase(10000) / weaken(9500) / vulnerable(9000) / overshield / pointy / damage_from_overshield / damage_from_block / negate_damage / cap_damage。**`ACTION_BLOCK` を対象にする interceptor はない** — `autoload/GlobalProdDataGenerator.gd:1367-1535`
- カード説明の数値プレビューは、既定では `["damage", ACTION_ATTACK]` と `["block", ACTION_BLOCK]` を擬似的に intercept して計算し、元の値より大きければ緑、小さければ赤で表示する。カードごとに `card_description_preview_overrides` で別のキーも登録できる — `scripts/ui/card/Card.gd:182-245`, `data/prototype/CardData.gd:96-99`
- 攻撃処理は `target.damage(damage, bypass_block)` だけで、パラメータは `damage` と `bypass_block` の2つ。ダメージ種別の引数はない — `scripts/actions/combatant_actions/ActionAttack.gd:21-26`
- リポジトリ全体で `damage_type` / `magic` / `physical` を grep したが、該当する概念は見つからなかった (ヒットは bypass_block 関連と UI だけ)
- Action には `action_tags: Array[String]` があり、interceptor が同じ種類のアクションを区別するのに使える — `scripts/actions/BaseAction.gd:26-28`, `:55`
- 既存のアーキタイプ: 緑カードはコード上で `#region Health and Self Damage` (`:2454-2989`)、`#region Research Archetype` (`:2990-3155`)、`#region Critical Archetype` (`:3156-3416`) の3つに分かれている — `autoload/GlobalProdDataGenerator.gd`
- Critical アーキタイプの仕組み: `status_effect_critical` が毎ターン `status_effect_overheat` を付与し、overheat が上限10を超えると (overflow) 敵味方全員に10ダメージ — `autoload/GlobalProdDataGenerator.gd:771-829`

### Inferences
- 「物理/魔法」のような軸は、(a) `action_tags` に `tag_physical` / `tag_magic` を付け、(b) 新しい interceptor (例: InterceptorPowerScaling) が tag を見て `damage` を加算する、という形にすれば **ActionAttack 本体を変えずに**実装できる。説明文のプレビューも既存の仕組みでそのまま緑色になる。
- 別のやり方として、`player_values` に `stat_physical` などを入れ、interceptor の中で `Global.player_data.player_values` を読む方法もある。値はこの辞書に保存され、`ActionUpdatePlayerValue` で更新できる (`scripts/actions/combatant_actions/player_actions/ActionUpdatePlayerValue.gd:4-17`)。
- 「ブロックが伸びる」防御ビルドを作るなら、ACTION_BLOCK 用の interceptor (敏捷相当) が丸ごと足りない。

### Gaps
- `ActionAttackGenerator` が `number_of_attacks` をどう展開し、どの値を子の ActionAttack に引き継ぐか (action_tags が伝わるか) は未確認。tag 方式を採るなら要確認。
- `ActionHandler` のキュー処理の詳細 (同期/非同期・割り込み) は読んでいない。

---

## 3. レリック (Artifact) モデルとフック

### Takeaway
レリックは `ArtifactData` で表し、データだけで書けるフックが8種ある (add / remove / right_click / first_turn / end_of_combat / turn_start / turn_end / max_counter)。それ以外のタイミング (カードを使ったとき、撃破時など) は、`artifact_script_path` で `BaseArtifact` を継承したスクリプトを指定し、`Signals` (74個) を購読して作る。常時かかる数値補正は `artifact_interceptor_ids` で interceptor をプレイヤーに登録して行う。**装備スロットの概念はない** (スロットがあるのは消耗品3枠とカードデコレーター1枠だけ)。

### Cited Findings
- ArtifactData のフィールド: name / description / texture / `artifact_script_path` / `artifact_interceptor_ids` / counter (max, wraparound, ターン開始時と戦闘終了時のリセット) / `artifact_color_id` / rarity (BASIC, COMMON, UNCOMMON, RARE, BOSS, SHOP, EVENT) — `data/prototype/ArtifactData.gd:6-34`
- データだけで書けるアクションフック: `artifact_max_counter_actions` / `add` / `remove` / `right_click` (+validators) / `first_turn` / `end_of_combat` / `turn_start` / `turn_end` — `data/prototype/ArtifactData.gd:37-59`
- 実行は `perform_artifact_actions()` がダミーの CardPlayRequest に `artifact_data` と `artifact_counter` を入れて ActionGenerator に渡す — `data/prototype/ArtifactData.gd:92-108`
- `BaseArtifact` は combat_ended / player_turn_started / player_turn_ended だけを購読し、それ以外はサブクラスで足す — `scripts/artifacts/BaseArtifact.gd:9-17`, `:41-61`。例: `ArtifactBlockOnAttacks` は `Signals.card_played` を購読し、ATTACK を使うたびにカウンターを進める — `scripts/artifacts/ArtifactBlockOnAttacks.gd:4-12`
- 専用スクリプトがあるのは4つだけ (BlockOnAttacks / DrawOnKill / EasyMode / RetainHand) — `scripts/artifacts/`
- Interceptor の登録: 入手時に `Player._on_artifact_added` が `artifact_interceptor_ids` を `ActionHandler.register_action_interceptor` する — `scripts/combatants/Player.gd:195-208`
- `Signals.gd` には signal が74個定義されている。フックとして使えそうなものは card_played / card_drawn / card_discarded / card_exhausted / card_upgraded / card_added_to_deck / combat_started / combat_ended / player_turn_started / player_turn_ended / combatant_damaged / enemy_killed / player_artifact_added / rest_action_ended / shop_opened / map_location_selected など — `autoload/Signals.gd:34-134`
- 永続ステータス成長の前例: `artifact_increase_attack_on_rest` は入手時に休憩所の選択肢 "Increase Damage" を追加し、休憩所でカウンターを+1、各戦闘の1ターン目にカウンター値を `status_effect_damage_increase` として付与する (custom_key_names で counter → status_charge_amount に変換) — `autoload/GlobalProdDataGenerator.gd:171-192`, `:630-638`
- 本番レリック25個のうち、BOSS / SHOP の色別プレースホルダが10個 (`artifact_boss_red`〜`artifact_shop_white`) — `autoload/GlobalProdDataGenerator.gd:257-342`。テスト用の名前 ("Artifact Add Money", "Artifact Negate Money Gain" など) も混ざっている — `:44-62`
- スロットの概念: 消耗品は `player_consumable_slot_count = 3` と slot→id の辞書 — `data/prototype/PlayerData.gd:204-205`。カードデコレーターは1枠 — `data/prototype/CardData.gd:137`。レリックは `player_artifact_uid_to_artifact_data` に上限なく入る — `data/prototype/PlayerData.gd:141`

### Inferences
- 「装備」は ArtifactData を流用し、(1) `equipment_slot: String` フィールドを追加し、(2) `PlayerData.add_artifact` で同じスロットの既存装備を `remove_artifact` してから入れる、という最小の変更で作れそう。remove 時の interceptor 解除と remove_actions はすでに揃っている (`PlayerData.gd:530-544`, `Player.gd:206-208`)。
- 消耗品スロットの実装 (`slot_count` と `slot→id` 辞書) は、装備スロットの UI と保存形式の雛形にできる。
- 「休憩所で永続成長 → 戦闘開始時にステータスとして付与 → interceptor で数値に反映」という流れが既存のパターンとして確立しているので、ステータス軸の成長はこれを一般化すればよい。

### Gaps
- `scripts/ui/ArtifactContainer.gd` で表示数に上限があるか、どう並ぶかは未確認 (装備 UI をどこに置くかに影響する)。
- `ArtifactRetainHand` / `ArtifactDrawOnKill` の実装は読んでいない。

---

## 4. キャラクター/ヒーロー (Vera Thornforge)

### Takeaway
プレイアブルなキャラは緑の1人 (`character_green`、名前は "Vera Thornforge") だけ。HP 75、エネルギー3、開始レリックは `artifact_draw_on_combat_start` (初ターンに2枚ドロー)、開始デッキは19枚。ドラフト対象は緑のカードパックだけ。CharacterData は RunData 初期化用の読み取り専用データで、「ビルドパス」や「サブクラス」を表すフィールドはない。

### Cited Findings
- `character_green.character_name = "Vera Thornforge"`、`character_starting_health = 75` — `autoload/GlobalProdDataGenerator.gd:1674-1679`
- 開始レリックは `["artifact_draw_on_combat_start"]` — `:1681`。このレリックの効果は初ターンに `draw_count 2`、緑、UNCOMMON — `:97-103`
- カードのドラフト対象は `["card_pack_green"]` だけ (白パックを含まない)。レリックと消耗品は white + green — `:1680-1683`
- 開始デッキは basic_attack ×4、basic_block ×4、particle_accelerator ×2、critical ×1、wildflower ×4、meltdown ×2、photoelectric_synthesis ×2 の計19枚。コメントアウトされた候補が多数並んでいて、調整中だとわかる — `:1684-1705`
- `character_starting_money` は緑では設定していないので、既定値 999 で始まる — `data/readonly/CharacterData.gd:227` (`GlobalProdDataGenerator.gd` に `starting_money` の出現0件)
- エネルギーは `player_energy_max = 3` (PlayerData の既定) — `data/prototype/PlayerData.gd:13-15`
- CharacterData のフィールドは name / description / color / icon / animation / player_id / starting_artifact_ids / starting_card_draft_card_pack_ids / starting_artifact_pack_ids / starting_consumable_pack_ids / starting_card_object_ids / starting_money / starting_health のみ — `data/readonly/CharacterData.gd:6-43`
- PlayerData のプロトタイプは red / blue / green / orange の4つあるが、CharacterData は green だけ — `autoload/GlobalProdDataGenerator.gd:2253-2272`, `:1669-1717`
- `docs/character_design.md` では「既存の The Botanist に対応する人物として扱い、ゲーム内名称や能力、数値の変更は行わない」とし、デザインを見た目と演出に限っている。装備の意匠と能力は「前腕のシアン二重六角 = Overshield、籠手の三本トゲ = Pointy、背中の排熱口 = Overheat、腰の廃液カプセル = Waste」と対応づけている — `docs/character_design.md:9`, `:17`
- 2026-09-25 に背中の鉢原子炉 (苗) が削除された — `docs/character_design.md:68`。最新コミット `671fab6` と一致する
- README の遊び方には「The Botanist を選んでスタート」とあり、コード上の名前 (Vera Thornforge) と表記がずれている — `README.md:14`, `autoload/GlobalProdDataGenerator.gd:1676`

### Inferences
- ヒーローの見た目は装備ごとに能力アーキタイプへ対応づけてあり (Overshield / Pointy / Overheat / Waste)、「装備 = ビルド軸」というデザイン上の土台はすでにある。物理軸 = 剪定剣・トゲ、魔法(原子炉)軸 = Overheat / Critical、防御軸 = Overshield、と読み替えるとアートと矛盾しない。
- 「ビルドパス」は CharacterData に `character_build_path_ids` のような配列を足し、ラン開始時か幕の切り替え時に選ばせるのが既存の型に合う。

### Gaps
- Overshield / Pointy / Waste を中心にした緑カード群が、3つの region のどれに属するかの全体マップは作っていない (カードごとの action を全部は読んでいない)。

---

## 5. 報酬フロー (カード・レリック・ショップ・イベント・マップ)

### Takeaway
報酬はすべて PlayerData のキャッシュ (パック由来のカード/レリック/消耗品の ID 集合) から引く。カードは「レアリティの重み表 + レアの pity 補正」による重み付き抽選、レリックは「ラン開始時にシャッフルした全レリックのプールを前から順に取り出す」方式。**カードのタグやアーキタイプで偏らせる仕組みはない**。ただし、報酬は interceptor をかけられる Action (`ActionGrantRewards` / `ActionShopPopulateItems`) を経由するので、差し込む場所はすでにある。

### Cited Findings
- 戦闘報酬: `ActionGenerator.generate_add_location_rewards()` が money / card_drafts / artifact_ids を `ACTION_GRANT_REWARDS` に入れる — `autoload/ActionGenerator.gd:157-168`
- `ActionGrantRewards` は interceptor を通したあと `Signals.reward_grant_requested` を emit する。`reward_group` で排他的な報酬グループを作れ、`custom_action_data` で任意の報酬ボタン (例: 回復) も追加できる — `scripts/actions/rewards/ActionGrantRewards.gd:6-34`
- カードドラフトの重み (`CARD_DRAFT_RARITY_WEIGHTS`): STANDARD は C55/U43/R2、MINIBOSS は C50/U40/R10、BOSS は R100、SHOP は C55/U40/R5 — `autoload/Random.gd:123-151`
- pity: COMMON を引くたびに `player_rare_card_modifier_current += 1.5` し、その値だけ RARE の重みを上げて COMMON を下げる — `autoload/Random.gd:165-207`, `data/prototype/PlayerData.gd:133-135`
- 抽選元は `player_reward_card_rarity_cache` (パックの合計 − blacklist + whitelist を、レアリティ別のバケットにしたもの) — `data/prototype/PlayerData.gd:585-612`
- 1回の報酬は `reward_cards_per_draft = 3` 枚の候補を `reward_drafts = 1` 回 — `data/prototype/PlayerData.gd:115-117`, `autoload/Random.gd:259-278`
- カードパックは `card_pack_card_ids` / `card_pack_color_id` / `card_pack_validators` (ValidatorCardTag などでの絞り込み) を持つ — `data/readonly/CardPackData.gd:9-32`。CardFilter には type / rarity / energy_cost / colors / validators での絞り込みがある — `data/filters/CardFilter.gd:40-189`
- レリック: `initialize_artifact_pool()` で全レリック ID を rng でシャッフルし、`get_next_artifacts_from_pool()` で「入手可能 (パックのキャッシュ) かつ指定レアリティ」のものを前から (ショップは後ろから) 取り出す — `data/prototype/PlayerData.gd:422-503`
- レリックのレアリティ重み: 宝箱は C50/U35/R15、ミニボスは C25/U50/R25、ボスは BOSS レアリティから — `autoload/Random.gd:284-317`
- ショップ: カード6枚 (SHOP の重み表、pity なし)、通常レリック2個 + ショップ専用1個、消耗品3個 — `data/mutable/ShopData.gd:22-25`, `:59-80`。最後は `ActionShopPopulateItems` で、これも interceptor をかけられる — `scripts/actions/shop_actions/ActionShopPopulateItems.gd:15-24`
- 消耗品の選び方は `Random.get_random_consumable_object_id()` で、重みのない一様抽選 — `autoload/Random.gd:241-251`
- お金の報酬は 25〜49G — `autoload/Random.gd:280-282`
- 休憩所の既定の選択肢: rest / upgrade_card / remove_cards / add_random_consumable / enchant_cards (25G でデコレーター付与) — `data/prototype/PlayerData.gd:104-110`, `autoload/GlobalProdDataGenerator.gd:446-626`
- ラン開始時のオプション (Neow 相当): upside と downside をそれぞれシャッフルして組み合わせ、選択肢にする — `scripts/ui/RunStartOptions.gd:25-67`。中身は最大HP±、お金±、カードのドラフト、COMMON レリック、ボスレリックとの交換など10種 — `autoload/GlobalProdDataGenerator.gd:1836-1972`
- マップ: StS2 風で、7列 × 15/14/13行、経路6本、エリート5・商人3・? 10〜14・休憩6〜7。? の中身は 敵10%/商人3%/宝箱2% から始まり、外れるたびに確率が上がる — `scripts/actions/world_generation_actions/ActionGenerateAct.gd:1-33`, `docs/sts2_research.md:5-19`
- 幕データ: Act 2 と Act 3 は Act 1 の event pool をそのまま使っており、hard combat も easy プールを指している — `autoload/GlobalProdDataGenerator.gd:1135-1153`
- イベント (?): 10種。レリック報酬は `_relic()` / `_relic([RARE])` で出す — `scripts/content/EventContent.gd:12-24`, `:55`

### Inferences
- アーキタイプに偏らせる報酬は、次のどちらかで既存構造に沿って実現できる。
  1. 低侵襲: `generate_rarity_weighted_card_draft()` のバケットから1枚選ぶところ (`Random.gd:186-194`) で、card_tags と「プレイヤーが選んだビルドの tag」の一致に応じて重みを掛ける。
  2. さらに疎結合: 報酬を出す Action (ActionGrantRewards) に interceptor を差し込み、`card_drafts` の中身を差し替える。既存の interceptor 機構の範囲で完結し、Random.gd に手を入れずに済む。
- 現状、緑カードに `card_tags` が1枚も付いていないので、偏りの抽選をする前に、まず region (Health / Research / Critical) をタグとしてデータに落とす作業が要る。
- レリックのプールは「シャッフルした列の順番」で決まるので、重みで偏らせるには `get_next_artifacts_from_pool` に重み付きの選び方を足すか、ビルドごとの ArtifactPack (例: `artifact_pack_green_physical`) を `player_artifact_pack_ids` に足し引きするのが単純。後者は既存の API (`regenerate_artifact_available_id_cache`) だけで済む — `data/prototype/PlayerData.gd:618-626`

### Gaps
- `ActionBasePickCards` (338行) のドラフト機能 (`draft_is_weighted` などのパラメータ) は一部しか読んでいない — `scripts/actions/card_actions/pick_card_actions/ActionBasePickCards.gd:193`
- `RewardOverlay` がカードのスキップや複数ドラフトをどう UI に出すかは、骨格しか確認していない — `scripts/ui/RewardOverlay.gd:35-107`

---

## 6. docs の設計意図 (難易度・ビルド・アーキタイプ)

### Takeaway
docs は「土台の取り込みと Codex へのアート委託の手順」「StS2 準拠のマップ構成」「?イベントの型」「主人公の外見」が中心で、**ビルド多様性・装備・ステータス軸・アーキタイプ設計についての記述はない**。難易度についてはコード上に Difficulty 1〜5 の run modifier があるだけ。

### Cited Findings
- PLAN.md はアート委託パイプラインのフェーズ1〜9 で、ゲームデザインの項目はない — `docs/PLAN.md:17-27`
- sts2_research.md には StS2 の幕構成とマップ生成、報酬の相場 (通常戦闘 10〜20G + カード3択、エリートはレリック確定、休憩は30%回復 or 強化、ポーションのドロップ率40%±10%) がまとまっている — `docs/sts2_research.md:5-21`
- events.md の設計ルール: すべてのイベントに無難な選択肢を置く。報酬が大きいほどコストか不確実性も大きくする。呪いの代わりにこのキャラの仕組みに合う「放射性廃棄物 (Waste)」を負のカードとして使う — `docs/events.md:27-31`
- events.md の相場: 遺物1つ ≒ HP 8〜15 / 最大HP 8〜13 / 呪い1枚 / 100〜200G — `docs/events.md:10`
- character_design.md は外見に限った設計で、能力と数値は変えない方針 — `docs/character_design.md:9`
- README: 「クビになった熱核植物学者が、暴走した園芸ロボットだらけの原子炉温室を駆け上がる、StS 風デッキ構築ローグライク」 — `README.md:3`
- 難易度: `run_modifier_difficulty_1`〜`_5` ("Harder Enemies", "Harder Minibosses", "Harder Bosses", 4, 5) — `autoload/GlobalProdDataGenerator.gd:1725-1756`、ほかに Easy Mode / Endless / Prismatic (全色ドラフト) / Auto Revive — `:1772-1825`
- コード上のアーキタイプは3つ: Health and Self Damage / Research / Critical — `autoload/GlobalProdDataGenerator.gd:2454`, `:2990`, `:3156`

### Inferences
- ビルド多様性の設計は白紙に近い。一方で、region の3分割と装備意匠の4要素 (Overshield / Pointy / Overheat / Waste) はアーキタイプの種として使える。
- events.md の「安全で小さい報酬 ⇔ 危険で大きい報酬」という型は、ビルド選択イベント (例: どちらかの装備を受け取る) にそのまま転用できる。

### Gaps
- `docs/art_direction.md` (125行) は読んでいない。アートの色と形の意味にアーキタイプの記述が含まれているかは未確認。
- `tools/codex_art/design_brief.md` / `character_brief.md` は読んでいない。

---

## 7. 拡張ポイント (装備スロット / ステータス軸 / 偏った報酬 / ビルドパス)

### Takeaway
4つとも、既存の「データ + Action + Interceptor + Signals」の枠組みに、新しいエンジン機構を作らずに乗せられる。最小の変更で済む順に並べると、(2) ステータス軸 → (1) 装備スロット → (3) 偏った報酬 → (4) ビルドパスになる。

### Cited Findings (各案の土台になる既存コード)
- **(1) 装備/ギアスロット**
  - 土台は ArtifactData で、interceptor 登録と add/remove アクションが揃っている — `data/prototype/ArtifactData.gd:10`, `:40-42`, `scripts/combatants/Player.gd:202-208`
  - スロット管理の雛形: 消耗品の `player_consumable_slot_count` と `player_consumable_slot_to_consumable_object_id` — `data/prototype/PlayerData.gd:204-205`
  - 付け替え: `PlayerData.remove_artifact()` は remove_actions の実行と Signal の emit まで行う — `data/prototype/PlayerData.gd:530-544`
  - 保存: PlayerData の `@export` フィールドは `PROPERTY_USAGE_STORAGE` 判定で自動的に保存される — `data/SerializableData.gd:134-143`
- **(2) ステータス軸 (物理パワー / 魔法パワー)**
  - 値の置き場所: `PlayerData.player_values` (保存され、action value 階層の最後に参照される) — `data/prototype/PlayerData.gd:23-26`, `scripts/actions/BaseAction.gd:190-192`。更新用の Action は既存 — `ActionUpdatePlayerValue.gd:4-17`
  - 計算の置き場所: 新しい interceptor (`InterceptorDamageIncrease` と同じ形) を、レリックや run modifier の `*_interceptor_ids` でプレイヤーに常設する — `scripts/action_interceptors/InterceptorDamageIncrease.gd`, `scripts/combatants/Player.gd:184-200`
  - 種別の識別: `action_tags` (Action 側) と `card_tags` (Card 側) がある — `scripts/actions/BaseAction.gd:26-28`, `data/prototype/CardData.gd:142-144`
  - UI: カード説明の数値プレビューが intercept 後の値を緑/赤で出す — `scripts/ui/card/Card.gd:205-227`
  - 前例: 休憩所 → カウンター → 戦闘開始時にステータス付与 → interceptor — `autoload/GlobalProdDataGenerator.gd:171-192`, `:630-638`
- **(3) アーキタイプに偏らせた報酬**
  - 介入点A: `Random.generate_rarity_weighted_card_draft()` のバケットから選ぶ部分 — `autoload/Random.gd:184-199`
  - 介入点B: `ActionGrantRewards` / `ActionShopPopulateItems` の interceptor — `scripts/actions/rewards/ActionGrantRewards.gd:7-15`, `scripts/actions/shop_actions/ActionShopPopulateItems.gd:15-24`
  - 介入点C: パック単位の出し入れ (`reward_draft_card_pack_ids`, `player_artifact_pack_ids` と各 `regenerate_*`) — `data/prototype/PlayerData.gd:126`, `:155`, `:585-626`。Prismatic modifier が「パックを差し替えてドラフト範囲を変える」前例 — `autoload/GlobalProdDataGenerator.gd:1808-1810`, `scripts/run_modifiers/custom/RunModifierCustomDraftAllColors.gd`
- **(4) ヒーローのビルドパス選択 (Monster Train のチャンピオン強化風)**
  - 選択 UI の前例: ラン開始オプション (DialogueOption ボタンにアクション配列を結びつける) — `scripts/ui/RunStartOptions.gd:25-67`
  - 選択 UI の前例: ダイアログ型イベント (state / option / validator / ロック表示) — `scripts/content/EventContent.gd:161-221`
  - 休憩所に選択肢を動的に足す前例: `ACTION_UPDATE_REST_ACTIONS` の `add_rest_action_object_ids` — `autoload/GlobalProdDataGenerator.gd:179-181`
  - 幕の切り替え: `act_next_act_ids` と `ActionGenerator.generate_act()` — `autoload/GlobalProdDataGenerator.gd:1126`, `autoload/Global.gd:280`

### Inferences
- **(2) ステータス軸**: interceptor を1本 (例: `InterceptorStatScaling`) と、`player_values` のキー (`stat_physical`, `stat_magic` など) を足し、カードの play action に `action_tags` (`["physical"]`) を付ければ動く。既存カードのデータは tag を付けるだけでよい。KISS/YAGNI 的に最も小さい。
- **(1) 装備**: 新しいデータ種を作らず、ArtifactData に `artifact_equipment_slot: String = ""` を1フィールド足し、「同じスロットなら入れ替え」の判定を `add_artifact` に数行足すのが最小。装備の効果は既存のフック (interceptor / add_actions で player_values を加算) で表現できる。
- **(3) 偏った報酬**: 介入点B (interceptor) が「主体 (報酬 Action) が流れてきて加工される」という作りで、ユーザーのベルトコンベア設計方針とも一致する。重みは Random.gd に依存させず、interceptor の中で card_tags を見て候補を入れ替える。
- **(4) ビルドパス**: CharacterData に `character_build_path_ids` を足し、BuildPathData (readonly: 名前 / 説明 / 付与する装備・パック・player_values) を SCHEMA に追加し、選ぶ UI は RunStartOptions かイベントのダイアログを流用する、という形が既存の流儀に合う。ボス撃破後 (幕の切り替え) に2段目の強化を選ばせるなら、ボス報酬の `custom_action_data` (任意の報酬ボタン) が使える — `scripts/actions/rewards/ActionGrantRewards.gd:16-32`

### Gaps
- `ActionAttackGenerator` から子の `ActionAttack` に `action_tags` が伝わるかは未確認。伝わらなければ、tag 方式には Generator 側の数行修正が要る。
- 敵の攻撃も同じ ActionAttack を使う場合、プレイヤー専用の interceptor は `modifies_parent = true` で自分の攻撃だけに効く設計になっている (`ActionInterceptorData.gd:7`)。敵側への影響はないはずだが、実際に動かしての検証はしていない。

---

## 8. 1000行超のファイルと結合リスク

### Takeaway
1000行を超えるのはデータ生成の2ファイル (本番3529行、未使用のテスト用4741行) と、ツール用の JSON 2つ。設計上いちばん大きなリスクは「全データが1ファイルの手続きコードに集中していること」と「Global / Signals / ActionHandler の autoload に密結合していること」。ほかに、データ不整合のバグらしき箇所がいくつかある。

### Cited Findings
- 行数: `autoload/GlobalTestDataGenerator.gd` 4741行、`autoload/GlobalProdDataGenerator.gd` 3529行、`tools/codex_art/assets.json` 1772行、`tools/codex_art/slots.json` 1485行。その次は `addons/smooth_scroll_container/SmoothScrollContainer.gd` 968行、`autoload/HandManager.gd` 774行、`autoload/Global.gd` 695行、`data/prototype/PlayerData.gd` 664行 — `wc -l` の結果
- テスト用の生成器は呼び出しがコメントアウトされている (死蔵コード) — `autoload/Global.gd:180`
- **ID の衝突**: Auto Revive の run modifier が `RunModifierData.new("run_modifier_draft_all_colors")` と Prismatic と同じ ID で登録されている — `autoload/GlobalProdDataGenerator.gd:1808`, `:1820`
- `has_action_value()` が `card_values.has("key_name")` と文字列リテラルで判定している (変数ではない) — `scripts/actions/BaseAction.gd:207`
- 緑キャラのドラフトパックが `card_pack_green` だけなので、白カード `card_energy_next_turn` は報酬に出ない — `autoload/GlobalProdDataGenerator.gd:1680`, `:2426-2448`
- 開始資金が既定値の 999G のまま — `data/readonly/CharacterData.gd:227`
- Act 2 と Act 3 は Act 1 の敵・イベントプールを流用 — `autoload/GlobalProdDataGenerator.gd:1135-1153`
- `status_effect_duplicate_attacks` と `status_effect_block_on_special_discard` の表示名や interceptor がコピペのまま ("Duplicate Play"、`interceptor_duplicate_attacks`) — `autoload/GlobalProdDataGenerator.gd:1101-1116`
- Interceptor はスクリプトパスの文字列一致で対象 Action を判定する (`action.get_script().resource_path` と `action_intercepted_action_paths` の比較) — `scripts/action_interceptors/ActionInterceptorProcessor.gd:91-92`, `:111-112`
- Interceptor は登録された戦闘者ごとに、処理のたびに `load()` → `new()` される — `scripts/action_interceptors/ActionInterceptorProcessor.gd:131-135`
- ほとんどのデータクラスとアクションが `Global.player_data` を直接参照している (例: `CardData.gd:199`, `BaseAction.gd:191`, `Random.gd:162`)

### Inferences
- ビルド系のデータ (装備・ビルドパス・タグ付けしたカード) を `GlobalProdDataGenerator.gd` に足し続けると、ユーザー規約の「1000行超は分割」にさらに反する。`EventContent.gd` と同じ形の `scripts/content/EquipmentContent.gd` や `BuildPathContent.gd` に分けるのが妥当。ついでに既存のカード定義 (`add_cards_green`, 約970行) を `CardContentGreen.gd` に切り出すのが、影響の小さい最初の分割候補になる。
- Interceptor はスクリプトパスで照合するので、新しい Action を作ると既存の interceptor (筋力など) が効かなくなる。ステータス軸は「新しい Action を作る」より「既存の ACTION_ATTACK / ACTION_BLOCK に tag を付けて interceptor で分岐する」ほうが安全。
- interceptor を処理のたびに `load()` しているので、ステータス軸の interceptor を何本も常設するとプレビュー計算 (手札のカード全部 × 対象) のコストが増える。本数は少なく (例: 1本で全軸を処理) 保つのがよい。
- ID 衝突 (`run_modifier_draft_all_colors`) は、`register_rod(..., allow_collisions = true)` が既定なので黙って上書きされている可能性がある (`autoload/Global.gd:136`)。新しいデータ種を足すときも、ID の重複検知がない前提で命名する必要がある。

### Gaps
- `register_rod` の衝突時の挙動 (上書きか無視か) は、関数の頭しか見ておらず中身は未確認 — `autoload/Global.gd:136`
- 実際に起動 (`godot --headless`) してエラーを確認する作業はしていない (読み取りのみの指示のため)。
