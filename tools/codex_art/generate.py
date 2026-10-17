"""Codex CLI にアート生成を委託するパイプライン.

manifest (assets.json) の各アセットについて:
  1. codex exec + $imagegen で raw PNG を生成 (raw/<id>.png)
  2. Pillow で後処理 (透過トリム / クロップ / リサイズ) して out に保存

使い方:
  python tools/codex_art/generate.py                 # 未生成のものだけ
  python tools/codex_art/generate.py --only card_    # id 前方一致で絞り込み
  python tools/codex_art/generate.py --force         # raw を作り直す
  python tools/codex_art/generate.py --post-only     # raw から後処理だけやり直す
  python tools/codex_art/generate.py --grid 5x6      # 透過アイコンを 30 個ずつ 1 枚にまとめて描く
"""
import argparse
import glob
import json
import os
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from PIL import Image, ImageFilter, PngImagePlugin

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


# refs (正本画像) を添付したときの役割分担: デザインは添付画像、ポーズは Subject の文
REF_RULE = (
    "Reference: attached image 1 is the canonical design of this character. Match it exactly for the face, hair, "
    "horns, body proportions, armor, gauntlets, claws, tail, colors and rendering style. Follow the Subject text only "
    "for pose, framing, frame count and effects; do not copy the reference's pose or canvas.\n\n"
)


TRANSPARENT_BG = ("Use the image tool's transparent background option: output a PNG with a real alpha channel where "
                  "the background is fully transparent (alpha 0), not white, black, checkerboard, gradient or any "
                  "colored backdrop or glow haze.")
# 透過に失敗したときの描き直し用。後処理で chroma_key して抜く
GREEN_BG = ("Paint the background as one perfectly flat solid pure green (#00FF00) fill edge to edge, with no "
            "gradient, shadow or glow on it, and do not use that green anywhere on the subject; it will be "
            "chroma-keyed out.")
GREEN = "#00FF00"


def build_prompt(style: str, asset: dict, raw_path: Path) -> str:
    if asset.get("greenscreen"):
        bg = GREEN_BG
    elif asset.get("transparent"):
        bg = TRANSPARENT_BG
    else:
        bg = "Fill the whole canvas edge to edge, no border, no transparency."
    return (
        "$imagegen Generate exactly one image and nothing else.\n"
        f"Art direction:\n{style}\n\n"
        f"Subject:\n{asset['prompt']}\n\n"
        f"{asset.get('ref_rule', REF_RULE) if asset.get('refs') else ''}"
        f"{bg} No text, no letters, no watermark, no UI frame.\n"
        f"Save the final PNG to this exact path: {raw_path.name} (in the current working directory). "
        "Do not create or modify any other file."
    )


def run_codex(codex: str, prompt: str, raw_path: Path, refs: list, label: str) -> bool:
    raw_path.unlink(missing_ok=True)  # 古い raw が残ると失敗しても成功と判定されるので消してから作る
    proc = subprocess.run(
        [codex, "exec", "-C", str(RAW_DIR), "-s", "workspace-write",
         "--skip-git-repo-check", "--ephemeral",
         *[arg for ref in refs for arg in ("-i", str(REPO / ref))], "-"],
        input=prompt, text=True, encoding="utf-8",
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=900,
    )
    ok = raw_path.exists()
    if not ok:
        print(f"[NG] {label}\n{proc.stdout[-1500:]}")
    return ok


def generate_raw(codex: str, style: str, asset: dict) -> bool:
    raw_path = RAW_DIR / f"{asset['id']}.png"
    return run_codex(codex, build_prompt(style, asset, raw_path), raw_path, asset.get("refs", []), asset["id"])


# --grid: 透過アイコンを cols x rows のマスの 1 枚にまとめて描き、マスごとに切り分けて各 raw にする
# (例: 5x6 なら 30 個を Codex 1 回で描く)。カード絵は解像度が要るので常に 2x2
CARD_GRID = (2, 2)


def parse_grid(text: str) -> tuple:
    """'5x6' -> (5 列, 6 行)."""
    try:
        cols, rows = (int(v) for v in text.lower().split("x"))
    except ValueError:
        raise argparse.ArgumentTypeError(f"--grid は 列x行 (例: 4x4, 5x6) で指定: {text}")
    if cols < 1 or rows < 1:
        raise argparse.ArgumentTypeError(f"--grid の列と行は 1 以上: {text}")
    return cols, rows


def can_grid(asset: dict) -> bool:
    if asset.get("sheet") or asset.get("refs"):
        return False
    return needs_alpha_check(asset) or is_card_art(asset)


# カード絵 (正方形・不透明) も 2x2 でまとめて描ける。マスの間の暗い溝は、切り分けるときに内側で切り落とす
def is_card_art(asset: dict) -> bool:
    return asset.get("category") == "card_art" and not asset.get("transparent")


CARD_GRID_INSET = 0.04


def grid_prompt(style: str, batch: list, cols: int, rows: int, raw_name: str) -> str:
    """batch の i 番目を左上から横に読んだ i 番目のマス (row r, column c) に描かせるプロンプト."""
    cards = is_card_art(batch[0])
    shape = "square" if cols == rows else ("landscape" if cols > rows else "portrait")
    subjects = "\n".join(f"- row {i // cols + 1}, column {i % cols + 1}: {a['prompt']}" for i, a in enumerate(batch))
    grid = (f"Divide the canvas into a grid of {cols} columns by {rows} rows ({cols * rows} equal cells), "
            "counted left to right and top to bottom from row 1, column 1 at the top-left.")
    if cards:
        layout = (f"Layout: a sheet of separate square card illustrations in one consistent style. {grid} Separate the "
                  "cells with thin flat dark-navy gutters. Each cell is its own complete full-bleed illustration with an "
                  "opaque painted background filling the cell; keep every important shape at least 8 percent away from "
                  "the cell edges and never continue a picture into another cell. Fill unused cells with flat dark navy.\n\n")
        background = "No text, no letters, no numbers, no borders, no UI frame."
    else:
        layout = (f"Layout: a sheet of separate icons in one consistent style. {grid} Draw exactly one subject centered "
                  "in its listed cell, fully contained inside it with at least 12 percent empty margin from the cell "
                  "edges, never touching or crossing into another cell. Leave unused cells empty.\n\n")
        background = f"{TRANSPARENT_BG} No text, no letters, no numbers, no grid lines, no borders, no UI frame."
    return (
        f"$imagegen Generate exactly one {shape} image and nothing else.\n"
        f"Art direction:\n{style}\n\n"
        f"{layout}"
        f"Subjects:\n{subjects}\n\n"
        f"{background}\n"
        f"Save the final PNG to this exact path: {raw_name} (in the current working directory). "
        "Do not create or modify any other file."
    )


def split_grid(sheet: Image.Image, batch: list, cols: int, rows: int) -> None:
    """cols x rows のシートをマスごとに切り分けて batch の各 raw に保存する (左上から横に読む順)."""
    cards = is_card_art(batch[0])
    cw, ch = sheet.width / cols, sheet.height / rows
    inset = round(min(cw, ch) * CARD_GRID_INSET) if cards else 0
    for i, a in enumerate(batch):
        c, r = i % cols, i // cols
        box = (round(c * cw) + inset, round(r * ch) + inset, round((c + 1) * cw) - inset, round((r + 1) * ch) - inset)
        mark = PngImagePlugin.PngInfo()
        if not cards:
            mark.add_text("grid", "1")  # 後処理で隣のマスのはみ出しを消す目印
        sheet.crop(box).save(RAW_DIR / f"{a['id']}.png", pnginfo=mark)


def generate_grid(codex: str, style: str, batch: list, cols: int, rows: int) -> bool:
    if not is_card_art(batch[0]):
        rows = -(-len(batch) // cols)  # 最後の半端な束は空の行を描かせず、マスを大きくする
    raw_path = RAW_DIR / ("grid_" + batch[0]["id"] + ".png")
    prompt = grid_prompt(style, batch, cols, rows, raw_path.name)
    if not run_codex(codex, prompt, raw_path, [], "grid " + ",".join(a["id"] for a in batch)):
        return False
    split_grid(Image.open(raw_path).convert("RGBA"), batch, cols, rows)
    raw_path.unlink()
    return True


def clean_grid_cell(im: Image.Image) -> Image.Image:
    """grid から切り分けたマスから、隣のマスのはみ出し (マスの縁に接する小さい成分) を消す."""
    step = 2
    comps = components(im, step)
    if not comps:
        return im
    w, h = im.width // step, im.height // step
    biggest = max(len(c) for c in comps)
    def touches_edge(pts):
        return any(x in (0, w - 1) or y in (0, h - 1) for x, y in pts)
    kept = [p for c in comps if len(c) == biggest or not touches_edge(c) for p in c]
    return keep_points(im, kept, step)


def alpha_ok(im: Image.Image) -> bool:
    """透過アセットとして使えるか: 四隅がすべて透明で、全体の 9 割以上が不透明ではない."""
    a = im.convert("RGBA").getchannel("A")
    w, h = a.size
    corners = [a.getpixel(p) for p in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1))]
    opaque = a.point(lambda v: 255 if v > 8 else 0).histogram()[255] / (w * h)
    return max(corners) <= 8 and opaque < 0.9


def needs_alpha_check(asset: dict) -> bool:
    """四隅で透過を判定するアセットか. 端まで描く素材 (fit: stretch の羊皮紙など) と chroma_key 指定は除く."""
    return bool(asset.get("transparent")) and asset.get("fit") != "stretch" and not asset.get("chroma_key")


def make_raw(codex: str, style: str, asset: dict) -> bool:
    """raw を作る (失敗したら 1 回だけ再試行)。透過のはずが背景つきで出たらグリーンバックで描き直す."""
    if not (generate_raw(codex, style, asset) or generate_raw(codex, style, asset)):
        return False
    if needs_alpha_check(asset) and not alpha_ok(Image.open(RAW_DIR / f"{asset['id']}.png")):
        print(f"[RETRY] {asset['id']}: background is not transparent, regenerating on green screen")
        return generate_raw(codex, style, {**asset, "greenscreen": True})
    return True


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


def seamless_y(im: Image.Image, band_ratio: float = 0.2) -> Image.Image:
    """下端の帯を上端にクロスフェードして縦に継ぎ目なく並ぶようにする."""
    w, h = im.size
    b = int(h * band_ratio)
    out = im.crop((0, 0, w, h - b))
    top = im.crop((0, 0, w, b))
    bottom = im.crop((0, h - b, w, h))
    mask = Image.linear_gradient("L").resize((w, b))  # 上が 0 (bottom), 下が 255 (top)
    out.paste(Image.composite(top, bottom, mask), (0, 0))
    return out.resize((w, h), Image.LANCZOS)


def trim(im: Image.Image) -> Image.Image:
    bbox = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    return im.crop(bbox) if bbox else im


def place(im: Image.Image, w: int, h: int, scale: float, pad: float, anchor) -> Image.Image:
    """im を scale 倍して w x h のキャンバスに置く (anchor=bottom なら足元揃え)."""
    im = im.resize((max(1, round(im.width * scale)), max(1, round(im.height * scale))), Image.LANCZOS)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x = (w - im.width) // 2
    y = h - im.height - round(h * pad) if anchor == "bottom" else (h - im.height) // 2
    canvas.paste(im, (x, y), im)
    return canvas


def components(f: Image.Image, step: int = 2) -> list:
    """不透明部分 (alpha > 8) の連結成分を 1/step に縮小した座標の点リストで返す."""
    small = f.getchannel("A").resize((f.width // step, f.height // step), Image.NEAREST)
    w, h = small.size
    px = small.load()
    label = [[0] * w for _ in range(h)]
    comps = []
    for y0 in range(h):
        for x0 in range(w):
            if px[x0, y0] > 8 and not label[y0][x0]:
                label[y0][x0] = len(comps) + 1
                stack, pts = [(x0, y0)], []
                while stack:
                    x, y = stack.pop()
                    pts.append((x, y))
                    for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                        if 0 <= nx < w and 0 <= ny < h and not label[ny][nx] and px[nx, ny] > 8:
                            label[ny][nx] = len(comps) + 1
                            stack.append((nx, ny))
                comps.append(pts)
    return comps


def keep_points(f: Image.Image, pts: list, step: int) -> Image.Image:
    """縮小座標の点 pts (とその周囲の縁) だけを残し、ほかを透明にした画像を返す."""
    mask = Image.new("L", (f.width // step, f.height // step), 0)
    mpx = mask.load()
    for x, y in pts:
        mpx[x, y] = 255
    mask = mask.resize(f.size, Image.NEAREST).filter(ImageFilter.MaxFilter(2 * step + 1))
    out = f.copy()
    out.putalpha(Image.composite(f.getchannel("A"), mask, mask))
    return out


def clean_cell(f: Image.Image) -> Image.Image:
    """セル内の連結成分を調べ、最大成分以外で「左端に接するもの (前コマのはみ出し)」と小さなゴミを消す."""
    step = 2
    comps = components(f, step)
    if not comps:
        return f
    w = f.width // step
    biggest = max(len(c) for c in comps)
    kept = []
    for pts in comps:
        touches_left = any(x == 0 for x, _ in pts)
        touches_right = any(x == w - 1 for x, _ in pts)
        if len(pts) == biggest or not (touches_left or (touches_right and len(pts) < biggest * 0.15) or len(pts) < biggest * 0.01):
            kept.extend(pts)
    return keep_points(f, kept, step)


def split_by_components(im: Image.Image, count: int) -> list:
    """大きな連結成分がちょうど count 個あれば、それぞれを 1 コマとして切り出す (コマ境界をはみ出す翼や斬撃も欠けない).
    小さな成分 (火の粉など) は中心が最も近いコマに入れ、最大の 1% 未満のゴミは捨てる。count 個でなければ None."""
    step = 2
    comps = components(im, step)
    if not comps:
        return None
    biggest = max(len(c) for c in comps)
    bodies = sorted((c for c in comps if len(c) >= biggest * 0.3), key=lambda c: min(x for x, _ in c))
    if len(bodies) != count:
        return None
    centers = [sum(x for x, _ in c) / len(c) for c in bodies]
    groups = [list(c) for c in bodies]
    for c in comps:
        if any(c is b for b in bodies) or len(c) < biggest * 0.01:
            continue
        cx = sum(x for x, _ in c) / len(c)
        groups[min(range(count), key=lambda i: abs(centers[i] - cx))].extend(c)
    return [keep_points(im, g, step) for g in groups]


def split_sheet(im: Image.Image, count: int) -> list:
    """横一列 count コマのシートを分割。各コマは足元 (下25%) の中心で左右位置をそろえ、下端を共通にする."""
    cells = split_by_components(im, count)
    if cells is None:
        cell = im.width / count
        cells = [clean_cell(im.crop((round(i * cell), 0, round((i + 1) * cell), im.height))) for i in range(count)]
    frames = []
    for f in cells:
        cell_alpha = f.getchannel("A").point(lambda a: 255 if a > 8 else 0)
        bbox = cell_alpha.getbbox()
        if not bbox:
            frames.append(f)
            continue
        feet = cell_alpha.crop((0, bbox[1] + (bbox[3] - bbox[1]) * 3 // 4, f.width, bbox[3])).getbbox()
        cx = (feet[0] + feet[2]) // 2 if feet else (bbox[0] + bbox[2]) // 2
        half = max(cx - bbox[0], bbox[2] - cx)
        frames.append(f.crop((cx - half, bbox[1], cx + half, bbox[3])))
    # 全コマ同じ高さ (最大) にして下端をそろえる
    top_h = max(fr.height for fr in frames)
    out = []
    for fr in frames:
        c = Image.new("RGBA", (fr.width, top_h), (0, 0, 0, 0))
        c.paste(fr, (0, top_h - fr.height), fr)
        out.append(c)
    return out


def body_height(frame: Image.Image) -> int:
    """コマ内の不透明部分の高さ (足元から頭/武器の先まで)."""
    bbox = frame.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    return (bbox[3] - bbox[1]) if bbox else frame.height


def pixelate(im: Image.Image, px: int) -> Image.Image:
    """px 倍の大きさのドットに量子化し、アルファを 2 値化してくっきりさせる."""
    small = im.resize((im.width // px, im.height // px), Image.NEAREST)
    # 2 値化してから内側の小さな穴を埋める (縁取りシェーダーが穴に付かないように)
    a = small.getchannel("A").point(lambda v: 255 if v > 60 else 0)
    a = a.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.MinFilter(3))
    small.putalpha(a)
    return small.resize((small.width * px, small.height * px), Image.NEAREST)


def post_process(asset: dict) -> None:
    raw_path = RAW_DIR / f"{asset['id']}.png"
    out_path = REPO / asset["out"]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    w, h = asset["size"]
    raw_im = Image.open(raw_path)
    from_grid = raw_im.info.get("grid") == "1"
    im = raw_im.convert("RGBA")
    if from_grid:
        im = clean_grid_cell(im)  # 隣のマスのはみ出しが四隅にかかると透過判定を誤るので、先に消す
    if asset.get("chroma_key"):
        im = chroma_key(im, asset["chroma_key"])
    elif needs_alpha_check(asset) and not alpha_ok(im):
        # グリーンバック (または単色背景) で出てきた raw は左上の色を抜く
        r, g, b, _ = im.getpixel((0, 0))
        im = chroma_key(im, f"#{r:02X}{g:02X}{b:02X}")
        print(f"[KEY] {asset['id']}: keyed out background #{r:02X}{g:02X}{b:02X}")

    if asset.get("fit") == "stretch":
        # 透明部分をトリムして、枠いっぱいに引き伸ばす (カード枠などレイアウト位置が重要なもの)
        bbox = im.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
        if bbox:
            im = im.crop(bbox)
        im = im.resize((w, h), Image.LANCZOS)
        if asset.get("clear_window"):
            im = clear_window(im, asset["clear_window"])
        if asset.get("seamless_y"):
            im = seamless_y(im)
    elif asset.get("sheet"):
        # 横一列のスプライトシート -> コマごとに共通スケールで足元揃え -> <out>_1.png ...
        frames = split_sheet(im, asset["sheet"])
        pad = asset.get("pad", 0.04)
        heights = sorted(body_height(f) for f in frames)
        median_h = heights[len(heights) // 2]
        scale = min(h * asset.get("body_ratio", 0.82) / median_h, min(w * (1 - pad * 2) / f.width for f in frames))
        # keep_frames: 先頭 N コマだけ書き出す (コマ間の描き直しでガタつく待機は 1 コマ + 呼吸 Tween にする)
        frames = frames[:asset.get("keep_frames", len(frames))]
        for i, f in enumerate(frames, 1):
            frame = place(f, w, h, scale, pad, asset.get("anchor"))
            if asset.get("pixel"):
                frame = pixelate(frame, asset["pixel"])
            frame.save(out_path.with_name(f"{out_path.stem}_{i}.png"))
        print(f"[OK] {asset['id']} -> {asset['out']} x{len(frames)} frames {w}x{h}")
        return
    elif asset.get("transparent"):
        # 透明部分をトリムして、枠内に収まるよう縮小 → 中央(下揃え可)に配置
        if from_grid:
            im = clean_grid_cell(im)  # 背景をキーで抜いた後に残ったはみ出しも消す
        im = trim(im)
        pad = asset.get("pad", 0.04)
        scale = min(w * (1 - pad * 2) / im.width, h * (1 - pad * 2) / im.height)
        im = place(im, w, h, scale, pad, asset.get("anchor"))
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

    if asset.get("pixel"):
        im = pixelate(im, asset["pixel"])
    im.save(out_path)
    print(f"[OK] {asset['id']} -> {asset['out']} {w}x{h}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="", help="id prefix filter (comma separated)")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--post-only", action="store_true")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--grid", nargs="?", const="2x2", default=None, type=parse_grid, metavar="COLSxROWS",
                    help="透過アイコンを 列x行 のマスで 1 枚にまとめて描き、マスごとに分割する。"
                         "値なしは 2x2 (4 個/回)、--grid 5x6 なら 30 個/回。カード絵 (category card_art) は常に 2x2。"
                         "refs や sheet を持つアセットは grid にしない")
    ap.add_argument("--manifest", default=str(MANIFEST), help="asset manifest json")
    args = ap.parse_args()

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    style = manifest["style"]
    prefixes = [p for p in args.only.split(",") if p]
    assets = [a for a in manifest["assets"]
              if not prefixes or any(a["id"].startswith(p) for p in prefixes)]
    RAW_DIR.mkdir(exist_ok=True)

    if not args.post_only:
        codex = find_codex()
        todo = [a for a in assets if args.force or not (RAW_DIR / f"{a['id']}.png").exists()]
        # reuse_raw: ほかのアセットの raw をコピーして使う (Codex を呼ばない)。元の raw ができてから処理する
        reuse = [a for a in todo if a.get("reuse_raw")]
        todo = [a for a in todo if a not in reuse]
        grid = [a for a in todo if args.grid and can_grid(a)]
        jobs = []
        for cards in (True, False):  # カード絵と透過アイコンは別の 1 枚にまとめる
            group = [a for a in grid if is_card_art(a) == cards]
            cols, rows = CARD_GRID if cards else args.grid
            n = cols * rows
            jobs += [lambda b=group[i:i + n], c=cols, r=rows: generate_grid(codex, style, b, c, r)
                     for i in range(0, len(group), n)]
        jobs += [lambda a=a: make_raw(codex, style, a) for a in todo if a not in grid]
        print(f"generating {len(todo)} assets in {len(jobs)} Codex calls with {args.workers} workers")
        with ThreadPoolExecutor(args.workers) as ex:
            list(ex.map(lambda job: job(), jobs))
        for a in reuse:
            src = RAW_DIR / f"{a['reuse_raw']}.png"
            if src.exists():
                shutil.copyfile(src, RAW_DIR / f"{a['id']}.png")
            else:
                print(f"[NG] {a['id']}: reuse_raw {src.name} does not exist")

    for a in assets:
        if (RAW_DIR / f"{a['id']}.png").exists():
            post_process(a)


if __name__ == "__main__":
    main()
