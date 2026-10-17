## 昇り竜の型 (ComboContent)。カードを出すたびにチェーンを進め、今のチェーンの長さをアイコンの数字で見せる。
## 倍率の計算は InterceptorComboChain。チェーンはターンの始め・終わりと戦闘の終わりに途切れる。
extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_play_started.connect(_on_card_play_started)

func _on_card_play_started(card_play_request: CardPlayRequest) -> void:
	if card_play_request.card_data == null:
		return
	var link: int = InterceptorComboChain.advance(card_play_request)
	artifact_data.set_artifact_counter(link)

func _on_player_turn_started() -> void:
	super()
	_break_chain()

func _on_player_turn_ended() -> void:
	super()
	_break_chain()

func _on_combat_ended() -> void:
	super()
	_break_chain()

func _break_chain() -> void:
	InterceptorComboChain.reset()
	artifact_data.set_artifact_counter(0)
