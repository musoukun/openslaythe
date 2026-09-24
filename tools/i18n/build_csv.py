"""ja.json ({英語: 日本語}) から Godot 用翻訳 CSV (localization/strings.csv) を作る."""
import csv
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
OUT = REPO / "localization/strings.csv"

ja = json.loads((HERE / "ja.json").read_text(encoding="utf-8"))
OUT.parent.mkdir(exist_ok=True)
with OUT.open("w", encoding="utf-8", newline="") as f:
    w = csv.writer(f, quoting=csv.QUOTE_ALL)
    w.writerow(["keys", "ja"])
    for en, jp in sorted(ja.items()):
        w.writerow([en, jp])
print(len(ja), "rows ->", OUT.relative_to(REPO))
