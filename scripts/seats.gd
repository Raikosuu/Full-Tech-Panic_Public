extends Area2D

var is_taken: bool = false

func occupy() -> void:
	if not is_taken:
		is_taken = true

func _on_body_entered(body: Node2D) -> void:
	pass
