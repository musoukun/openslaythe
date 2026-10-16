"""緑カードの枠 (card_frame_green_*.png) を主人公 Vera Emberscale の配色に塗り替える。

Codex を呼ばずに、既存の枠の形・透過・絵の窓はそのままで、緑の部分だけを明るさに応じて
黒鉄 #2A2426 → 深紅 #8E1B23 → 赤銅 #B5532E のグラデーションに置き換える。
クリーム色の説明欄は緑ではないので変わらない。内部の色 ID (color_green) やファイル名は変えない。

使い方: python tools/codex_art/recolor_frames.py <入力png>... (出力は同じパスに上書き)
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


def gradient(lum: np.ndarray) -> np.ndarray:
    xs = [s[0] for s in STOPS]
    return np.stack([np.interp(lum, xs, [s[1][i] for s in STOPS]) for i in range(3)], axis=-1)


def recolor(path: str) -> None:
    rgba = np.asarray(Image.open(path).convert("RGBA")).astype(np.float32)
    r, g, b = rgba[..., 0], rgba[..., 1], rgba[..., 2]
    # 緑みの強さ (0-1)。緑が赤・青より強いほど 1。暗い青緑の輪郭線も黒鉄に寄せる
    greenness = np.clip((g - np.maximum(r, b)) / 25.0, 0, 1)
    teal = np.clip((np.minimum(g, b) - r) / 20.0, 0, 1) * (g < 90)
    weight = np.maximum(greenness, teal)[..., None]
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    rgba[..., :3] = rgba[..., :3] * (1 - weight) + gradient(lum) * weight
    Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA").save(path)
    print("recolored", path)


if __name__ == "__main__":
    for p in sys.argv[1:]:
        recolor(p)
