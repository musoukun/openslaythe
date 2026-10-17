class_name ComboContent
## 昇り竜の型 (Ascending Dragon Form): ラン開始時の祝福で選べるコンボの型 (試作)。
## 同じターンに、前に出したカード以上のコストのカードを出すとチェーンが続き、n 枚目はダメージとブロックが +50%×(n-1)。
## 参考: Vampire Crawlers (poncle) のマナ順コンボ。
## 仕組みは BuildContent の武器と同じく、レリック (アイコンの数字 = 今のチェーン) と Action Interceptor で作る。
## GlobalProdDataGenerator.generate_production_data() から register() が呼ばれる。

const ARTIFACT_ID := "artifact_ascending_dragon_form"
const INTERCEPTOR_ID := "interceptor_combo_chain"
const INTERCEPTOR_SCRIPT_PATH := "res://scripts/action_interceptors/InterceptorComboChain.gd"
const ARTIFACT_SCRIPT_PATH := "res://scripts/artifacts/ArtifactComboChain.gd"
const TEXTURE_PATH := "external/sprites/artifacts/artifact_boss_red.png" # 既存の絵を流用
const DESCRIPTION := "Within a turn, playing a card that costs at least as much as the previous one continues the chain. The Nth card of a chain gets +50% damage and Block per link after the first. A cheaper card starts a new chain; the chain ends with your turn."


static func register() -> void:
	var interceptor: ActionInterceptorData = ActionInterceptorData.new(INTERCEPTOR_ID)
	interceptor.action_interceptor_priority = 9600 # 筋力・武器の加算 (10000) の後、弱体・脆弱 (9500 / 9000) の前に掛ける
	interceptor.action_interceptor_modifies_parent = true
	interceptor.action_interceptor_script_path = INTERCEPTOR_SCRIPT_PATH
	interceptor.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_BLOCK]
	Global.register_rod(interceptor)

	var artifact: ArtifactData = ArtifactData.new(ARTIFACT_ID)
	artifact.artifact_name = "Ascending Dragon Form"
	artifact.artifact_description = DESCRIPTION
	artifact.artifact_texture_path = TEXTURE_PATH
	artifact.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact.artifact_appears_in_artifact_packs = false
	artifact.artifact_script_path = ARTIFACT_SCRIPT_PATH
	artifact.artifact_interceptor_ids = [INTERCEPTOR_ID]
	artifact.artifact_counter_max = 99
	Global.register_rod(artifact)

	var option: RunStartOptionData = RunStartOptionData.new("run_start_option_" + ARTIFACT_ID)
	option.run_start_option_bb_code = "[color=green]Learn Ascending Dragon Form[/color]: Play cards in rising cost order; each link of the chain adds +50% damage and Block."
	option.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	option.run_start_option_actions = [{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": ARTIFACT_ID}}]
	Global.register_rod(option)
