# Codex への依頼: 主人公キャラクターの再デザイン（ドット絵アニメーション）

あなたはこのゲーム (Petal Fallout, Slay the Spire 風デッキ構築) のキャラクターデザイナーです。
今の主人公「The Botanist」(白衣の研究者) は戦闘向きに見えず格好良くない、という指摘を受けました。
**戦闘向きの女戦士** として主人公を再デザインしてください。今回は **設計ファイルを書くだけ** で、画像生成はまだしないでください。

## 要件 (ユーザー指定)
- ロングヘアの女戦士。胸元が深く開いた (deep cleavage) 鎧/衣装。格好良く、強そうに。
- 表現は **ドット絵 (pixel art) のアニメーション**。戦闘画面で待機・攻撃のアニメをする。
- 露骨・性的な表現にはしない (一般向けファンタジーゲームの女戦士の範囲)。
- ゲームのテーマ (原子炉温室 × 植物 × 園芸ロボットとの戦い) と、カードのメカニクス (Overshield / Pointy(トゲ) / Overheat / 放射性廃棄物) に合う装備にする。例: 植物の蔓が絡む鎧、放射性に光る大剣や鎌 など。
- 既存のアートディレクション `docs/art_direction.md` の配色 (インクティール, 銅, ミント, ライム, コーラル) と調和させる。
- 他作品のキャラクターの模倣はしない。

## 出力 (この2ファイルだけを作成)

### 1. `docs/character_design.md` (日本語)
- キャラ名 (英語名とカタカナ読み)、一言キャッチ、背景設定 (2〜3文。元の「クビになった熱核植物学者」設定を戦士寄りに再解釈してよい)
- 外見 (髪・顔・体格・鎧・武器)、配色 (hex)、シルエットの特徴
- アニメーション設計: idle (4フレーム) と attack (4フレーム) の各コマで何が起きるか

### 2. `tools/codex_art/character_assets.json`
```json
{
  "style": "ドット絵用の共通スタイル (英語, 3-5文。ピクセルアート、くっきりした1pxの暗い輪郭、限られたパレット、アンチエイリアスなし、透過背景 など)",
  "assets": [
    {"id": "hero_idle", "out": "external/sprites/characters/character_green/hero_idle.png", "size": [256, 256], "transparent": true, "anchor": "bottom", "sheet": 4, "pixel": 4, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero_attack", "out": "external/sprites/characters/character_green/hero_attack.png", "size": [256, 256], "transparent": true, "anchor": "bottom", "sheet": 4, "pixel": 4, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero_icon", "out": "external/sprites/characters/character_green/character_green_icon.png", "size": [128, 128], "transparent": true, "pixel": 2, "category": "icon", "brief": "...", "prompt": "..."},
    {"id": "hero_card_bust", "out": "sprites/ui/hero_bust.png", "size": [512, 512], "transparent": true, "category": "icon", "brief": "タイトル/キャラ選択用の大きめバストアップ (ドット絵)", "prompt": "..."}
  ]
}
```
- `sheet: 4` の画像は **横一列に4コマ並んだスプライトシート** として生成させる。prompt に必ず次を含めること:
  「exactly 4 frames in a single horizontal row, equal-width cells, same character size and same ground line in every frame, full body, facing RIGHT, no overlap between frames, transparent background, no text, no grid lines」
- idle は呼吸・髪と武器の揺れ程度の小さな動き。attack は 構え→振りかぶり→斬撃(武器の軌跡)→戻り。
- id / out / size / transparent / anchor / sheet / pixel の値は上の例のまま変えないこと (prompt と brief だけ書く)。

作業が終わったら、作成したファイル名とキャラ名だけを短く報告してください。
