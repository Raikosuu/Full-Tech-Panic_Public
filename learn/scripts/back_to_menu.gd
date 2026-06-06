extends Node

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		# Find the parent button node
		var btn := get_parent()
		if btn is Control and btn.get_global_rect().has_point(event.position):
			_on_pressed()
