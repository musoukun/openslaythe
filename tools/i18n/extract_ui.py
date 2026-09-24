"""シーン(.tscn)の固定 UI 文字列と、スクリプト内で UI に設定される文字列リテラルを抽出する."""
import glob
import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
QUOTED = r'"((?:[^"\\]|\\.)*)"'
strings = {}


def add(text: str, source: str) -> None:
    text = text.replace('\\"', '"').replace("\\n", "\n")
    if re.search(r"[A-Za-z]{2,}", text):
        strings.setdefault(text, source)


for f in glob.glob(str(REPO / "scenes/**/*.tscn"), recursive=True):
    for m in re.finditer(r'^(?:text|tooltip_text|placeholder_text) = ' + QUOTED, Path(f).read_text(encoding="utf-8"), re.M):
        add(m.group(1), "scene:" + Path(f).name)

# スクリプトで UI に入れるリテラル
code_pat = re.compile(r'(?:\.text\s*\+?=\s*|tooltip_text\s*\+?=\s*|\btr\(|parse_bbcode\(|set_bbcode\(|append_text\()' + QUOTED)
for f in glob.glob(str(REPO / "scripts/**/*.gd"), recursive=True):
    for m in code_pat.finditer(Path(f).read_text(encoding="utf-8")):
        add(m.group(1), "code:" + Path(f).name)

out = REPO / "tools/i18n/ui_strings.json"
out.write_text(json.dumps(strings, indent=1, ensure_ascii=False), encoding="utf-8")
print(len(strings), "ui strings")
