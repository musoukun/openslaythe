# Slay the Spire 2 の難易度評価と「挑戦 vs パワーファンタジー／ビルド自由度」設計論

> 調査日: 2026-10-16。重要な前提訂正: 依頼文では「Early Access since March 2025」とあるが、実際の StS2 アーリーアクセス開始は **2026年3月5日**（2025年予定から2025年9月に延期発表）— [Wikipedia: Slay the Spire II](https://en.wikipedia.org/wiki/Slay_the_Spire_II)。以下「EA初期」= 2026年3〜4月、「後期」= 2026年5〜10月。

## Q1. StS2 は「難しすぎる／窮屈／壊れ瞬間が足りない」と言われているか。パッチ対応と Mega Crit の発言は？

### Takeaway
EA初期（2026年3〜4月）は「Act1 の敵ダメージが高すぎる」「A0 に前作のアセンションが数段分入っている」「勝つには壊れコンボが必須」という声が多く、一方で Mega Crit は初回バランスパッチ（v0.100.0）で無限コンボを潰しにかかり、**「難しいから無限ビルドに頼るしかないのに、その無限を潰した」**という反発で大規模なレビュー爆撃を受けて一部撤回した。その後 Mega Crit は「ベース難易度は quite hard」と認め、低アセンションを緩和・高アセンションを強化する方針に転じたが、「1枚のカードを雪だるま式に育てる」ことには明確に抑制的な姿勢を保っている。

### Cited Findings

**ローンチ規模（文脈）**
- EA 開始 2026年3月5日。初日同時接続 17.7万人超（Hades 2 / Mewgenics の記録超え）、翌日 40万人超、初週販売 300万本超 — [Wikipedia](https://en.wikipedia.org/wiki/Slay_the_Spire_II)
- Mega Crit は「EA 期間の大半はバランス調整に費やす」と表明。1.0 までの見込みは 1〜2年 — [Wikipedia](https://en.wikipedia.org/wiki/Slay_the_Spire_II)

**EA初期のプレイヤーの難易度不満（Steam 掲示板、逸話的サンプル）**
- スレ「Game's difficulty seems to be significantly above StS 1」(2026/3/26)。OP は「敵は強化されたのにプレイヤー側は前作移植カードが大半で強くなっていない」「アセンション1で何度も休憩所で休む羽目に」「3階の通常敵に1ターン目26ダメージ」と述べ、結論として「It seems that getting a 'busted' combo is now a requirement to win a run」— [Steam Discussions](https://steamcommunity.com/app/2868840/discussions/0/798965575663498393/)
  - 同スレ返信: 「80%のランが最初のボスかエリートで終わる、勝ちは実力より運」(MIghtyepson)、「60時間以上で1勝」(Amy 80)、「Act1 が前作よりずっと難しい」(kidgoat2027)。反対意見として「v0.99 は前作よりずっと簡単だった、v0.100 で勝率が妥当になった」(Missingno.)、「配信者の連勝を見れば前作より簡単」(Gert)、「HP やルートの判断が前作よりダイナミック」(Kihp) — 同上
- スレ「Feedback: A10 Enemy Damage is Extremely Overtuned」(2026/4/6)。前作 A20 クリア経験者の OP が「A10 の Act2 は毎ターン25+、Act3 は2ターン目から約30ダメージ」「ブロックかダメージ軽減をスケールできないとほぼ死ぬ」「序盤価値で組んで後でピボットができず、希少パーツを探すしかない」「A10 は賢い判断より運」と主張。Ironclad/Regent はブロックカードが何戦も出ないことがあると指摘 — [Steam Discussions](https://steamcommunity.com/app/2868840/discussions/0/798966340583124298/)
  - 反論: 「A10 は易しすぎるより難しすぎる側に倒すべき、下のアセンションがあるのだから」(Missingno.)、「StS2 の A10 Act2 は StS1 の同等遭遇と難易度が釣り合っている」(Floro) — 同上
- 検索要約レベルでは「A0 に前作のアセンション数段分が最初から焼き込まれている感じ」「Act1 でランの9割が死ぬ」「逆に史上最も簡単なローグライクの一つ」など両論が混在 — [Steam: Devs I beg you…](https://steamcommunity.com/app/2868840/discussions/0/806845425982236000/), [Steam: Interesting that they say the base game is too difficult](https://steamcommunity.com/app/2868840/discussions/0/798968152812740969/), [Steam: Community thoughts on Act 1 difficulty](https://steamcommunity.com/app/2868840/discussions/0/802341528343175812/)（※スレッド本文は未精読、検索スニペットのみ）

**無限コンボ潰しパッチ（v0.100.0, 2026年3月中旬・ベータ）とレビュー爆撃**
- v0.100.0 は「無限を達成しにくくする（ただし完全には消さない）」パッチ。PCGamesN は無限を「StS2 のパワーカーブの根幹」と表現。調整対象: Silent の Prepared、Regent の Glow / Alignment / Void Form 等、Ironclad の Expect a Fight / Stoke / Dominate 等、Necrobinder の Borrowed Time / Seance 等、無色 Hidden Gem、マルチ用カードなど（記事は Mega Crit の直接引用ではなく記者の要約）— [PCGamesN 2026/3/20](https://www.pcgamesn.com/slay-the-spire-2/patch-notes-infinites-nerfed)
- TheGamer: 通常1日約100件の否定レビューが約8,500件に急増。プレイヤー Leo Dilu「ゲームが難しすぎるから cycling/無限ビルドを強いられている」、Ghost14「シングルプレイのゲームを、有効な選択肢を弱体化してバランス取りするのはやめてくれ」「一部の戦術が使われすぎるのは強すぎるからではなく、他が弱すぎるから」。批判の核は「代替を強化せずに潰した」こと — [TheGamer 2026/3/20](https://www.thegamer.com/slay-the-spire-2-review-bombed-balance-changes/)
- 別集計では「1日1万件超の否定レビュー」— [sts2front（ファン攻略サイト）](https://www.sts2front.com/tips/v0101-patch-revert-analysis/)（数字はソース間で不一致: 4,800 / 5,000 / 8,500 / 10,000+）
- 中国語（簡体字）レビュー約7.5万件が「Mostly Negative」と GameSpot が報道 — [GameSpot（検索スニペット、本文403で未精読）](https://www.gamespot.com/articles/slay-the-spire-2-is-fantastic-so-why-is-it-being-review-bombed/1100-6539724/)
- Kotaku: Steam のレビュー爆撃フィルタ ON で 94%「Very Positive」、OFF で 56%「Mixed」。3回の爆撃の内訳は (1) Act3 ボス Doormaker の強化、(2) Doormaker が弱体化されないこと、(3) Anita Sarkeesian のコンサルタントクレジット — [Kotaku](https://kotaku.com/slay-the-spire-2-as-told-by-steam-reviews-2000699834)
- GamesRadar 見出し: StS2 は否定レビュー約8万件、前作が9年で受けた量の約14倍 — [GamesRadar](https://www.gamesradar.com/games/roguelike/slay-the-spire-2-has-almost-80-000-negative-steam-reviews-nearly-14-times-more-than-the-first-game-received-in-9-years/)（見出しのみ確認）

**撤回（v0.101.0, 2026/3/28前後）**
- Prepared / Borrowed Time / Capture Spirit の弱体化を（全部または一部）巻き戻し、Doormaker・Skulking Colony・序盤エリート・Gloom 関連の難易度上昇も巻き戻し。Notebookcheck は開発の説明を「明らかに間違ったアプローチだった」と要約。Borrowed Time は「どのデッキでも楽しいカード」にしたいので将来再設計の可能性 — [Notebookcheck 2026/3/28](https://www.notebookcheck.com/Slay-the-Spire-2-zieht-Reissleine-Neuer-Patch-nimmt-kritisierte-AEnderungen-zurueck.1261216.0.html)
- Wikipedia は「2回目のパッチで1回目のアップデートが "not favorable" だったと認めて一部を巻き戻した」と記述 — [Wikipedia](https://en.wikipedia.org/wiki/Slay_the_Spire_II)
- Anthony Giovannetti「Player feedback has been instrumental in helping guide our process. Progress will not be linear.」— [sts2front 経由の引用](https://www.sts2front.com/tips/v0101-patch-revert-analysis/)
- PC Gamer 見出し: Mega Crit は初回バランスパスを「the first of many」と呼び「No change is necessarily permanent」と表明 — [PC Gamer](https://www.pcgamer.com/games/card-games/mega-crit-responds-to-the-panic-over-slay-the-spire-2s-1st-balance-pass-saying-these-changes-are-the-first-of-many-no-change-is-necessarily-permanent/)（本文未取得、見出しのみ）

**難易度緩和（v0.104.0 ベータ, 2026年4月）**
- 共同代表 Anthony Giovannetti がベース難易度は「quite hard」と認める。Act1 の Scrolls of Biting / Owl Magistrate / Slimed Berserker は低アセンションで HP 減・高アセンションで HP 増、Act1 ボス Vantom を低難度で弱体化、エリート Waterfall Giant の回復を低難度で減少。低/高アセンションの差は「過剰修正を避けて段階的に広げる」方針 — [eTeknix 2026/4/24](https://www.eteknix.com/slay-the-spire-2-difficulty-rebalanced-in-latest-beta-patch/)
- GamesRadar 見出し:「弱いカード・レリックを強化、Mega Crit は game "is quite hard" と同意、低アセンションを "more accessible" にしたい」— [GamesRadar](https://www.gamesradar.com/games/roguelike/new-slay-the-spire-2-patch-makes-some-terrible-cards-and-relics-actually-good-mega-crit-agrees-the-game-is-quite-hard-and-wants-lower-ascensions-to-be-more-accessible/)
- PCGamesN 見出し: 本線反映時「序盤は易しく、無限は難しく」— [PCGamesN](https://www.pcgamesn.com/slay-the-spire-2/patch-notes-live-april-2026)
- 4月の Neowsletter で Casey Yano「すべてのカードとアイテムが interesting and viable に感じられるよう rework/balance している」。エンドレスモードは「Probably not」、理由は「ランが長くなるほどデッキ構築が面白くなくなる」「Balatro の方が上手く扱えているのは無限戦略が成立しにくいから」 — [Mega Crit Neowsletter 2026/4/17](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/)

**後期（2026年5〜10月）**
- v0.106〜v0.111: 敵の大規模リワーク、Doormaker を削除し Aeonglass に置換、RNG リワーク、Regent バフ、v0.109 の再設計を v0.110 で一部撤回など（ファン集計サイトで日付・版に不一致あり）— [gamedropdaily](https://gamedropdaily.com/updates/slay-the-spire-2/), [slaythetierlist（ファンサイト）](https://slaythetierlist.com/patch-notes), [Gamerant](https://gamerant.com/slay-the-spire-2-update-patch-notes-april-2026/)
- v0.111.0 で Ironclad の Expect a Fight がブロックカード化（無限対策の継続）との記述はファンサイト単独情報 — [slaythetierlist](https://slaythetierlist.com/patch-notes)
- 2026年8月 Neowsletter: Casey「Ascension 10 is close to the highest difficulty we'll have」「キャラが増えたので A20 を埋めるのは苦行」「挑戦的難易度の扱いはいずれ明確にする」。エンチャントのスタック禁止の理由として「単一カードを雪だるま式に育てる確率が上がる」「We want our players to experience deckbuilding rather than cardbuilding!」。実験的ゲームモードを開発中。別 Act2 と新キャラを開発するため更新間隔を空ける — [Mega Crit Neowsletter 2026/8/14](https://www.megacrit.com/news/2026-8-14-neowsletter-issue-25/), [TechTimes 2026/8/15](https://www.techtimes.com/articles/324630/20260815/slay-spire-2-pauses-patches-sixth-character-alternate-act-2-are-next.htm)

**批評家（EAレビュー）**
- GamesRadar EA レビュー「Instantly familiar, but already bursting with new ideas」。新キャラはセットアップとリソース管理寄り — [GamesRadar](https://www.gamesradar.com/slay-the-spire-2-review/)
- 複数のEAレビューが「バランスに課題あり」と指摘（検索要約）— [NoobFeed](https://www.noobfeed.com/reviews/slay-the-spire-2-early-access-review), [Rogueliker](https://rogueliker.com/slay-the-spire-2-early-access-impressions/)

### Inferences
- 不満の構造は「難しい」単独ではなく、**「被ダメージが高い → 生存には強烈なシナジー（無限）が必要 → その頼みの綱を開発が潰す」**という連鎖。プレイヤーは無限を「ズル」ではなく「高難度への正当な解答」と受け取っていた。これは爽快感設計において決定的な教訓。
- 「運ゲー」批判（A10 は判断より運）は、ブロック/防御カードの供給が不安定なこと＝**一貫性ツールの不足**に起因する部分が大きいと読める。
- Mega Crit は「全カードを viable に」「deckbuilding であって cardbuilding ではない」「無限は稀に」と、**突出を均す方向の哲学**を一貫して持つ。プレイヤーの一部が求める「壊れる自由」とは方向性がずれている。
- 2026年4月以降は低難度緩和・ボス撤去など「受け入れやすさ」へ寄せた修正が続き、初期ほどの炎上は報道されていない（ただし後期の Steam スコア推移は未確認）。

### Gaps
- 2026年10月時点の Steam 総合/直近レビュー％は未取得（ストアページ直接確認が必要）。
- 2026年9月の Neowsletter の内容は未確認。
- r/slaythespire の具体スレは検索で拾えず（Steam 掲示板中心の証拠）。
- v0.100.0 の Mega Crit 公式パッチノート原文（無限についての開発者自身の文言）は未取得。PCGamesN/Notebookcheck の要約に依拠。

## Q2. StS1 は「壊れた」無限・コンボランを多く許したか。プレイヤーが挙げる最高に楽しい瞬間は？

### Takeaway
StS1 でも開発者は「無限は最も稀にしたいもの」と明言しており、壊れコンボは「毎回は来ない稀な当たり」として存在していた。プレイヤーは Corruption + Dead Branch などを代表的な快感として語り、「確実に毎回組めたら問題だが、稀に組めるのが楽しさの一部」という合意が古くからある。StS2 の問題は無限の存在可否より、**ベース難易度が上がって「稀な当たり」が「必須」に変わった**点にあると見える。

### Cited Findings
- Giovannetti:「Going infinite is the number one thing we try to make really rare. It makes the actual playing of the game trivial.」Dual Wield は「totally broken」「スキルをコピーして無限ができた」ため軽く弱体化。記事はシングルプレイなので「純粋なバランスではなく娯楽価値のために変更できる」と記述 — [Game Developer](https://www.gamedeveloper.com/design/how-i-slay-the-spire-i-s-devs-use-data-to-balance-their-roguelike-deck-builder)
- GDC 2019「Metrics Driven Design and Balance」: 採用率と勝利デッキ出現率を主要指標とし、低すぎるカードは「basically not a card in our game」。シングルプレイなので**稀な壊れコンボを他プレイヤーに迷惑をかけず許容できる**のが利点と述べた（要約サイト経由）— [GDC Vault](https://www.gdcvault.com/play/1025731/-Slay-the-Spire-Metrics), [Podwise要約](https://podwise.ai/episodes/1459444), [Game Developer プレビュー](https://www.gamedeveloper.com/design/learn-i-slay-the-spire-i-s-metrics-driven-approach-to-game-balancing-at-gdc-2019)
- ストリーマー/YouTuber のフィードバックがバランス調整に「非常に貴重」だった — [PCGamesN](https://www.pcgamesn.com/slay-the-spire/slay-the-spire-balance)
- Corruption + Dead Branch はガイドで「最も壊れたコンボ」とされ、300+ ブロックの報告も。ただし「毎ランで Dead Branch / Corruption が揃うわけではない」と信頼性の低さも指摘。Echo Form（Defect）+ Creative AI 等の事例で「壊れコンボを作れるのが楽しさの一部、毎回確実に組めたら問題」という返信（2018〜2019年の Steam フォーラム、検索要約）— [earlyguides](https://earlyguides.com/slay-the-spire/builds), [Steam StS1 Discussions（検索結果群）](https://steamcommunity.com/app/646570/discussions/0/1778262124930086284)
- 4月 Neowsletter で Casey は「ランが長くなるほどデッキ構築は面白くなくなる」としてエンドレスモードに否定的 — [Mega Crit](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/)

### Inferences
- StS1 の「壊れ」は「低頻度・高インパクト」の当たりとして設計されていた（＝変動比率報酬）。StS2 EA初期は敵側の数値が上がり、当たりの「必要度」が上昇 → 外れランの体験が劇的に悪化した、という解釈が Q1 の証言と整合する。
- 「deckbuilding rather than cardbuilding」「無限は稀に」は StS1 から一貫した Mega Crit の美学であり、StS2 で哲学が変わったわけではない。変わったのは敵の圧力とプレイヤーの期待値（前作経験者の母数）。

### Gaps
- StS1 の無限発生率・勝率の定量データは見つからず。
- StS1 の Echo Form スレッドの正確な URL は特定できず（検索結果の帰属が曖昧）。

## Q3. 「プレイヤーを最強にする」ゲームは挑戦性をどう保っているか（Balatro / Vampire Survivors / Brotato / Hades / Risk of Rain 2 / Monster Train）

### Takeaway
成功例に共通するのは、(1) 難易度を **opt-in の段階制**（Stakes / Heat / Danger / 難易度クロック）にして「最強になる自由」と「挑戦」を別レイヤーに分ける、(2) 時間・アンテで**敵側もエスカレート**させ、どこかで必ず天井に当たるようにする（Balatro の naneinf キルスクリーン、RoR2 の時間スケーリング）、(3) 救済は「敵を弱くする」でなく「プレイヤーを少しずつ強くする」（Hades God Mode）、の3点。

### Cited Findings
- **Balatro**: デッキごとにクリアで「Stakes」が解放され高難度条件が追加。アンテ8で勝利後もエンドレス継続可。アンテ39超で必要チップが倍精度浮動小数点で溢れ「naneinf」となり進行不能＝キルスクリーン。PC Gamer は「スコアが高すぎてクラッシュさせることでしか終われない」と表現。発売8時間で100万ドル、2025年1月までに500万本超 — [Wikipedia: Balatro](https://en.wikipedia.org/wiki/Balatro)
- **LocalThunk（Balatro）**: 壊れコンボについて両面の感情。問題なのは「Something can be overpowered in a way that excludes the player from experiencing other fun」、常に使える楽な戦略を「the path of least resistance」と呼ぶ。上級者が想定外のコンボを見つけると「it makes me feel good that this game ended up being so emergent」— [Game Informer 2024/3/21](https://gameinformer.com/interview/2024/03/21/balatro-was-almost-called-joker-poker-and-other-details-from-its-creator)
- LocalThunk: すべての Joker は何らかの調整を受けており、多様なプレイを促しつつ面白さを保つバランスを目指す。バランスは「hard」ではなく継続的プロセス — [Rogueliker](https://rogueliker.com/balatro-interview/)
- **Hades（Supergiant, Greg Kasavin）**: God Mode は即20%被ダメ軽減、死ぬたびに+2%（最大80%）。敵は弱くせず「What if we just make you a little bit tougher?」。通常のイージーモードにしない理由は「If you could just blow through it, what's interesting about the game goes away」（死とループが体験の核）— [Inverse](https://www.inverse.com/gaming/hades-god-mode-interview), [Can I Play That](https://caniplaythat.com/2021/08/11/hades-god-mode-explained-by-supergiant-games/)
- Hades の Pact of Punishment（Heat）は敵強化・敵数増・ボス変化を選んで積む方式で、継続的な高難度は希少報酬・装飾・NPCサブプロットを解放 — [Wikipedia: Hades](https://en.wikipedia.org/wiki/Hades_(video_game))
- **Risk of Rain 2**: 敵が時間経過で強く・多くなる難易度クロック。Drizzle は通常の50%、Monsoon は150%の速度 — [RoR2 wiki](https://riskofrain2.wiki.gg/wiki/Difficulty)。初代では敵撃破速度で難易度を上げる案も試したが「highs and lows」が消えたため不採用、時間ベースは「育成に時間を使うか、早く進むか」の選択を生む — [Wikipedia: Risk of Rain](https://en.wikipedia.org/wiki/Risk_of_Rain)。アイテムが積み重なり「か弱い生存者が画面を一掃する肉挽き機になる」雪だるま型（レビュー評）— [Vice](https://vice.com/en/article/7xgvbz/risk-of-rain-2-makes-you-a-force-of-nature), [GameGeeker](https://gamegeeker.com/games/2-632360/review?market=DE)
- **Vampire Survivors（Luca Galante）**: Castlevania DLC について「It's still crazy, still unbalanced, but different」と、意図的な非バランスを自認 — [Pocket Tactics](https://www.pockettactics.com/vampire-survivors/interview)。プレイヤーの「動かない縛り」から Peppino のギミックを作るなど、プレイヤーの遊び方を公式化 — [Game Developer](https://www.gamedeveloper.com/design/vampire-survivors-development-sounds-like-an-open-source-fueled-fever-dream)
- **Brotato**: 1人開発（Blobfish / Thomas Gervraud）、ウェーブ20〜90秒の短い反復 — [Wikipedia](https://en.wikipedia.org/wiki/Brotato), [1.0 プレスリリース](https://gamespress.westeu-v2.propressroom.com/es/Brotato-10-Release)。Danger レベルとは別にアクセシビリティ扱いの難易度スライダーがある（プレイヤー解説）— [Steam Discussions](https://steamcommunity.com/app/1942280/discussions/0/3810657379788919419)
- **20 Minutes Till Dawn**: 「Darkness」段階（最大15）で自分弱体/敵強化 — [Wikipedia](https://en.wikipedia.org/wiki/20_Minutes_Till_Dawn)
- **Megabonk**: レビュアーは壊れビルドをハイライトとして評価しつつ、難易度スパイクを批判 — [Wikipedia](https://en.wikipedia.org/wiki/Megabonk)
- **Monster Train 等の論考**: 上級者は「massively broken builds」で全戦闘を吹き飛ばすが、焦点が「カードバトル」から「カード構築」だけに移る懸念、敵は同じ壊れ道具を使えないためバランスが難しい（Thinky Games、検索要約・本文403）— [Thinky Games](https://thinkygames.com/features/great-deckbuilders-break-the-rules/)
- 出力ランダム（ミス判定等）はエージェンシー欠如感を生み、入力ランダム＋決定論的解決は失敗を戦略のせいにできる（論考）— [Playbattlesquare](https://playbattlesquare.com/latest/rng-vs-skill-why-roguelike-deckbuilders-are-taking-over/)。カード数が増えるほど選択肢は増えるが一貫性は落ち、生のカードパワーより一貫性が重要、カード除去とデッキサイズ管理が中核判断（ガイド）— [Gunslinger's Revenge](https://www.gunslingersrevenge.com/posts/deckbuilders/roguelike-deckbuilder-mechanics-explained.html)

### Inferences
- 「壊れる自由」と「挑戦」は同一軸で調整すると衝突する（StS2 の炎上）。別軸（opt-in 難度レイヤー／時間・アンテのエスカレート／最終キルスクリーン）に分けると両立する。
- Balatro は「無限を潰す」のではなく「どこまでも数字が伸びた末に計算機が壊れる」を**ゴールの演出**にした。壊れること自体が報酬になっている。
- Hades の God Mode は「ズル感」を避けつつ救済する設計（死ぬたびに少しずつ強く＝努力が蓄積する変動報酬）。

### Gaps
- Brotato 開発者自身の難易度哲学の発言は見つからず。
- Monster Train（Shiny Shoe）の Covenant 設計意図の一次発言は未取得。
- Derek Yu（Spelunky）の関連発言は今回未調査。
- RoR2 の開発者による「パワーファンタジー」意図の直接引用は見つからず（レビュー評のみ）。

## Q4. 日本語コミュニティの StS2 難易度評価

### Takeaway
日本語圏でも「前作より難化」「運要素が大きい」が主流の印象だが、「強いカードが多く上手く組めれば1より易化」「ぶっ壊れ探しが楽しい」という肯定的な受け止めもある。調整のたびに難しくなるという不満も見られる。

### Cited Findings
- Yahoo!知恵袋: プレイ10時間で2章もクリアできないという質問に「このゲームは実際相当難しい」と回答。ボス・マップ・報酬のランダム性で運要素が大きいとの指摘 — [Yahoo!知恵袋](https://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q11326237076)
- Game8 レビュー: 前作経験者には迷わず勧められるが、攻守2リソースを同時管理する感覚は慣れるまで難しい。コメント欄に「調整のたびに難易度が上がり、最初が一番楽しかったゲームと化している」という不満（コメント、検索要約）— [ゲームエイト](https://game8.jp/steam/768073)
- 個人ブログ: 敵が強くなり難化した一方、強いカードが多くデッキを上手く組めれば1より易化。前作でアセンション1まで経験してから遊ぶのがおすすめ — [余白（はてなブログ）](https://umimozuku.hatenablog.com/entry/2026/03/13/015050), [ぼくとRPGのあいだに](https://baykersan.hatenadiary.jp/entry/2026/03/10/082938)
- まとめ記事タイトル「【スレイザスパイア2雑談】ぶっ壊れ探すのが楽しいね。」(2026/3/8) — [gamemos](https://gamemos.net/2026/03/08/post-138732/)（本文未精読）
- レビュー爆撃は主に中国地域（簡体字）からで、日本語圏が爆撃の主体だった証拠は見当たらず — [Wikipedia](https://en.wikipedia.org/wiki/Slay_the_Spire_II)

### Inferences
- 日本語圏でも「ぶっ壊れ発見の快感」が語られており、爽快感は前作から引き継がれた期待値。

### Gaps
- 5ch / X の生の声、note 記事、4Gamer / ファミ通の難易度言及は今回取得できず。Steam 日本語レビューの比率も未確認。

## Q5. 爽快感を守るための設計原則（インディー StS ライク向け）

### Takeaway
「壊れる自由」は残し、挑戦は別レイヤーで提供する。潰すなら上を削るより下を引き上げ、救済はプレイヤー側を少しずつ強くする形で行う。

### Cited Findings（原則と根拠）
1. **壊れコンボは「稀な当たり」として残し、潰さない。** 無限/壊れはプレイヤーにとって高難度への正当な解答であり、潰すと「選択肢を奪われた」と受け取られる（StS2 v0.100.0 で1日数千〜1万件の否定レビュー、v0.101.0 で撤回）— [TheGamer](https://www.thegamer.com/slay-the-spire-2-review-bombed-balance-changes/), [Notebookcheck](https://www.notebookcheck.com/Slay-the-Spire-2-zieht-Reissleine-Neuer-Patch-nimmt-kritisierte-AEnderungen-zurueck.1261216.0.html)。StS1 でも「毎回組めたら問題、稀に組めるのが楽しい」との合意 — [earlyguides](https://earlyguides.com/slay-the-spire/builds)
2. **「強すぎ」より「他が弱すぎ」を先に疑う＝下を引き上げる。** 「使われすぎるのは強いからでなく他が弱いから」— [TheGamer](https://www.thegamer.com/slay-the-spire-2-review-bombed-balance-changes/)。Mega Crit 自身も後に弱カードの強化と「全カードを viable に」へ — [GamesRadar](https://www.gamesradar.com/games/roguelike/new-slay-the-spire-2-patch-makes-some-terrible-cards-and-relics-actually-good-mega-crit-agrees-the-game-is-quite-hard-and-wants-lower-ascensions-to-be-more-accessible/), [Neowsletter 4月](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/)
3. **壊れの問題は「強さ」ではなく「他の楽しさを締め出すか」で判定する。** LocalThunk「overpowered in a way that excludes the player from experiencing other fun」が問題、想定外コンボの発見は emergent さの証 — [Game Informer](https://gameinformer.com/interview/2024/03/21/balatro-was-almost-called-joker-poker-and-other-details-from-its-creator)
4. **ベース難易度は低く、挑戦は opt-in の段階制に分離する。** StS2 は A0 が「quite hard」で炎上→低アセンションを緩和し高アセンションを強化 — [eTeknix](https://www.eteknix.com/slay-the-spire-2-difficulty-rebalanced-in-latest-beta-patch/)。Balatro の Stakes、Hades の Heat、20MTD の Darkness も同型 — [Wikipedia: Balatro](https://en.wikipedia.org/wiki/Balatro), [Wikipedia: Hades](https://en.wikipedia.org/wiki/Hades_(video_game)), [Wikipedia: 20MTD](https://en.wikipedia.org/wiki/20_Minutes_Till_Dawn)
5. **救済は「敵を弱く」でなく「自分が少しずつ強くなる」形で。** Hades God Mode: 死ぬたび+2%耐性、「What if we just make you a little bit tougher?」— [Inverse](https://www.inverse.com/gaming/hades-god-mode-interview)
6. **天井は「潰す」でなく「敵側のエスカレート／演出的な終点」で作る。** Balatro の naneinf キルスクリーン（数字が壊れること自体がゴール）、RoR2 の時間スケーリング — [Wikipedia: Balatro](https://en.wikipedia.org/wiki/Balatro), [RoR2 wiki](https://riskofrain2.wiki.gg/wiki/Difficulty)。逆に Mega Crit は「長いランほど構築がつまらない」とエンドレスに否定的で、この点は設計判断として対立軸になる — [Neowsletter 4月](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/)
7. **防御・一貫性ツールを確保し「運負け」を減らす。** 「A10 は賢い判断より運」「Ironclad/Regent でブロックカードが何戦も出ない」— [Steam A10 スレ](https://steamcommunity.com/app/2868840/discussions/0/798966340583124298/)。生のパワーより一貫性、カード除去・デッキサイズ管理が中核 — [Gunslinger's Revenge](https://www.gunslingersrevenge.com/posts/deckbuilders/roguelike-deckbuilder-mechanics-explained.html)
8. **序盤の被ダメージスパイクを抑え、最初の数戦は「強くなる感覚」を先に与える。** EA初期の不満は Act1（3階で26ダメージ、Steam 敵の40+）に集中、Mega Crit も Act1 敵を低難度で弱体化 — [Steam 難易度スレ](https://steamcommunity.com/app/2868840/discussions/0/798965575663498393/), [eTeknix](https://www.eteknix.com/slay-the-spire-2-difficulty-rebalanced-in-latest-beta-patch/)
9. **ランダムは「入力側」に置き、結果は決定論的に。** 失敗を自分の判断に帰属できるとエージェンシーが保たれる — [Playbattlesquare](https://playbattlesquare.com/latest/rng-vs-skill-why-roguelike-deckbuilders-are-taking-over/)
10. **バランス変更はベータで段階的に、公開して撤回できる体制で。** Mega Crit「No change is necessarily permanent」「Progress will not be linear」、ベータブランチで実験 — [PC Gamer](https://www.pcgamer.com/games/card-games/mega-crit-responds-to-the-panic-over-slay-the-spire-2s-1st-balance-pass-saying-these-changes-are-the-first-of-many-no-change-is-necessarily-permanent/), [sts2front](https://www.sts2front.com/tips/v0101-patch-revert-analysis/), [Neowsletter 4月](https://www.megacrit.com/news/2026-4-17-neowsletter-issue-21/)

### Inferences
- Mega Crit の「deckbuilding rather than cardbuilding」（単一カードの雪だるま抑制）— [Neowsletter 8月](https://www.megacrit.com/news/2026-8-14-neowsletter-issue-25/) — は戦略深度を守る正当な美学だが、「爽快感ファースト」の StS ライクを作るなら、**あえて逆張りして「1枚を育てて壊す」体験を主役にする余地**がある（StS2 との差別化ポイントになりうる）。ただし原則3の「他の楽しさを締め出さない」チェックとセットで。
- 「難しいから壊れに頼る → 壊れを潰す」の連鎖を避けるには、敵数値を上げる前にプレイヤー側の上振れ天井を決め、両者を別々に調整するのが安全。

### Gaps
- これらの原則を定量検証した研究（離脱率・継続率と難易度の関係など）は見つからず。原則はケーススタディと開発者発言からの帰納。
