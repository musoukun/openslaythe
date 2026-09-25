# Slay the Spire 2 マップ・幕構成 調査メモ (2026-09)

実装: `scripts/actions/world_generation_actions/ActionGenerateAct.gd`

| 項目 | StS2 | 出典 |
|---|---|---|
| 幕 | 3幕 (Act1 は Overgrowth/Underdocks からランダム)。各幕の最初に Ancient、最後にボス | wiki.gg Acts |
| 行数 | Act1=15 / Act2=14 / Act3=13 (+Ancient +ボス) | spire-codex |
| 格子 | 7列、経路6本・交差なし (StS1 と同様と推定) | spire-codex / StS1 wiki |
| 固定行 | 1行目=敵、最後から7行目=宝箱、最終行=休憩 | spire-codex, wiki.gg |
| 配置制限 | 最初の5行にエリート・休憩なし / エリート・商人・休憩は連続しない / 同じ親の子は別種 | spire-codex, StS1 |
| 部屋数 | エリート5 (A1+:8) / 商人3 / ? Act1 10〜14, Act2/3 9〜13 / 休憩 Act1・2 6〜7, Act3 5〜6 / 残り敵 | spire-codex |
| ?の中身 | 敵10% / 宝箱2% / 商人3% (外れるたび +10/+2/+3、当たれば初期値、幕でリセット) | spire-codex |
| 弱い敵 | Act1 最初の3戦、Act2/3 最初の2戦 | wiki.gg |

報酬など: 通常戦闘 10〜20G+カード3択 / エリート 35〜45G+レリック確定 / 宝箱 レリック+42〜53G /
休憩所 HP30%回復 or アップグレード / ポーションドロップ 40% ±10%。

未確認 (StS1 準拠で実装): 経路本数・交差ルール・同種連続禁止。?の中身は本実装では生成時に判定 (入室時判定と同じ確率推移)。

Sources: slaythespire.wiki.gg (StS2: Acts / Map Locations / Ascension), spire-codex.com/mechanics/map-generation, spire-codex.com/mechanics/unknown-rooms, kosgames.com (StS1 map generation guide)
