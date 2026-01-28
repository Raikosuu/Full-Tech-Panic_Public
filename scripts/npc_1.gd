extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

@export var move_speed: float = 50.0
@export var loop_path: bool = false

var last_position: Vector2



func _update_animation(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		# No movement → idle
		anim_sprite.play("idle")
	else:
		# Horizontal movement dominates
		if abs(movement.x) > abs(movement.y):
			if movement.x > 0:
				anim_sprite.flip_h = false
			else:
				anim_sprite.flip_h = true
				anim_sprite.play("walk")
		else:
			# Vertical movement (optional: add up/down animations if you have them)
			anim_sprite.play("walk")
		
