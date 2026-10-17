class_name DifficultyContent
## 難易度 (レベル 0〜5)。レベル 0 が基本で、クリアするたびに次のレベルが 1 つ解禁される (NewRunMenu / StatsHandler)。
## レベルが上がると、ボス戦の敵の火力と HP が少しずつ上がり、回復量 (幕の開始・休憩所・割合での回復) が下がる。
## 元の「難易度で敵の数値を切り替える」仕組み (DIFFICULTY_*_HARDER) は使わない (GlobalProdDataGenerator で無効にしてある)。
## GlobalProdDataGenerator.add_run_modifiers() の最後で register() が呼ばれる。

## レベルごとの値 (添字 = レベル)
const BOSS_DAMAGE_BONUS: Array[float] = [0.0, 0.02, 0.04, 0.08, 0.10, 0.16]
const BOSS_HEALTH_BONUS: Array[float] = [0.0, 0.10, 0.20, 0.30, 0.40, 0.60]
const HEAL_RATE: Array[float] = [1.0, 0.95, 0.90, 0.85, 0.80, 0.75]

const INTERCEPTOR_BOSS_DAMAGE := "interceptor_difficulty_boss_damage"
const INTERCEPTOR_HEAL := "interceptor_difficulty_heal"


static func register() -> void:
	var boss_damage: ActionInterceptorData = ActionInterceptorData.new(INTERCEPTOR_BOSS_DAMAGE)
	boss_damage.action_interceptor_priority = 9000 # 脆弱と同じく、受ける側 (プレイヤー) で掛ける
	boss_damage.action_interceptor_modifies_parent = false
	boss_damage.action_interceptor_script_path = "res://scripts/action_interceptors/InterceptorDifficultyBossDamage.gd"
	boss_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]
	Global.register_rod(boss_damage)

	var heal: ActionInterceptorData = ActionInterceptorData.new(INTERCEPTOR_HEAL)
	heal.action_interceptor_priority = 9000
	heal.action_interceptor_modifies_parent = false
	heal.action_interceptor_script_path = "res://scripts/action_interceptors/InterceptorDifficultyHeal.gd"
	heal.action_intercepted_action_paths = [Scripts.ACTION_HEAL_PERCENT]
	Global.register_rod(heal)

	# レベル 1 以上のランには difficulty_1 の修飾が必ず付くので、Interceptor はそこにだけ付ける (値はレベルの表から読む)
	var level_1: RunModifierData = Global.get_run_modifier_data(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS[1])
	level_1.run_modifier_interceptor_ids = [INTERCEPTOR_BOSS_DAMAGE, INTERCEPTOR_HEAL]

	# 新しいラン画面に出るレベルの名前 (効果を名前に書く)
	for level in range(1, len(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS)):
		var modifier: RunModifierData = Global.get_run_modifier_data(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS[level])
		modifier.run_modifier_name = get_level_name(level)


static func get_level_name(level: int) -> String:
	return "Difficulty %d: Boss HP +%d%%, damage +%d%%, healing %d%%" % [level,
		roundi(BOSS_HEALTH_BONUS[level] * 100), roundi(BOSS_DAMAGE_BONUS[level] * 100), roundi(HEAL_RATE[level] * 100)]


static func get_level() -> int:
	return clampi(Global.player_data.player_run_difficulty_level, 0, len(HEAL_RATE) - 1)


static func is_boss_fight() -> bool:
	var location: LocationData = Global.get_player_location_data()
	return location != null and location.location_type == LocationData.LOCATION_TYPES.BOSS


static func get_heal_rate() -> float:
	return HEAL_RATE[get_level()]


## ボス戦の敵の最大 HP を増やす (Combat が敵を並べた直後に呼ぶ)
static func apply_boss_health(enemies: Array[Enemy]) -> void:
	var bonus: float = BOSS_HEALTH_BONUS[get_level()]
	if bonus <= 0.0 or not is_boss_fight():
		return
	for enemy: Enemy in enemies:
		var health_max: int = roundi(enemy.get_combatant_health_max() * (1.0 + bonus))
		enemy.set_health(health_max, health_max)


## ボス戦で敵から受けるダメージ (小さい攻撃では 2% などは四捨五入で変わらないことがある)
static func get_boss_damage(damage: int) -> int:
	var bonus: float = BOSS_DAMAGE_BONUS[get_level()]
	if bonus <= 0.0 or not is_boss_fight():
		return damage
	return roundi(damage * (1.0 + bonus))
