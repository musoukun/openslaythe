"""翻訳キー一覧 (keys.json) を作る: データ文字列 + UI 文字列 + コード内の固定語."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent

# UI に出ないダミー表示 (エディタ用プレースホルダ) は除外
PLACEHOLDERS = {
    "Test", "test", "Card Name", "Card Type", "If you can see this something is wrong", "Act Name",
    "Color", "Attack Name", "Intent Description", "Reward 1", "999x Very Long Card Name", "Consumable Name",
    "Run Name", "Rest Action", "Name", "Enemy Name", "Character Name", "Character Description",
    "Artifact Name", "Description ", "HH:MM:SS", "[center]", "Victory/Death Message", "Death or Victory Message",
    "[color=Orange][Keyword][/color] description here", "[color=green]Dialogue Prompt Rich Text[/color]",
    "HP: 80 - 90 | 120 - 130 (D2) | 150 - 160 (D3)", "Win rate: XX.XX%", "Play Time: HHHH:MM:SS",
    "Fastest Run: HH:MM:SS", "HP: 100/100", "Money: 99999", "End Time: HH:MM:SS", "Floor: 999",
    "Run Seed", "Run Completion Date", "Wins: 0", "Losses: 0", "Current Win Streak: 0", "Highest Win Streak: 0",
    "Current Loss Streak: 0", "Highest Loss Streak: 0", "Difficulty 0", "Pick X cards", "Pick X Cards",
    "Project Wiki and Tutorials", "Support the Creator", "Petal Fallout",
}

# コード内で tr() している固定語
EXTRA = {
    # カードのレアリティ / タイプ (CardData の enum 名)
    "BASIC": "card rarity", "COMMON": "card rarity", "UNCOMMON": "card rarity", "RARE": "card rarity",
    "GENERATED": "card rarity", "ATTACK": "card type", "SKILL": "card type", "POWER": "card type",
    "STATUS": "card type", "CURSE": "card type",
    # カードのキーワードタグ
    "Top Deck": "card keyword", "Bottom Deck": "card keyword", "Unplayable": "card keyword",
    "Retain": "card keyword", "Ethereal": "card keyword", "Exhaust": "card keyword", "Banish": "card keyword",
    "Blocked": "combat popup",
    # マップのロケーション名
    "Combat": "map location", "Miniboss": "map location", "Boss": "map location", "Event": "map location",
    "Treasure": "map location", "Shop": "map location", "Rest site": "map location",
    "Money %s": "reward button",
}

keys = {}
for name in ["data_strings.json", "ui_strings.json"]:
    for k, v in json.loads((HERE / name).read_text(encoding="utf-8")).items():
        if k not in PLACEHOLDERS:
            keys.setdefault(k, v)
for k, v in EXTRA.items():
    keys.setdefault(k, v)
(HERE / "keys.json").write_text(json.dumps(keys, indent=1, ensure_ascii=False), encoding="utf-8")
print(len(keys), "keys")
