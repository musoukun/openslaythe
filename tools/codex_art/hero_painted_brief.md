# Codex への依頼: 主人公ヴェラを手描き風アニメーションで作り直す

ドット絵版の主人公は世界観 (手描きガッシュ調の背景・敵・カード) と合わない、という判断になりました。
`docs/character_design.md` のヴェラ・ソーンフォージ (長い髪、胸元が深く開いた V 字の胸甲、炉刃剪定剣、背中の鉢原子炉 など) のデザインはそのまま使い、
**絵柄だけを `tools/codex_art/assets.json` の "style" (ゲーム全体の手描きスタイル) に合わせて** 作り直すための設計ファイルを書いてください。
今回も **設計ファイルを書くだけ** で、画像生成はしないでください。

## 出力: `tools/codex_art/hero_painted_assets.json` (このファイルだけ作成)

```json
{
  "style": "assets.json の style をベースに、戦闘キャラのアニメーションシート用の注意を足した共通スタイル (英語)",
  "assets": [
    {"id": "hero2_idle",   "out": "external/sprites/characters/character_green/hero_idle.png",   "size": [300, 300], "transparent": true, "anchor": "bottom", "sheet": 4, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero2_attack", "out": "external/sprites/characters/character_green/hero_attack.png", "size": [300, 300], "transparent": true, "anchor": "bottom", "sheet": 4, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero2_hurt",   "out": "external/sprites/characters/character_green/hero_hurt.png",   "size": [300, 300], "transparent": true, "anchor": "bottom", "sheet": 3, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero2_block",  "out": "external/sprites/characters/character_green/hero_block.png",  "size": [300, 300], "transparent": true, "anchor": "bottom", "sheet": 3, "category": "combatant", "brief": "...", "prompt": "..."},
    {"id": "hero2_icon",   "out": "external/sprites/characters/character_green/character_green_icon.png", "size": [128, 128], "transparent": true, "category": "icon", "brief": "...", "prompt": "..."},
    {"id": "hero2_bust",   "out": "sprites/ui/hero_bust.png", "size": [512, 512], "transparent": true, "category": "icon", "brief": "タイトル用バストアップ", "prompt": "..."}
  ]
}
```

- id / out / size / transparent / anchor / sheet の値は上のまま変えず、brief と prompt を書くこと。
- `sheet: N` の画像は **横一列に N コマ並んだスプライトシート**。prompt に必ず含める:
  「exactly N frames in a single horizontal row, equal-width cells, the SAME character at the SAME size and the SAME ground line in every frame, full body, facing RIGHT, clear empty gap between frames, nothing crosses a cell border, transparent background, no text, no grid lines, no motion trail outside the cell」
- 4 種類のシートで同一人物に見えるよう、各 prompt の冒頭にキャラの外見を毎回フルに書く (髪色・肌・鎧・武器・背中の炉)。
- 動き:
  - idle (4): 構えたまま呼吸、髪と蔓がわずかに揺れる。足は動かさない。
  - attack (4): 構え → 大きく振りかぶる → 前方へ斬り下ろす (刃の軌跡はセル内に収める) → 構えに戻る。
  - hurt (3): 被弾でのけぞる → 最もひるんだ姿勢 (目をつぶる) → 立て直し。
  - block (3): 剣を横に構え腕の六角シールド (シアン) を展開 → 最大展開で踏ん張る → 構えに戻る。
- 一般向けファンタジーの女戦士の範囲 (露骨・性的な表現にしない)。成人の戦士らしい力強さを優先。

作業が終わったら、作成したファイル名だけを短く報告してください。
