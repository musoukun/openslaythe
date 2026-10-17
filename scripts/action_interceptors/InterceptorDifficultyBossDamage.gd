# 難易度 (DifficultyContent): ボス戦で敵から受けるダメージを、レベルに応じて少し増やす
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	if not action_interceptor_processor.parent_action.parent_combatant is Enemy:
		return ACTION_ACCEPTENCES.CONTINUE
	var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
	action_interceptor_processor.set_shadowed_action_values("damage", DifficultyContent.get_boss_damage(damage))
	return ACTION_ACCEPTENCES.CONTINUE
