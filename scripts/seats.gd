extends Area2D

#sends signals when player collides with the seat area(Area2d)
func _on_body_entered(body: Node2D) -> void:
	print("npc has taken the seat")
