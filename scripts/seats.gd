extends Area2D

var is_taken: bool = false

func occupy() -> void:
	if not is_taken:
		is_taken = true
		
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var char_body = body as CharacterBody2D
		# If velocity is zero, the body is not moving
		if char_body.velocity == Vector2.ZERO:
			print("Seat is taken")
