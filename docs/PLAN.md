# OpenSlay 開発計画

土台: [DesirePathGames/Slay-The-Robot](https://github.com/DesirePathGames/Slay-The-Robot) (MIT, Godot 4.6)

ビジュアルデザイン（世界観・マップ・カード・戦闘エフェクト・VFX）は **Codex CLI に委託** し、
Claude Code が実装・組み込みを担当する。

## Codex 委託の方法

- `codex exec`（非対話モード）に `$imagegen` スキルで画像生成させる
  - `-C tools/codex_art/raw -s workspace-write --skip-git-repo-check --ephemeral`
  - プロンプトは stdin で渡す（引数渡しは入力待ちで固まることがある）
  - 生成物は `~/.codex/generated_images/` に出るので、指定パスへコピーさせる
- デザイン仕様（アートディレクション・プロンプト）も Codex に書かせる → `docs/art_direction.md` / `tools/codex_art/assets.json`
- 後処理は `tools/codex_art/generate.py`（透過トリム・クロップ・リサイズ、並列生成）

## フェーズ

1. [x] 土台取り込み
2. [ ] Codex 委託パイプライン（generate.py / assets.json）
3. [ ] Codex によるアートディレクション（テーマ・配色・各アセット仕様）
4. [ ] カード: タイプ/色別フレーム + カードイラスト
5. [ ] マップ: 背景・ノードアイコン・道
6. [ ] 戦闘: 背景・プレイヤー・敵・インテント
7. [ ] 戦闘エフェクト: スプライトシート VFX、ダメージ数字、ヒットストップ、画面揺れ
8. [ ] UI: タイトル画面・レリック/消耗品/状態異常アイコン
9. [ ] README / クレジット / push

## 検証

- `godot --headless --path . --quit-after N` でエラー確認
- `godot --path . --write-movie shots/x.png --fixed-fps 10 --quit-after N` で画面キャプチャ
