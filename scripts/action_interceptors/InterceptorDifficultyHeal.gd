# 難易度 (DifficultyContent): 割合で回復する量 (休憩所など) を、レベルに応じて減らす
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var percent: float = action_interceptor_processor.get_shadowed_action_values("percentage_heal_amount", 1.0)
	action_interceptor_processor.set_shadowed_action_values("percentage_heal_amount", percent * DifficultyContent.get_heal_rate())
	return ACTION_ACCEPTENCES.CONTINUE
