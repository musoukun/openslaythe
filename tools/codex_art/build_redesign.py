"""絵の作り直し (issue #35) の manifest を作る.

方針: 描き込みはいまの 7 割。デフォルメしてよい。アイテムは形 (シルエット) が全部違う。
カードは名前と絵柄で情景が浮かぶ場面の絵 (主人公が技を出している姿ごと描く)。
敵・背景は今の形と配置の条件を残して、画風だけ描き込みを減らす。

  python tools/codex_art/build_redesign.py      # 下の 3 つの manifest を書き出す
  python tools/codex_art/generate.py --grid --force --manifest tools/codex_art/redesign_world_assets.json
  python tools/codex_art/generate.py --grid --force --manifest tools/codex_art/redesign_hero_green_icons.json
  python tools/codex_art/generate.py --grid --force --manifest tools/codex_art/redesign_hero_green_cards.json
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent

SIMPLE = (
    "Simplified, chunky stylized fantasy game art with about 30 percent less detail than a typical painted fantasy "
    "asset: a few big readable shapes, thick dark-brown outlines, flat color masses with two-step cel shading and one "
    "soft highlight, very little texture. No filigree, no tiny rivets, no engraved patterns, no gem encrustations, no "
    "pedestals, stands or display bases, no ornate frames. Light deformation is welcome (exaggerate the one key part, "
    "simplify the rest); cute but not childish. Saturated but harmonious colors. Do not imitate any existing game, "
    "character, franchise or official artwork. Include no text, letters, numerals, logos or symbols."
)

WORLD_STYLE = SIMPLE + (
    " This art belongs to the SHARED WORLD that every playable hero visits, so it must never show or hint at any "
    "hero: no dragon scales, claws, tails, wings, horns or dragon fire, and no people. The world is an original realm "
    "of enchanted forest ruins with moss-covered pale stone, tarnished bronze, clockwork stone golems and teal rune light."
)

ICON = ("One single object, three-quarter view, centered, filling about 80 percent of its cell, readable at 48px by its "
        "silhouette alone; one dominant hue. Transparent background, no ground shadow, no stand.")

# レリックとポーション: それぞれ違う形の身近な物ひとつ
WORLD_ICONS = {
    "artifact_add_money": "A tipped-over round clay jar spilling a few chunky gold coins.",
    "artifact_negate_money_gain": "A squat iron piggy bank wrapped in one thick chain with a big padlock, a small yellow spark leaking from its coin slot.",
    "artifact_heal_on_combat_ended": "A shiny red apple with one green leaf and a small bite taken out.",
    "artifact_full_heal": "A steaming wooden bowl of soup with a wooden spoon sticking out, warm orange broth.",
    "artifact_draw_on_kill": "A curved hunting knife with a single blank playing card pinned on its tip.",
    "artifact_draw_on_combat_start": "A proud rooster-shaped weathervane on a short iron arrow, bright red comb.",
    "artifact_energy_on_combat_start": "A fat ceramic mug of hot tea with big curls of steam, sky-blue glaze.",
    "artifact_easy_mode": "A fluffy pink feather duster with a short wooden handle.",
    "artifact_block_on_attacks": "A round wooden buckler shield with three deep notches cut into its rim and an iron boss.",
    "artifact_retain_hand": "A plump jar of golden honey with a wooden honey dipper, honey dripping down the side.",
    "artifact_preserve_energy": "A corked glass mason jar holding three glowing yellow fireflies.",
    "artifact_increase_attack_on_rest": "A crude training dumbbell made of two round grey stones lashed to a wooden stick.",
    "artifact_see_top_of_draw_pile": "A single round brass monocle on a short curling chain, a bright glint on the lens.",
    "artifact_top_deck_attack_card": "A jack-in-the-box: a small wooden box with a red boxing glove springing out on a coiled spring.",
    "artifact_right_click_shuffle_deck": "A whirling wooden spinning top with red and white stripes, motion swoosh around it.",
    "artifact_boss_red": "A crimson war drum with two crossed drumsticks resting on top.",
    "artifact_shop_red": "A single glossy red chili pepper with a curled green stem.",
    "artifact_boss_blue": "A round cobalt-blue teapot with a tall curved spout and a little knob lid.",
    "artifact_shop_blue": "A blue paper lantern, round and ribbed, with a warm glow inside.",
    "artifact_boss_orange": "A carved orange pumpkin lantern with a cheeky grin and candle light inside.",
    "artifact_shop_orange": "A plump orange mushroom with big white spots and a thick stem.",
    "artifact_boss_white": "A white porcelain theater mask with a calm closed-eye smile and a thin crack.",
    "artifact_shop_white": "A white origami paper crane with sharp folded wings.",
    "artifact_blue_earring": None,  # Luca (青) は別で作り直すので作らない
    "consumable_heal": "A round-bellied red potion flask with a heart-shaped cork stopper.",
    "consumable_block": "A short wide teal potion bottle shaped like a little shield, with an iron screw cap.",
    "consumable_damaging": "A black round bomb-shaped potion flask with a short lit fuse spitting sparks.",
    "consumable_multi_damaging": "A purple triangular potion flask with three sparks bursting out of its open neck.",
}

# 主人公 (Vera) 専用のレリック: 竜の鱗・爪・炎を使ってよい
HERO_ICON_STYLE = SIMPLE + (
    " These icons belong to the half-dragon warrior heroine and may use her motifs: copper-red dragon scales, "
    "black-iron dragon claws with ember-orange cracks, crimson dragon blood and ember fire. Palette: blackened iron "
    "#2A2426, copper-red #B5532E, crimson #8E1B23, ivory #EFE2C4, ember #FF8A2A."
)
HERO_ICONS = {
    "artifact_boss_green": "A smoldering black ember stone shaped like a heart, glowing orange cracks, small flame wisps on top.",
    "artifact_shop_green": "A single big copper-red dragon scale hanging on a leather cord necklace.",
    "artifact_weapon_reactor_gauntlet": "One copper-red scaled gauntlet ending in four curved black-iron claws, wrapped in licking orange flames.",
    "artifact_weapon_pruning_blade": "Four curved black-iron dragon claws laid fanned out on a flat grey whetstone, a bright sharpening glint.",
    "artifact_ascending_dragon_form": "A crimson silk ribbon spiraling upward like a rising staircase, ending in a small ember flame at the top.",
}

# 主人公の緑カード: 名前から情景が浮かぶ場面。背景色はカードごとに変える
CARD = ("Square card illustration, full bleed, opaque background. A clear small scene: {scene} Simple background made "
        "of two or three big shapes, dominant background color: {bg}. One focal point, readable at 96px.")
HERO_CARD_STYLE = SIMPLE + (
    " Card illustrations for the half-dragon warrior heroine (the attached reference). Each card is a small dynamic "
    "scene that makes the card's name easy to remember: show her full figure or three-quarter figure performing the "
    "action, with her face drawn as in the reference (anime-style, amber dragon eyes, mischievous grin). Enemies are "
    "chunky moss-covered stone-and-bronze golems with teal rune eyes. Each card uses its own dominant background "
    "color so the cards look clearly different from each other."
)
HERO_CARDS = {
    "card_basic_attack_green": ("Slash", "she lunges forward with a big diagonal claw swipe, three orange claw streaks across a stone golem.", "dusk orange"),
    "card_basic_block_green": ("Brace", "she crouches behind crossed scaled gauntlets as a golem fist slams into them, sparks flying.", "steel blue"),
    "card_blossom": ("Rekindle", "she kneels with eyes closed, cupping a small warm flame to her chest, a soft healing glow around her.", "warm amber"),
    "card_bud": ("Bristling Scales", "the scales on her arms and tail bristle up like spikes, a golem pulls back its pricked hand.", "crimson"),
    "card_cell_wall": ("Harden Scales", "she flexes as her forearm scales turn glossy and rock-hard, a golem's bronze spear snapping against them.", "slate grey"),
    "card_chloroplast": ("Wildfire Orb", "she holds a big swirling orb of fire above her head, about to hurl it.", "night violet"),
    "card_clippers": ("Twin Claws", "she spins with both claw hands slashing in an X, two crossing orange streaks.", "teal"),
    "card_differentiation": ("Reckless Rend", "she tears through a golem's chest plate while flying stone shards cut her own arm.", "blood red"),
    "card_fertilize": ("Blood Kindling", "a drop of her blood falls from her bitten thumb and bursts into flame, two ember orbs rising.", "black and crimson"),
    "card_fruit": ("Dragon Egg", "she hugs a big copper-red speckled egg glowing from inside, grinning in surprise.", "moss green"),
    "card_growth": ("Shed Skin", "she steps out of a translucent peeled shell of old scales like a snake's shed, shining fresh.", "pale jade"),
    "card_lotus": ("Layered Scales", "rings of floating translucent red scales stack around her like layered armor plates.", "deep teal"),
    "card_moss": ("Scale Bash", "she shoulder-charges a golem with her armored shoulder, the golem cracking in half.", "ochre"),
    "card_pollen": ("Fever Dream", "she sways dizzy and sweating inside a swirl of ember spirals and floating eyes, cards drifting out of the haze.", "sickly purple-green"),
    "card_petals": ("Wing Shroud", "she wraps herself in her translucent ember-fire wings like a cocoon, stone arrows bouncing off.", "indigo night"),
    "card_reap": ("Devour", "she rips a glowing teal rune core out of a golem, its light flowing into her.", "dark green"),
    "card_wildflower": ("Wrath Claw", "bruised and furious with a cut on her cheek, she counter-slashes with blazing claws.", "hot red-orange"),
    "card_symbiosis": ("Dragonhide", "she stands proud, her whole body covered in a gleaming living armor of copper scales, a golem's hammer bouncing off.", "bronze"),
    "card_thorns": ("Spined Guard", "she crouches behind her spiked shoulder guards with her spiked tail curled around her, a golem pricking its fist.", "dark olive"),
    "card_verdant": ("Unbreakable Hide", "a huge golem hammer slams onto her raised forearm and the hammer cracks instead.", "stone grey with an orange impact flash"),
    "card_vines": ("Tail Lash", "she spins and her long crimson tail sweeps three small golems off their feet.", "sunset orange"),
    "card_conclusion": ("Banked Flame", "she shelters a small but intense flame inside a little clay brazier, saving it for later.", "dim brown"),
    "card_datum": ("Mirror Scale", "she holds up one big polished red scale that reflects her own face, a ghostly copy of the scale beside it.", "silver-blue"),
    "card_photoelectric_synthesis": ("Dragon Awakening", "she roars with fire wings fully spread and blazing eyes, a giant dragon shape of flame rising behind her.", "blazing gold"),
    "card_big_boom": ("Inferno", "she slams both fists into the ground and a ring of fire explodes outward through the golems.", "red-orange"),
    "card_containment": ("Swallow the Fire", "she gulps a stream of fire into her mouth, cheeks glowing, embers falling into her hands.", "dark teal"),
    "card_critical": ("Boiling Blood", "steam rises from her body, her veins glow orange, she grits her teeth.", "deep maroon"),
    "card_feedback_loop": ("Fire Feeds Fire", "two flames chase each other in a loop around her, one feeding the other.", "dark violet"),
    "card_fusion_cannon": ("Cinder Volley", "she flings a barrage of glowing cinder chunks from both hands at a line of golems.", "ash grey"),
    "card_meltdown": ("Searing Breath", "she breathes a cone of fire at a golem, its stone face glowing red.", "night blue"),
    "card_particle_accelerator": ("Stoke the Heart", "she punches her own chest and a burst of flame flares out of her heart.", "crimson"),
    "card_unstable": ("Flare Up", "her whole body suddenly erupts in flame, hair flying, cards flipping up into the air around her.", "yellow-orange"),
    "card_waste": ("Cinder", "close-up of her open clawed palm holding a smoldering lump of black cinder with orange cracks and smoke.", "ashen grey"),
    "card_green_heat_scales": ("Heatproof Scales", "she stands calmly knee-deep in a lava pool, unharmed, her scales glowing hot.", "lava orange and black"),
    "card_green_searing_claw": ("Searing Claw", "her single claw slash leaves a molten glowing cut across a golem's stone body.", "dark teal"),
    "card_green_frenzied_claws": ("Frenzied Claws", "she is a blur of many flurrying claw arms, motion lines everywhere.", "magenta-red"),
    "card_green_sharpen_claws": ("Sharpen Claws", "she sits on a rock sharpening her claws on a whetstone, sparks flying, focused smirk.", "twilight moss green"),
    "card_green_claw_flurry": ("Dragon Claw Flurry", "she leaps above a golem and rains down many claw streaks.", "purple sky"),
    "card_green_blood_pact": ("Blood Pact", "she presses her bleeding palm on an ancient rune stone, the stone glows and cards fan out of the light.", "dark crimson and teal"),
    "card_green_cauterize": ("Cauterize", "she presses a flaming claw to a cut on her arm, wincing, steam hissing.", "dim amber"),
}

WHITE_CARD = {
    "card_energy_next_turn": "A tall hourglass filled with glowing yellow light-sand standing on a mossy stone, sunrise behind the forest ruins. No people.",
}


def load(name: str) -> dict:
    return json.loads((HERE / name).read_text(encoding="utf-8"))


def old_entry(manifests: list, asset_id: str) -> dict:
    for m in manifests:
        for a in m["assets"]:
            if a["id"] == asset_id:
                return a
    raise KeyError(asset_id)


def write(name: str, style: str, assets: list) -> None:
    (HERE / name).write_text(json.dumps({"style": style, "assets": assets}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{name}: {len(assets)} assets")


def main() -> None:
    old = [load(n) for n in ("assets.json", "hero_ui_assets.json", "enemy_assets.json", "world_assets.json", "realm_assets.json")]

    world = []
    for asset_id, prompt in WORLD_ICONS.items():
        if prompt is None:
            continue
        kind = "consumables" if asset_id.startswith("consumable") else "artifacts"
        world.append({"id": asset_id, "out": f"external/sprites/{kind}/{asset_id}.png", "size": [128, 128],
                      "transparent": True, "category": "icon", "prompt": f"{prompt} {ICON}"})
    # 敵: 形と配置の条件は今の指示文のまま、重要なので 1 回 2 体
    for asset_id in ("enemy_1", "enemy_2", "enemy_3", "enemy_4", "enemy_minion_1", "enemy_minion_2",
                     "enemy_act_1_miniboss_1", "enemy_act_1_miniboss_2", "enemy_act_1_boss_1"):
        a = dict(old_entry(old, asset_id))
        a.pop("brief", None)
        a["per_call"] = 1 if asset_id == "enemy_act_1_boss_1" else 2
        a["prompt"] = "Chunky simplified version with big shapes and little surface detail. " + a["prompt"]
        world.append(a)
    # 背景: 1 枚ずつ
    for asset_id in ("world_act_1", "world_act_2", "world_act_3", "world_rest_site"):
        a = dict(old_entry(old, asset_id))
        a.pop("brief", None)
        a["prompt"] = ("Painted as a simplified stage: fewer, larger shapes, flat color planes with soft gradients, "
                       "no small leaves, pebbles or tiny props, quiet low-detail background. " + a["prompt"])
        world.append(a)
    for asset_id, prompt in WHITE_CARD.items():
        world.append({"id": asset_id, "out": "external/sprites/cards/white/card_energy_next_turn.png", "size": [384, 384],
                      "transparent": False, "category": "card_art",
                      "prompt": f"Square card illustration, full bleed, opaque background. {prompt}"})
    write("redesign_world_assets.json", WORLD_STYLE, world)

    hero_icons = [{"id": asset_id, "out": f"external/sprites/artifacts/{asset_id}.png", "size": [128, 128],
                   "transparent": True, "category": "icon", "prompt": f"{prompt} {ICON}"}
                  for asset_id, prompt in HERO_ICONS.items()]
    write("redesign_hero_green_icons.json", HERO_ICON_STYLE, hero_icons)

    cards = []
    for asset_id, (name, scene, bg) in HERO_CARDS.items():
        cards.append({"id": asset_id, "out": f"external/sprites/cards/green/{asset_id}.png", "size": [384, 384],
                      "transparent": False, "category": "card_art", "per_call": 2, "crop_align": 0.1,
                      "refs": ["tools/codex_art/refs/hero_master.png"],
                      "prompt": f"Card '{name}': " + CARD.format(scene=scene, bg=bg)})
    write("redesign_hero_green_cards.json", HERO_CARD_STYLE, cards)


if __name__ == "__main__":
    main()
