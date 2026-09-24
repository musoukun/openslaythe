"""Codex CLI にアート生成を委託するパイプライン.

manifest (assets.json) の各アセットについて:
  1. codex exec + $imagegen で raw PNG を生成 (raw/<id>.png)
  2. Pillow で後処理 (透過トリム / クロップ / リサイズ) して out に保存

使い方:
  python tools/codex_art/generate.py                 # 未生成のものだけ
  python tools/codex_art/generate.py --only card_    # id 前方一致で絞り込み
  python tools/codex_art/generate.py --force         # raw を作り直す
  python tools/codex_art/generate.py --post-only     # raw から後処理だけやり直す
"""
import argparse
import glob
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
RAW_DIR = HERE / "raw"
MANIFEST = HERE / "assets.json"


def find_codex() -> str:
    if os.environ.get("CODEX_BIN"):
        return os.environ["CODEX_BIN"]
    cands = glob.glob(os.path.expandvars(r"%LOCALAPPDATA%\OpenAI\Codex\bin\*\codex.exe"))
    if not cands:
        sys.exit("codex.exe not found. Set CODEX_BIN.")
    return max(cands, key=os.path.getmtime)


def build_prompt(style: str, asset: dict, raw_path: Path) -> str:
    bg = ("The background MUST be fully transparent (alpha)."
          if asset.get("transparent") else
          "Fill the whole canvas edge to edge, no border, no transparency.")
    return (
        "$imagegen Generate exactly one image and nothing else.\n"
        f"Art direction:\n{style}\n\n"
        f"Subject:\n{asset['prompt']}\n\n"
        f"{bg} No text, no letters, no watermark, no UI frame.\n"
        f"Save the final PNG to this exact path: {raw_path.name} (in the current working directory). "
        "Do not create or modify any other file."
    )


def generate_raw(codex: str, style: str, asset: dict) -> bool:
    raw_path = RAW_DIR / f"{asset['id']}.png"
    prompt = build_prompt(style, asset, raw_path)
    proc = subprocess.run(
        [codex, "exec", "-C", str(RAW_DIR), "-s", "workspace-write",
         "--skip-git-repo-check", "--ephemeral", "-"],
        input=prompt, text=True, encoding="utf-8",
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=900,
    )
    ok = raw_path.exists()
    if not ok:
        print(f"[NG] {asset['id']}\n{proc.stdout[-1500:]}")
    return ok


def chroma_key(im: Image.Image, hex_color: str, tolerance: int = 90) -> Image.Image:
    """指定色に近いピクセルを透明にする (距離に応じてなめらかに)."""
    kr, kg, kb = (int(hex_color.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4))
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            d = abs(r - kr) + abs(g - kg) + abs(b - kb)
            if d < tolerance:
                px[x, y] = (r, g, b, 0)
            elif d < tolerance * 2:
                px[x, y] = (r, g, b, min(a, int(255 * (d - tolerance) / tolerance)))
    return im


def clear_window(im: Image.Image, seed_pct: list) -> Image.Image:
    """seed (割合座標) から暗い不透明な縁に当たるまでを透明にする (カード枠の絵の窓を抜く)."""
    px = im.load()
    sx, sy = int(im.width * seed_pct[0]), int(im.height * seed_pct[1])
    def is_wall(p):
        r, g, b, a = p
        return a > 200 and (r * 0.3 + g * 0.59 + b * 0.11) < 95
    stack, seen = [(sx, sy)], set()
    while stack:
        x, y = stack.pop()
        if (x, y) in seen or not (0 <= x < im.width and 0 <= y < im.height):
            continue
        seen.add((x, y))
        if is_wall(px[x, y]):
            continue
        r, g, b, _ = px[x, y]
        px[x, y] = (r, g, b, 0)
        stack.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return im


def post_process(asset: dict) -> None:
    raw_path = RAW_DIR / f"{asset['id']}.png"
    out_path = REPO / asset["out"]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    w, h = asset["size"]
    im = Image.open(raw_path).convert("RGBA")
    if asset.get("chroma_key"):
        im = chroma_key(im, asset["chroma_key"])

    if asset.get("fit") == "stretch":
        # 透明部分をトリムして、枠いっぱいに引き伸ばす (カード枠などレイアウト位置が重要なもの)
        bbox = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
        if bbox:
            im = im.crop(bbox)
        im = im.resize((w, h), Image.LANCZOS)
        if asset.get("clear_window"):
            im = clear_window(im, asset["clear_window"])
    elif asset.get("transparent"):
        # 透明部分をトリムして、枠内に収まるよう縮小 → 中央(下揃え可)に配置
        bbox = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
        if bbox:
            im = im.crop(bbox)
        pad = asset.get("pad", 0.04)
        scale = min(w * (1 - pad * 2) / im.width, h * (1 - pad * 2) / im.height)
        im = im.resize((max(1, round(im.width * scale)), max(1, round(im.height * scale))), Image.LANCZOS)
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        x = (w - im.width) // 2
        y = h - im.height - round(h * pad) if asset.get("anchor") == "bottom" else (h - im.height) // 2
        canvas.paste(im, (x, y), im)
        im = canvas
    else:
        # 目標アスペクトで中央クロップしてからリサイズ
        target = w / h
        if im.width / im.height > target:
            nw = round(im.height * target)
            left = (im.width - nw) // 2
            im = im.crop((left, 0, left + nw, im.height))
        else:
            nh = round(im.width / target)
            top = (im.height - nh) // 2
            im = im.crop((0, top, im.width, top + nh))
        im = im.resize((w, h), Image.LANCZOS)

    im.save(out_path)
    print(f"[OK] {asset['id']} -> {asset['out']} {w}x{h}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="", help="id prefix filter (comma separated)")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--post-only", action="store_true")
    ap.add_argument("--workers", type=int, default=4)
    args = ap.parse_args()

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    style = manifest["style"]
    prefixes = [p for p in args.only.split(",") if p]
    assets = [a for a in manifest["assets"]
              if not prefixes or any(a["id"].startswith(p) for p in prefixes)]
    RAW_DIR.mkdir(exist_ok=True)

    if not args.post_only:
        codex = find_codex()
        todo = [a for a in assets if args.force or not (RAW_DIR / f"{a['id']}.png").exists()]
        print(f"generating {len(todo)} assets with {args.workers} workers")
        with ThreadPoolExecutor(args.workers) as ex:
            list(ex.map(lambda a: (generate_raw(codex, style, a) or generate_raw(codex, style, a)) and post_process(a), todo))

    for a in assets:
        if (RAW_DIR / f"{a['id']}.png").exists():
            post_process(a)


if __name__ == "__main__":
    main()
