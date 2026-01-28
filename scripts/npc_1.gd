extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

func _update_animation(movement: Vector2) -> void:
	if abs(movement.x) > abs(movement.y) and movement.x > 0:
		anim_sprite.flip_h = false
		anim_sprite.play("walk")
	else:
		anim_sprite.flip_h = true
		anim_sprite.play("walk")
		
	
