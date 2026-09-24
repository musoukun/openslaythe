"""ゲームデータ (GlobalProdDataGenerator.gd) からアセット枠 slots.json を作る.

slots.json は「どのファイルを・どのサイズで・何のために」作るかの技術仕様だけを持つ。
デザイン (prompt) は Codex が assets.json に書く。
"""
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
SRC = (REPO / "autoload/GlobalProdDataGenerator.gd").read_text(encoding="utf-8")


def objects(cls: str):
    for var, oid in re.findall(r'var (\w+): %s = %s\.new\("([^"]+)"' % (cls, cls), SRC):
        def field(suffix):
            m = re.search(r'\n\t%s\.(\w*%s) = "([^"]*)"' % (re.escape(var), suffix), SRC)
            return m.group(2) if m else ""
        typ = re.search(r'\n\t%s\.card_type = CardData\.CARD_TYPES\.(\w+)' % re.escape(var), SRC)
        yield oid.format("green"), field("_name"), field("_description"), typ.group(1) if typ else ""


slots = []


def add(id_, out, size, transparent, brief, **extra):
    slots.append({"id": id_, "out": out, "size": list(size), "transparent": transparent, "brief": brief, **extra})


# --- cards ---
BASIC = {"card_basic_attack_green": ("Basic Attack", "Deal 7 damage.", "ATTACK"),
         "card_basic_block_green": ("Basic Block", "Gain 5 block.", "SKILL")}
for oid, name, desc, typ in objects("CardData"):
    if oid in BASIC:
        name, desc, typ = BASIC[oid]
    color = "white" if oid == "card_energy_next_turn" else "green"
    add(oid, f"external/sprites/cards/{color}/{oid}.png", (192, 192), False,
        f"Card illustration for card '{name}' ({typ}): {desc}", category="card_art")
for t in ["attack", "skill", "power", "status"]:
    add(f"frame_{t}", f"sprites/ui/card_frame_{t}.png", (288, 368), True,
        f"Card frame for {t.upper()} cards. Portrait 144:184. Upper square art window (about x 17%-83%, y 6%-59%) "
        "and lower text plate (y 61%-98%) must be plain dark flat areas so art/text can be overlaid. "
        "Cost gem slot at top-left corner.", category="card_frame")
for c in ["green", "white"]:
    add(f"energy_{c}", f"external/sprites/colors/{c}_energy_icon.png", (128, 128), True,
        f"Energy (mana) orb icon for the {c} card color, shown in the card cost corner", category="icon")

# --- map ---
add("map_background", "sprites/ui/map_background.png", (1200, 700), False,
    "Map screen background: top-down overworld map the player travels through. Center area should be calm/low contrast so node icons stay readable.",
    category="map")
for loc in ["combat", "miniboss", "boss", "event", "treasure", "shop", "rest_site"]:
    add(f"map_{loc}", f"sprites/map/location_{loc}.png", (128, 128), True,
        f"Map node icon for location type {loc.upper()}", category="map_icon")

# --- backgrounds ---
for i in [1, 2, 3]:
    add(f"bg_act_{i}", f"external/sprites/backgrounds/act_{i}.png", (1200, 700), False,
        f"Combat background for Act {i}. Side view stage; player stands left-center, enemies right; lower 30% is covered by cards so keep it simple.",
        category="background")
add("bg_title", "sprites/ui/title_background.png", (1200, 700), False,
    "Title screen key art. Left third is covered by menu buttons, top-center has the logo text (rendered by the game), so keep those areas quieter.",
    category="background")

# --- combatants ---
add("character_green", "external/sprites/characters/character_green/character_green.png", (256, 256), True,
    "Player character 'The Botanist': a former thermonuclear botanist fired for their experiments. Faces RIGHT. Full body.",
    category="combatant", anchor="bottom")
add("character_green_icon", "external/sprites/characters/character_green/character_green_icon.png", (128, 128), True,
    "Portrait icon (bust) of The Botanist for character select", category="icon")
ENEMY_SIZE = {"enemy_act_1_boss_1": 300, "enemy_act_1_miniboss_1": 220, "enemy_act_1_miniboss_2": 220, "enemy_4": 200}
for oid, name, desc, _ in objects("EnemyData"):
    s = ENEMY_SIZE.get(oid, 160)
    add(oid, f"external/sprites/enemies/{oid}.png", (s, s), True,
        f"Enemy '{oid}' (placeholder name '{name}', role: {'boss' if 'boss_1' in oid else 'miniboss' if 'miniboss' in oid else 'minion' if 'minion' in oid else 'regular enemy'}). Faces LEFT. Full body.",
        category="combatant", anchor="bottom")
for it in ["attacking", "blocking", "buffing", "debuffing", "summoning"]:
    add(f"intent_{it}", f"sprites/intents/enemy_intent_{it}.png", (128, 128), True,
        f"Enemy intent icon: enemy is {it} next turn. Must read instantly at 32px.", category="icon")

# --- small icons ---
for oid, name, desc, _ in objects("StatusEffectData"):
    add(oid, f"external/sprites/status_effects/{oid}.png", (96, 96), True,
        f"Status effect icon '{name}'. Shown at 24px, must be bold and simple.", category="icon")
for oid, name, desc, _ in objects("ArtifactData"):
    add(oid, f"external/sprites/artifacts/{oid}.png", (128, 128), True,
        f"Relic/artifact item icon '{name}': {desc}", category="icon")
for oid, name, desc, _ in objects("ConsumableData"):
    add(oid, f"external/sprites/consumables/{oid}.png", (128, 128), True,
        f"Consumable potion/item icon '{name}': {desc}", category="icon")
for ui in ["deck", "map", "pause", "draw_pile", "discard_pile", "exhaust_pile", "block", "gold", "health"]:
    add(f"ui_{ui}", f"sprites/ui/icon_{ui}.png", (128, 128), True, f"HUD icon: {ui.replace('_', ' ')}", category="icon")
add("ui_chest", "sprites/ui/chest.png", (256, 256), True, "Treasure chest (closed) shown in treasure room", category="icon")
add("ui_shop", "sprites/ui/shop.png", (256, 256), True, "Shop merchant stall/shopkeeper shown to enter the shop", category="icon")

(HERE / "slots.json").write_text(json.dumps(slots, indent=1, ensure_ascii=False), encoding="utf-8")
print(len(slots), "slots")
