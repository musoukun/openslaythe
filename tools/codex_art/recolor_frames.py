"""緑カードの枠 (card_frame_green_*.png) を主人公 Vera Emberscale の配色に塗り替える。

Codex を呼ばずに、既存の枠の形・透過・絵の窓はそのままで、緑の部分だけを明るさに応じて
黒鉄 #2A2426 → 深紅 #8E1B23 → 赤銅 #B5532E のグラデーションに置き換える。
クリーム色の説明欄は緑ではないので変わらない。内部の色 ID (color_green) やファイル名は変えない。

使い方: python tools/codex_art/recolor_frames.py [--palette=azure] <入力png>... (出力は同じパスに上書き)
  --palette=azure: 2人目の主人公ルカの配色 (紺 → サファイア → 淡い青)。省略時は Vera の赤銅
"""
import sys

import numpy as np
from PIL import Image

# 明るさ (0-255) → 色 の対応点。間は線形補間する
STOPS = [
    (0, (0x14, 0x0E, 0x10)),
    (65, (0x2A, 0x24, 0x26)),   # 黒鉄 (リボン・内側の縁)
    (95, (0x5E, 0x14, 0x1A)),
    (120, (0x8E, 0x1B, 0x23)),  # 深紅 (カード本体)
    (165, (0xB5, 0x53, 0x2E)),  # 赤銅 (明るい部分)
    (255, (0xFF, 0x8A, 0x2A)),  # 残り火
]

AZURE_STOPS = [
    (0, (0x0A, 0x0E, 0x1C)),
    (65, (0x14, 0x1C, 0x36)),   # 濃紺 (リボン・内側の縁)
    (95, (0x16, 0x24, 0x4A)),
    (120, (0x1B, 0x2A, 0x55)),  # 紺 (カード本体)
    (165, (0x2E, 0x5C, 0xA8)),  # サファイア (明るい部分)
    (255, (0x7F, 0xD3, 0xFF)),  # 淡い青の光
]
PALETTES = {"copper": STOPS, "azure": AZURE_STOPS}


def gradient(lum: np.ndarray, stops: list = STOPS) -> np.ndarray:
    xs = [s[0] for s in stops]
    return np.stack([np.interp(lum, xs, [s[1][i] for s in stops]) for i in range(3)], axis=-1)


def recolor(path: str, stops: list = STOPS) -> None:
    rgba = np.asarray(Image.open(path).convert("RGBA")).astype(np.float32)
    r, g, b = rgba[..., 0], rgba[..., 1], rgba[..., 2]
    # 緑みの強さ (0-1)。緑が赤・青より強いほど 1。暗い青緑の輪郭線も黒鉄に寄せる
    greenness = np.clip((g - np.maximum(r, b)) / 25.0, 0, 1)
    teal = np.clip((np.minimum(g, b) - r) / 20.0, 0, 1) * (g < 90)
    weight = np.maximum(greenness, teal)[..., None]
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    rgba[..., :3] = rgba[..., :3] * (1 - weight) + gradient(lum, stops) * weight
    Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA").save(path)
    print("recolored", path)


if __name__ == "__main__":
    args = sys.argv[1:]
    palette = "copper"
    if args and args[0].startswith("--palette="):
        palette = args.pop(0).split("=", 1)[1]
    for p in args:
        recolor(p, PALETTES[palette])
