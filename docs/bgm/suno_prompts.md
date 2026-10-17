# OpenSlayThe BGM 用 Suno プロンプト集

調べた日: 2026-10-18。対象は Suno の **v6 世代（v6 / v6-wild / v6-mini）**。
Style / Lyrics に貼る文章は**英語**（解説は日本語）。英語のほうが効くという公式の記述は確認できなかったが、調べた公式ヘルプ・解説記事はすべて英語のプロンプトで書かれているので、英語に統一している。

---

## 1. 調べてわかったこと

### 1-1. モデル（いちばん大事な変化）

- **2026-09-09 に v6 世代が出て、v4〜v5.5 は廃止された**。新しい曲を作れるのは v6 / v6-wild / v6-mini だけ。
  - v6: 旗艦。Pro / Premier 向け。「狙った音が決まっているとき」向き。
  - v6-wild: Pro / Premier 向け。予測しにくく、実験的。アイデア出し用。
  - v6-mini: 無料でも使える軽量版。
  - 1回の生成は最大 **8分**。1回で 2曲が出て **10 クレジット**。
  - 出典: https://help.suno.com/en/articles/13924737 、https://help.suno.com/en/articles/13924801 、https://help.suno.com/en/articles/13924481 、https://suno.com/blog/introducing-v6
- 以前の v5.5 向けの記事（Web 上に多い）は、モデル名が古いだけで基本の書き方は同じだが、「v5.5 の癖」の話は当てにしないこと。
- 画面は Create の右上のドロップダウンでモデルを選ぶ（出典: 上の 13924801）。

### 1-2. Style（Style of Music）欄

| 項目 | わかったこと | 出典 |
|---|---|---|
| 文字数の上限 | **約 1000 文字**（v4.5 以降。v4 以前は約 200）。**Suno 公式ヘルプには数字が載っていない**。解説サイトが画面のカウンタ（0/1000）から読み取った値。超えた分は警告なしで切り捨てられるという報告あり | https://hookgenius.app/learn/suno-custom-mode-guide/ 、https://aimusicapi.ai/en/blog/suno-ai-prompt-character-limits 、Suno API 文書（style 1000 / lyrics 5000 / negativeTags 1000）https://docs.sunoapi.org/suno-api/generate-music |
| 効く言葉 | ジャンル → テンポ/エネルギー → 主な楽器 → 雰囲気 → 音の質感、の順。4〜7 個の言葉に絞る。先に書いた言葉ほど重い。BPM は目安（メトロノームのように固定されない） | https://blakecrosley.com/guides/suno |
| アーティスト名 | 使わない（公式の「禁止」文言は今回確認できず。解説記事は「避ける」と推奨）。音の特徴の言葉に置き換える | 同上 |
| 否定表現 | Style 欄の中で "no drums" のように書くのは不安定。専用の Exclude 欄を使う | 同上、https://jackrighteous.com/en-us/blogs/guides-using-suno-ai-music-creation/advanced-suno-prompt-engineering-guide |

### 1-3. Exclude（除外）

- **Custom モードの Advanced Options の先頭にある「Exclude」欄**に、入れたくない楽器やスタイルを書く。
  出典（公式）: https://help.suno.com/en/articles/3161921
- 公式ヘルプには文字数上限の記載なし。Suno API 文書では 1000 文字（negativeTags）。
- メイン方向と矛盾する内容を入れない（解説記事の注意）。
- 構造（長いイントロなど）を Exclude で消せるかは**確認できなかった**。楽器・ボーカルを消す用途で使う。

### 1-4. スライダー（Create の詳細設定）

- **Weirdness**: Safe〜Chaos。50% が「普通」。**Style Influence**: Loose〜Strong。入力した Style にどれだけ従うか。**Audio Influence**: 音源アップロード時だけ出る。（公式: https://help.suno.com/en/articles/6141377 ）
- **Variety（v6 で追加）**: Style を Suno が自動で書き換えて幅を出す。**0 にすると自分の Style タグをそのまま使う**。（公式: https://help.suno.com/en/articles/13924481 ）
- どのスライダーが v6 で何%が既定かは公式に数字がない。この文書の推奨値は「1曲ずつ試して調整する出発点」。
- **Max Mode**: 追加クレジットで品質を上げるモード。2分超の曲、スタイル維持に推奨。追加クレジット量は公式 FAQ に数字なし。（同上 13924481）

### 1-5. Lyrics 欄（インスト）

- 公式ヘルプには「Instrumental トグル」の説明、角括弧タグの一覧、Lyrics の文字数上限は**見つからなかった**。
- 解説記事（v5.5 向け）: Custom モードで **Instrumental** をオンにし、さらに Lyrics 欄にも `[Instrumental]` を入れて構造を補強する。Style 欄だけが創作の入力になるので Style を詳しく書く。（https://blakecrosley.com/guides/suno ）
- トグルの正確なラベルは確認できなかった。Web 版は "Advanced"、iOS は "Custom" という報告（https://hookgenius.app/learn/suno-custom-mode-guide/ ）。**実際の画面を見て、Instrumental のスイッチを探すこと**。
- 歌詞欄の上限は約 5000 文字（解説サイトの報告。公式の数字なし）。
- 効くタグ（解説記事ベース。公式の保証なし）:
  - 構造: `[Intro]` `[Verse]` `[Chorus]` `[Bridge]` `[Build]` `[Drop]` `[Instrumental]` `[Instrumental Break]` `[Outro]` `[End]`
  - `[Verse: whispered vocals, acoustic guitar only]` のように **コロンの後に短い指示**を書ける。
  - `[End]` は「ここで止める」（余計な末尾を防ぐ）、`[Outro]` はエネルギーを落とす。`[Fade Out]` は徐々に小さくする。**ループ用には `[Fade Out]` は使わない**。
  - 出典: https://blakecrosley.com/guides/suno 、https://james-palm.medium.com/stop-wasting-your-credits-the-ultimate-guide-to-suno-ai-metatags-verse-chorus-and-drop-57e209a0e5d8
- ゲーム用の「loopable / seamless loop / no intro, no outro」を Style に書く方法が紹介されているが、**効く証拠はなく、完全なループにはならない**と同じ記事が書いている。DAW で切るのが前提。
  出典: https://hookgenius.app/learn/suno-for-game-developers/ 、https://sunodownloader.ai/blog/how-to-loop-a-song

### 1-6. 関連機能（このプロジェクトでの使い道）

| 機能 | 内容 | 使い道 | 出典 |
|---|---|---|---|
| Extend | 曲の続きを作る。「Get Whole Song」で全体に結合 | 長さが足りないとき | https://help.suno.com/en/articles/2409601 |
| Song Editor（Replace / Crop / Fade） | 区間の差し替え、不要部分の削除、フェード | 変な区間だけ直す。**ループ機能はない** | https://help.suno.com/en/articles/6141505 |
| Cover | **自分が作った曲**の旋律を保ったまま別スタイルにする（Beta、Pro / Premier）。最初の生成は無料と書かれている | 共通モチーフを他の曲へ持ち込む | https://help.suno.com/en/articles/2872257 |
| Personas | 曲の「らしさ」を保存。Custom モードで選ぶと Style 欄が自動で埋まる。**インスト曲で効くかは公式に記載なし**。既定は公開なので非公開に切り替える | 試す価値はあるが保証なし | https://help.suno.com/en/articles/3484161 |
| Get Stems | Pro / Premier。Auto Split は最大 12 本で 50 クレジット。Split from Mix は 1 本 10 クレジット | 音楽の層に分けてゲーム内で重ねる（任意） | https://help.suno.com/en/articles/13925185 |
| ダウンロード形式 | MP3 は全プラン、**WAV は Pro / Premier**。ステムは曲のダウンロードに含まれ、別カウントにならない。MIDI は Suno Studio の曲を Premier のみ | ループ編集用に WAV | https://help.suno.com/en/articles/13926081 |
| Custom Models | 自分の曲で調整したモデル（解説記事では 6 曲以上が必要）。プラン条件は確認できず | 全曲が揃ったあと、追加曲を同じ音で作るとき | https://help.suno.com/en/articles/11362497 （未読。名前のみ確認）、https://blakecrosley.com/guides/suno |
| Suno Sounds の Loop | 単発の音源・ループ素材を作る（BPM / キー指定可）。完全な曲ではなく、フルアレンジが入ることもある | 環境音のレイヤーなど（任意） | https://help.suno.com/en/articles/10625537 |

### 1-7. 商用利用（Steam で売るゲームに使えるか）

**結論: 有料プラン（Pro / Premier）で作り、その有料期間中にダウンロードした曲は、ゲームでの商用利用ができる。ただし条件が 4 つある。**

1. **有料プラン中に作った曲だけ**。無料プランで作った曲は非商用で、あとで課金しても自動では商用にならない（再取得は個別救済のみ）。
   - https://help.suno.com/en/articles/9601665 （有料プランの権利。「video games」での利用が明記されている）
   - https://help.suno.com/en/articles/2425729 （課金前に作った曲の扱い）
2. **ダウンロードした曲だけ**。2026-09-03 から発効の利用規約で、「承認された経路でダウンロードしていない Output は商用利用できない」。月のダウンロード枠は Pro 20 / Premier 60（Suno Studio 付きの Premier は無制限）。トライアルのダウンロードは**非商用**。
   - https://suno.com/terms （Effective September 3, 2026）
   - https://suno.com/blog/suno-updates-tos 、https://help.suno.com/en/articles/13876865
   - 1曲=1ダウンロード。**MP3 と WAV を両方取っても、ステムを取っても 1 回分**。再ダウンロードは消費しない。（https://help.suno.com/en/articles/13926145 ）
   - 一度商用権が付いたダウンロードは、枠を使い切っても、解約しても失われない（規約の文言）。
3. **著作権は保証されない**。権利（所有）と、法的な著作権保護は別。規約に "no representation ... that any copyright will vest in any Output" とある。人間が作っていない曲は米国では保護されにくいという説明が公式ヘルプにある。（https://help.suno.com/en/articles/2746945 ）
4. **Cover / Remix**: 他人の曲のリミックスは商用不可。**自分の曲（有料中に作ってダウンロード済み）のリミックスは商用になりうる**と公式ヘルプ。ただし「Cover」の扱いを明記した記述は見つからなかった。（https://help.suno.com/en/articles/9604993 ）
   - → 安全策: Cover を使った曲も、**有料プラン中に作った自分の曲を元にして、ダウンロードする**。

**確認できなかったこと**: Steam 側の規約と、Steam の AI 生成コンテンツの開示ルールは今回調べていない。公式ヘルプ（配信の記事 https://help.suno.com/en/articles/2410177 ）は「ゲーム」「Steam」「AI 開示」に触れていなかった。Steam への提出前に Steam のルールを別途確認すること。

**運用上の注意**: Pro は月 20 ダウンロード。8 曲だけなら足りるが、聞き比べでむやみにダウンロードしない。**聞くだけなら Suno 上で再生し、ダウンロードは最終版 1 回だけ**にする。

---

## 2. 全曲共通の音作り

### 2-1. 世界観の音（共通パレット）

| 要素 | 内容 |
|---|---|
| 土台 | シネマティックなファンタジー・オーケストラ（弦、フレンチホルン、木管） |
| 森 | 木のフルート、ニッケルハルパ（弓で弾く民族楽器）、ハーディガーディ、ドローン |
| 機械 | チェレスタ・オルゴールの「カチカチ」、真鍮の歯車の金属打楽器、金床 |
| ドラゴン | 太いホルンと低いブラス、太鼓（タイコ）、Boss では歌詞なしの合唱 |
| 調 | **D マイナーを中心**に全曲を回す（Rest だけ同主調の D メジャー） |
| 避けるもの | チップチューン、8bit、EDM のドロップ、ボーカル |

### 2-2. 共通モチーフ

- **「ドラゴンの呼び声」**: D マイナーで **D → F → A → G、そして D に落ちる**（短・短・長・やさしく下りて着地）。
  - 基本はホルン。Event では歪めたオルゴール、Rest では木のフルート、Boss では合唱と全ブラス。
- もう一つの共通要素: **8分音符の歯車のカチカチ**（チェレスタ/オルゴール）が、全曲の背景のどこかで鳴り続ける。

### 2-3. 強度の段階

| 曲 | BPM | 調 | 強度 |
|---|---|---|---|
| Lobby | 78 | D minor | 壮大・静か |
| Map | 96 | D Dorian | 旅 |
| Event | 72 | D minor（怪しい） | 疎ら |
| Normal | 120 | D minor | 中 |
| **Elite** | **138** | D minor + ♭2 | 強 |
| **Boss** | **152** | D minor | 最大 |
| Rest | 66 | D major | 休息 |
| Shop | 108（3拍子） | D Dorian | 軽妙 |

### 2-4. Suno で一貫性を保つ具体的な手順

1. **共通の核の文を毎回 Style の頭に近い位置へ入れる**（下の各曲のプロンプトにすでに入っている）。核:
   `cinematic fantasy orchestral, French horn, cello, wooden flute, nyckelharpa, celesta and music box clockwork ticks, brass gear percussion, ancient overgrown forest with clockwork machinery`
2. **モデルは v6 で固定**。スライダーも全曲同じ出発点にする（Variety 0、Style Influence 75 前後、Weirdness 35〜45 前後）。1曲ごとに 1 つずつだけ動かす。
3. **最初に Lobby を作り込む**（4〜6 回生成）。モチーフ（ホルンの 4 音）がいちばんはっきりした 1 曲を選ぶ。
4. **Normal → Elite → Boss は、まず文章だけで作る**。モチーフが出なければ、選んだ Lobby（または Normal）を元に **Cover** して Style だけ各曲の文に替える（Cover は旋律を保つ。Pro / Premier、自分の曲のみ）。
   - Cover は「旋律ごと同じ」になりやすいので、**全曲 Cover にしない**。Normal と Elite と Boss（モチーフを聞かせたい曲）に絞る。Audio Influence の効き方は公式に説明がないので、低め→高めで試す。
5. 気に入った曲があれば **Persona を作ってみる**（非公開）。Style が自動で埋まる。インストで効くかは未確認なので、効かなければやめる。
6. 8 曲が揃い、同じ音で足りない曲が出たら、**Custom Models**（自分の曲で調整）を試す。
7. 採用テイクの Style 文と設定を、このファイルの該当曲の下にメモしておく（再現用）。

---

## 3. 曲ごとのプロンプト

共通の設定（特記なければ）: **モデル v6 / Custom モード / Instrumental オン / Variety 0 / Style Influence 75 / Weirdness 40 / Max Mode オフ（モチーフが出ないときだけオン）**。
Style の長さはすべて 1000 文字以内（約 450〜600 文字）に収めてある。
Exclude 欄は共通で `vocals, singing, lyrics, chiptune, 8-bit, EDM drop, trap hi-hats, fade out` を基本にする（曲ごとに追加）。

### 3-1. Lobby / タイトル画面

- 用途とねらい: 最初に聞く曲。森と歯車、ドラゴンの呼び声（モチーフ）を印象づける。静かで壮大。
- BPM / キー: 78 BPM / D minor
- Style:
```
epic cinematic fantasy orchestral theme, majestic and wistful, 78 BPM, D minor, solo French horn plays a heroic four-note rising theme, warm cellos and violas, wooden flute, nyckelharpa drone, celesta and music box clockwork ticking in steady eighth notes, brass gear percussion, deep taiko, ancient overgrown forest with clockwork machinery, steady energy, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: solo French horn states the theme over soft clockwork ticks, 2 bars]
[Verse: theme in cellos and flute, steady taiko pulse]
[Chorus: full orchestra with French horns, warm and majestic, same tempo]
[Instrumental Break: nyckelharpa and music box, quiet]
[Chorus: full orchestra, same energy]
[End]
```
- 設定: 上の共通設定。Weirdness 35。
- Exclude: 共通の行 + `, drum kit solo`

### 3-2. Map / 次の部屋を選ぶ

- 用途とねらい: 長時間流れる。落ち着きつつ冒険の気配。あまり目立たず、飽きない。
- BPM / キー: 96 BPM / D Dorian（D minor に明るい 6 度）
- Style:
```
calm adventurous fantasy travel music, light and airy, 96 BPM, D Dorian, fingerpicked acoustic harp and nylon guitar, wooden flute melody, light strings, nyckelharpa and hurdy-gurdy, celesta and music box clockwork ticks, soft brass gear percussion, gentle French horn echoes the four-note theme, ancient overgrown forest with clockwork machinery, steady and unobtrusive, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: fingerpicked harp and soft clockwork ticks, already in tempo, 2 bars]
[Verse: wooden flute melody over light strings, gentle walking rhythm]
[Instrumental Break: hurdy-gurdy and nyckelharpa, same energy]
[Verse: French horn echoes the theme, strings add warmth]
[Outro: same energy, no slowdown]
[End]
```
- 設定: Weirdness 35、Style Influence 70。
- Exclude: 共通の行 + `, heavy drums, epic climax, big brass`

### 3-3. Event / 「?」の部屋

- 用途とねらい: 好奇心と、ちょっと不気味。何かが起きる前の静けさ。
- BPM / キー: 72 BPM / D minor
- Style:
```
curious mysterious fantasy underscore, slightly uncanny, 72 BPM, D minor, detuned music box and celesta play a distorted version of the four-note theme, glass harmonica, bowed nyckelharpa, low cello drone, wooden flute whispers, slow irregular clockwork ticking, brass gear clicks, ancient overgrown forest with clockwork machinery, sparse and spacious, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: music box melody and slow clockwork ticks, 2 bars]
[Verse: detuned celesta theme, low cello drone, sparse]
[Instrumental Break: glass harmonica swells, quiet brass gear clicks]
[Verse: theme returns on wooden flute, slightly off-key, uncanny]
[End]
```
- 設定: Weirdness **50〜55**（少し不気味にしたい）。出来が単調なら v6-wild も試す。
- Exclude: 共通の行 + `, drum kit, heavy percussion, full orchestra, major key cheerful`

### 3-4. Normal combat / 通常戦闘

- 用途とねらい: 毎戦聞く曲。リズム主体で、効果音の邪魔をしない。
- BPM / キー: 120 BPM / D minor
- Style:
```
driving fantasy battle orchestral, tense and heroic, 120 BPM, D minor, steady pulsing cello and low strings ostinato, taiko and brass gear anvil percussion on the beat, French horn plays the four-note theme, celesta and music box clockwork ticks, nyckelharpa rhythm, ancient overgrown forest with clockwork machinery, uncluttered mix with space for sound effects, mid-range focused, repeating groove, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: ostinato and taiko already playing, 2 bars]
[Verse: low strings ostinato, French horn theme, steady groove]
[Chorus: brass joins, same tempo, not too busy]
[Instrumental Break: clockwork percussion and nyckelharpa, sparse]
[Verse: theme returns, steady groove]
[End]
```
- 設定: Weirdness 35、Style Influence 75。
- Exclude: 共通の行 + `, dense cymbals, busy arpeggios, big choir, guitar solo`

### 3-5. Elite combat / エリート戦

- 用途とねらい: 明らかに Normal より危険。テンポを上げ、暗さ（♭2）と金属音を強める。
- BPM / キー: 138 BPM / D minor（♭2 の E♭ で緊張）
- Style:
```
dangerous dark fantasy battle orchestral, menacing and relentless, 138 BPM, D minor with phrygian flat second, aggressive low brass and French horns state the four-note theme, pounding taiko and heavy brass gear anvil percussion, fast staccato strings ostinato, grinding hurdy-gurdy, celesta clockwork ticks speeding up, ancient overgrown forest with clockwork machinery, driving and intense but uncluttered mix with space for sound effects, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: staccato strings and anvil hits already in tempo, 2 bars]
[Verse: low brass theme, fast string ostinato, menacing]
[Chorus: full brass and taiko, heavier than before, same tempo]
[Instrumental Break: clockwork grinding, bass drum pulse, tense]
[Chorus: heavier variation, same tempo]
[End]
```
- 設定: Weirdness 35、Style Influence 80。
- Exclude: 共通の行 + `, cheerful, light flute melody, slow tempo, guitar solo`

### 3-6. Boss combat / ボス戦

- 用途とねらい: クライマックス。最大の編成と強さ。歌詞なしの合唱とドラゴンの咆哮のような低いブラス。
- BPM / キー: 152 BPM / D minor
- Style:
```
epic climactic fantasy boss battle orchestral, massive and relentless, 152 BPM, D minor, wordless choir chants the four-note dragon theme, roaring low brass and French horn section, thunderous taiko and metallic gear anvil percussion, fast driving string ostinato, pipe organ, celesta and music box clockwork ticks at double speed, ancient overgrown forest with clockwork machinery, the biggest and most intense track, sustained high energy, space left in the mix for sound effects, seamless loop, instrumental, wordless choir only
```
- Lyrics:
```
[Instrumental]
[Intro: choir and brass already at full energy, 2 bars]
[Verse: low brass theme, driving strings, taiko]
[Chorus: wordless choir sings the theme, full orchestra, maximum energy, same tempo]
[Instrumental Break: gear percussion and organ, tense but steady]
[Chorus: choir and full brass, biggest version, same tempo]
[End]
```
- 設定: Weirdness 35、Style Influence 80。**Max Mode をオン推奨**（合唱込みで長めの曲のスタイルを保つため。追加クレジットは公式に数字なし）。
- Exclude: 共通の行 のうち `vocals, singing, lyrics` は外し、代わりに `lyrics, words, spoken word, solo singer, rap` を入れる（歌詞なし合唱は残すため）。+ `, slow tempo, gentle`
- 注意: 合唱が「言葉を歌う」ようなら、Exclude に `English words` を足す。それでも出るなら合唱を外す。

### 3-7. Rest site / 焚き火

- 用途とねらい: 戦闘の緊張が解ける。同じモチーフを、暖かい D メジャーで静かに聞かせる。
- BPM / キー: 66 BPM / D major（同主調）
- Style:
```
warm peaceful campfire fantasy lullaby, gentle and hopeful, 66 BPM, D major, wooden flute plays the four-note theme in major, fingerpicked nylon guitar and harp, soft cello pad, warm French horn, music box and celesta ticking softly like a clock by the fire, faint crackling embers, ancient overgrown forest with clockwork machinery at night, calm steady, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: fingerpicked guitar and soft music box, already in tempo, 2 bars]
[Verse: wooden flute theme in major, harp arpeggios]
[Instrumental Break: cello pad and music box, very quiet]
[Verse: French horn joins gently, same energy]
[End]
```
- 設定: Weirdness 30。
- Exclude: 共通の行 + `, drums, taiko, brass stabs, dark, minor key, tension`

### 3-8. Shop / 商人

- 用途とねらい: 機械仕掛けの行商人。軽妙で少しコミカル、長居しても疲れない。
- BPM / キー: 108 BPM（3拍子のワルツ） / D Dorian
- Style:
```
whimsical clockwork fantasy merchant waltz, playful and charming, 108 BPM, 3/4 time, D Dorian, pizzicato strings, celesta and music box, accordion-like hurdy-gurdy, plucked harp, bassoon, wooden flute plays a playful version of the four-note theme, brass gear and cash-register-like metallic percussion, ticking clockwork, ancient overgrown forest with clockwork machinery, light and unobtrusive, steady, seamless loop, instrumental
```
- Lyrics:
```
[Instrumental]
[Intro: pizzicato strings and clockwork ticks, already in tempo, 2 bars]
[Verse: playful flute theme over waltz rhythm, bassoon bass]
[Instrumental Break: celesta and hurdy-gurdy, light]
[Verse: strings and harp, same energy]
[End]
```
- 設定: Weirdness 40。3拍子にならないときは、Style の `3/4 time` を `waltz rhythm, one-two-three` に替えて再生成。
- Exclude: 共通の行 + `, heavy drums, epic brass, choir, dark`

---

## 4. 生成後のチェックとループ処理

### 4-1. いいテイクの選び方

1. **最初の 1 小節目から曲のエネルギーが出ている**（長いイントロがない）。
2. **ボーカルが混じっていない**（口笛、ハミング、"fake vocals" に注意）。
3. **テンポが途中で揺れたり、突然の盛り上がり/静かな部分がない**。
4. **戦闘曲は中域が混み合っていない**（効果音の上に載る高音のきらきらや、ずっと大きいシンバルがない）。
5. Elite は Normal より、Boss は Elite より、体感ではっきり強いか。3 曲を続けて聞き比べる。
6. 全曲を並べて、モチーフ（D-F-A-G）が聞き取れるか。

### 4-2. 保存

- **ダウンロードは最終テイクだけ**（1曲=1回分、MP3 と WAV は同じ 1 回分）。聞き比べは Suno 上で。
- 編集用は **WAV**（Pro / Premier）。ゲームに入れる最終は OGG Vorbis（128〜192 kbps が目安という解説記事あり、出典: https://hookgenius.app/learn/suno-for-game-developers/ ）。Godot は OGG のループ設定が使える。

### 4-3. きれいなループの作り方（短く）

1. 波形編集ソフト（Audacity、Reaper など）で WAV を開く。テンポが一定なので、**小節の頭（強拍）で切る**。曲の真ん中の、2 回目の繰り返し部分を使うのが安全。
2. 「小節 N の頭 → 小節 N+8 または +16 の頭」を、ループ範囲にする。テンポは BPM から 1 小節の長さ = 60 / BPM × 4 秒で計算できる（Suno の BPM は目安なので、実際の波形で確認する）。
3. 切ったあと、ループをつなぎ目で 5 回ほど続けて再生し、クリック、リズムのつっかかり、リバーブの切れ目を確認する。
4. 切れ目で音が途切れるなら、末尾の余韻を冒頭に 0.1〜0.5 秒かぶせる（クロスフェード）。
5. 完全に途中で切るのが難しければ、**ゲーム側で OGG のループ開始/終了サンプルを指定**する。
6. ループがうまくいかない曲は、Song Editor で不要な区間を Crop するか、Extend で 2 周目の A パートだけ増やす。

---

## 5. 確認できなかったこと（まとめ）

- Style 欄 1000 文字は**公式には未掲載**（解説サイトが画面のカウンタから読み取った値）。Exclude の 1000 文字も API 文書のみ。
- v6 の画面での Instrumental トグルのラベルと位置、Lyrics 欄で角括弧タグが v6 でも v5.5 と同じに効くかどうか。
- Weirdness / Style Influence / Variety の既定値と、v6 での効き方の細かい数字。
- Personas がインスト曲で効くか、Cover のコマーシャル上の扱い（Remix は明記あり、Cover は明記なし）。
- Steam の AI 開示ルール（調べていない）。
- 「loopable」「no intro, no outro」の Style 書きが実際に効くか（効く証拠なし）。
