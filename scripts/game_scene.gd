extends Node2D
@onready var fade_transition: ColorRect = $fade_transition

func _ready() -> void:
	$fade_transition/AnimationPlayer.play("fade_out")
