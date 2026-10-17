class_name CardShine
## カードのレア加工の輝き (sprites/shaders/card_shine.gdshader) の段階を決める。
## 段階は「このターンのコンボ (使った枚数)」と「そのカード自身の成長」の高いほう。
##   コンボ: COMBO_THRESHOLDS の枚数を超えるごとに 1 段階ずつ上がる (ターン開始で 0 に戻る)
##   成長: 強化済みで 1。ルカの蒼刃は、刃を伸ばす・刃を重ねるの強化に応じて上がる

const SHADER := preload("res://sprites/shaders/card_shine.gdshader")
const TIER_NAMES: Array[String] = ["", "RARE!", "SUPER RARE!", "ULTRA RARE!", "SECRET RARE!", "PARALLEL RARE!!"]
const TIER_COLORS: Array[Color] = [Color.WHITE, Color("#dfe8ff"), Color("#ffd35a"), Color("#7fe3ff"), Color("#ffffff"), Color("#ff8af0")]
const MAX_TIER := 5
## このターンに使った枚数がこれ以上になると、段階が 1, 2, 3, 4, 5 になる
const COMBO_THRESHOLDS: Array[int] = [2, 4, 6, 8, 10]
## 蒼刃の成長: 刃を伸ばす 6 ダメージぶんで 1 段階、刃を重ねる 1 回で 2 段階
const BLADE_EDGE_PER_TIER := 6
const BLADE_TWIN_TIERS := 2


static func combo_tier(combo: int) -> int:
	var tier := 0
	for threshold in COMBO_THRESHOLDS:
		if combo >= threshold:
			tier += 1
	return tier


static func growth_tier(card_data: CardData) -> int:
	var tier := 1 if card_data.card_upgrade_amount > 0 else 0
	if card_data.card_tags.has(HeroBlueContent.TAG_MANA_BLADE):
		var player: Player = Global.get_player()
		if player:
			tier += player.get_status_charges(HeroBlueContent.STATUS_BLADE_EDGE) / BLADE_EDGE_PER_TIER
			tier += player.get_status_charges(HeroBlueContent.STATUS_BLADE_TWIN) * BLADE_TWIN_TIERS
	return mini(tier, MAX_TIER)


static func tier_for(card_data: CardData) -> int:
	return maxi(combo_tier(Vfx.combo_count()), growth_tier(card_data))


## カードの見た目 (card_visual) に重ねる輝きの板を作る
static func create_overlay(size: Vector2) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.name = "CardShine"
	overlay.size = size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("card_size", size)
	material.set_shader_parameter("phase", randf() * 10.0)
	overlay.material = material
	overlay.visible = false
	return overlay


static func apply(overlay: ColorRect, tier: int) -> void:
	overlay.visible = tier > 0
	(overlay.material as ShaderMaterial).set_shader_parameter("tier", tier)
