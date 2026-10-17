# BGM のクレジット

このフォルダの曲は、Suno で作る本番の曲ができるまでの**仮の BGM** です。
すべて OpenGameArt.org の CC0（パブリックドメイン）の曲で、2026-10-18 にダウンロードしました。
CC0 なのでクレジットは必須ではありませんが、出どころを残しておきます。

| ファイル | 場面 | 曲名 | 作者 | 配布元 | ライセンス |
| --- | --- | --- | --- | --- | --- |
| lobby.ogg | タイトル画面 | A Legend Will Rise (Orchestral) | CodeManu | https://opengameart.org/content/a-legend-will-rise-orchestral | CC0 |
| map.ogg | マップ（次の部屋を選ぶ）・開始地点・宝箱・休憩所・店 | Unexplored (Expansion) | TAD、Bo Jingles（ループ版） | https://opengameart.org/content/unexplored-expansion | CC0 |
| event.ogg | イベント（?の部屋） | Mysterious | nene | https://opengameart.org/content/mysterious | CC0 |
| combat.ogg | 通常戦 | Battle Theme A | cynicmusic | https://opengameart.org/content/battle-theme-a | CC0 |
| elite.ogg | エリート戦 | Determined Pursuit (epic orchestra loop) | Emma_MA | https://opengameart.org/content/determined-pursuit-epic-orchestra-loop | CC0 |
| boss.ogg | ボス戦 | Epic Boss Battle [Seamlessly Looping] | Juhani Junkala (SubspaceAudio) | https://opengameart.org/content/boss-battle-music | CC0 |

## 元の曲から変えたところ

- すべて OGG Vorbis（品質 6）に変換し、音量を約 -18 LUFS にそろえた。
- lobby.ogg は末尾の無音（68.5 秒以降）、event.ogg は末尾の無音（83 秒以降）を切った。
- ループはゲーム側で設定している。ループ用に作られているのは map / elite / boss の3曲で、lobby / event / combat は曲の終わりから頭に戻るので、つなぎ目が少し目立つ。

## 差し替え方

同じファイル名の .ogg で上書きすれば差し替わる（どの場面でどのファイルを鳴らすかは `autoload/FileLoader.gd` の Music Paths）。
差し替えたら、この表の行も書き換えること。Suno 用のプロンプトは `docs/bgm/suno_prompts.md`。
