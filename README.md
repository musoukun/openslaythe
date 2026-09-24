# Petal Fallout

> クビになった「熱核植物学者」が、暴走した園芸ロボットだらけの原子炉温室を駆け上がる、Slay the Spire 風デッキ構築ローグライク。

- エンジン: Godot 4.6 (GDScript)
- 土台: [DesirePathGames/Slay-The-Robot](https://github.com/DesirePathGames/Slay-The-Robot)（MIT License）
- ビジュアルデザイン（世界観・カード・マップ・キャラ/敵・戦闘エフェクト）: **Codex CLI に委託して生成**

## 遊び方

1. [Godot 4.6](https://godotengine.org/download/) をインストール
2. このリポジトリを開いて実行（F5）
3. `New Game` → The Botanist を選んでスタート

## Codex へのアート委託の仕組み

| ファイル | 役割 |
|---|---|
| `tools/codex_art/build_slots.py` | ゲームデータから「作るべき画像の枠」(`slots.json`) を自動生成 |
| `tools/codex_art/design_brief.md` | Codex への依頼書（アートディレクター役） |
| `docs/art_direction.md` | Codex が書いたアートディレクション |
| `tools/codex_art/assets.json` | Codex が書いた全アセットの画像プロンプト |
| `sprites/vfx/vfx.json` | Codex が設計した戦闘 VFX 定義（エフェクト + トリガー） |
| `sprites/enemy_names.json` | Codex が命名した敵の名前 |
| `tools/codex_art/generate.py` | `codex exec` + `$imagegen` で画像を並列生成し、透過トリム・リサイズ |

```powershell
# 未生成の画像だけ生成（Codex CLI にログイン済みであること）
python tools/codex_art/generate.py --workers 5
# id 前方一致で作り直し
python tools/codex_art/generate.py --only card_bud --force
```

生成画像は命名規約で自動的にゲームへ割り当てられます（`scripts/ArtOverrides.gd`, `scripts/ui/UiSkin.gd`）。
戦闘演出は `autoload/Vfx.gd` が `vfx.json` を読み、スプライト・パーティクル・画面揺れ・ヒットストップで再生します。

## 開発用

```powershell
.\tools\shot.ps1 combat   # 戦闘画面を自動で開いてスクリーンショット (map / vfx も可)
```

## クレジット / ライセンス

- フレームワーク: Slay the Robot © 2025 DesirePathGames — MIT License（`LICENSE`）
- 旧インパクトエフェクト素材: sinestesiastudio (OpenGameArt) — `external/sprites/animated_effects/impact_default/credit.txt`
- サウンド: Slay the Robot 同梱のもの
- 生成アート: OpenAI Codex CLI（image generation）で本プロジェクト用に生成
