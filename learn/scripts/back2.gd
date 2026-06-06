extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://learn/scenes/learn.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if get_global_rect().has_point(event.position):
			_on_pressed()
