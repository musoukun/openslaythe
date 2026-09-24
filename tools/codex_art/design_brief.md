# Codex への依頼: アートディレクションと全アセットのデザイン

あなたはこのゲームのアートディレクター兼 VFX デザイナーです。
Slay the Spire 風デッキ構築ローグライク (Godot 4.6, 画面 1200x700 固定) のビジュアルを **ゼロから独自に** 設計してください。
実装は別のエンジニア (Claude Code) が行います。あなたは **設計ファイルを書くだけ** で、画像生成はまだしないでください。

## ゲームの前提 (変更不可)
- プレイヤーキャラ: **The Botanist** — 実験のせいでクビになった「熱核植物学者」。植物 × 原子炉がテーマ。
- メカニクス: Overshield(余剰シールド), Pointy(トゲ反撃), Overheat(過熱→自爆ダメージ系), Waste(放射性廃棄物カード), Pollen, Photosynthesis など。
- 敵は「ロボット」系 (フレームワーク名が Slay the Robot)。敵の名前・見た目はあなたが自由に決めてよい。
- 開発方針は「面白さファースト」: 10秒で人に見せたくなる、ちょっとくだらなくて愛嬌のある世界観が良い。
- Slay the Spire のアートや固有名詞を模倣しないこと (オリジナルであること)。
- 画像内に文字・数字・ロゴは入れない (ゲーム側で描画する)。

## 入力
- `tools/codex_art/slots.json` : 作るべき画像の枠 (id, out, size, transparent, brief, category, anchor)。これは技術仕様なので id/out/size/transparent/anchor は変えないこと。
- ゲームデータの詳細は `autoload/GlobalProdDataGenerator.gd` を読んでよい。

## 出力 (この4ファイルを作成すること。他のファイルは変更しない)

### 1. `docs/art_direction.md` (日本語)
- ゲームタイトル案 (1つに決める) と一言コンセプト
- 世界観・トーン、配色パレット (hex)、線・塗り・光の描き方のルール
- カテゴリ別ルール: カードイラスト / カードフレーム (ATTACK/SKILL/POWER/STATUS の差別化) / マップ / 戦闘背景 (Act1-3 の変化) / キャラと敵 / アイコン
- VFX デザイン方針 (何が起きたらどう光るか、気持ちよさの設計)

### 2. `tools/codex_art/assets.json`
```json
{
  "style": "全アセット共通のスタイル指示 (英語, 3-6文。画像生成プロンプトの先頭に付く)",
  "assets": [ { ...slots.json の1要素をそのまま..., "prompt": "その画像の被写体・構図・色の具体的な指示 (英語)" } ]
}
```
- slots.json の **全要素** を含め、各要素に `prompt` を追加する。
- さらに VFX 用テクスチャを **8〜12個** 追加する: `id` は `vfx_` で始め、`out` は `sprites/vfx/<id>.png`, `size` は [256,256], `transparent` true, `category` "vfx"。
  VFX テクスチャは「単体の静止画」で、エンジン側でスケール/回転/フェード/加算合成してアニメーションさせる前提 (例: 斬撃の弧, 衝撃の星形バースト, 六角シールド, 葉っぱ1枚, 花びら1枚, 放射能の光輪, 爆発の火球, 回復のきらめき, 粒子用の小さな光点)。
  加算合成するものは黒背景ではなく透明背景で、中心が明るく外側が透明になるように指示すること。
- 戦闘キャラ/敵は「左右どちらを向くか」を brief に従うこと。背景透過、足元まで全身、影なし。

### 3. `tools/codex_art/vfx.json`
エンジン実装者がこのデータだけで演出を作れるように定義する。スキーマ:
```json
{
  "effects": {
    "<effect_id>": {
      "texture": "sprites/vfx/<vfx id>.png",
      "blend": "add | mix",
      "duration": 0.35,
      "scale_from": 0.4, "scale_to": 1.2,
      "rotation_from": 0, "rotation_to": 0, "random_rotation": false,
      "alpha": "fade_out | flash | fade_in_out",
      "offset": [0, -40],
      "color": "#ffffff",
      "particles": { "texture": "sprites/vfx/<vfx id>.png", "amount": 12, "speed": [80, 220], "lifetime": 0.6, "gravity": 300, "scale": [0.1, 0.25], "color": "#ffffff", "spread_deg": 360 },
      "screen_shake": 6,
      "hit_stop": 0.05
    }
  },
  "triggers": {
    "attack_single": ["<effect_id>", ...],
    "attack_all": [...],
    "enemy_attack": [...],
    "block_gain": [...],
    "heal": [...],
    "status_buff": [...],
    "status_debuff": [...],
    "overheat": [...],
    "energy_gain": [...],
    "death": [...],
    "card_play_power": [...]
  }
}
```
- `particles`, `screen_shake`, `hit_stop` は省略可。 triggers のキーは上記を全て含めること。1トリガーに複数エフェクトを重ねてよい (同時再生)。
- 気持ちよさ重視: ヒットストップと画面揺れは強攻撃ほど強く、ただし過剰にならないこと。

### 4. `tools/codex_art/names.json`
```json
{ "game_title": "...", "enemies": { "<enemy id>": { "name": "表示名(英語)", "description": "1文(英語)" } } }
```
slots.json にある全敵 id について、assets.json の見た目と一致する名前を付けること。

作業が終わったら、作成したファイルの一覧だけを短く報告してください。
