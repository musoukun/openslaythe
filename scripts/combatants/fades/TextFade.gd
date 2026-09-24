## provides a basic text which fades above a combatant
extends Node2D
class_name TextFade

## ダメージ数字のポップ演出
const POP_DURATION := 0.18
const JITTER_X := 18.0

@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer
@onready var label: Label = $Label

func _ready():
	animation_player.animation_finished.connect(_on_fade_animation_finished)

func init(fade_text: String, font_color: Color = Color.WHITE) -> void:
	label.text = fade_text
	# 共有リソースを書き換えないよう複製してから色を変える
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color = font_color
	animation_player.play("fade")

## 大きく出てから縮む。strength はダメージ量などに応じた初期倍率 (1.0 以上)
func pop(strength: float) -> void:
	position.x += randf_range(-JITTER_X, JITTER_X)
	scale = Vector2.ONE * strength
	var target := Vector2.ONE * (1.0 + (strength - 1.0) * 0.35)
	create_tween().tween_property(self, "scale", target, POP_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_fade_animation_finished(_anim_name: String):
	queue_free()
