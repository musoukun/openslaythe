extends Control

@onready var turn_label: Label = $TurnLabel

func update_turn_label() -> void:
	# called from animation player
	turn_label.text = tr("Turn %s") % StatsHandler.get_turn_count()
