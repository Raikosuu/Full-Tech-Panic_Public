extends RigidBody2D

var is_grabbed: bool = false

func _process(delta: float) -> void:
	if is_grabbed:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position)
		linear_velocity = direction * 5
		return
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			is_grabbed = true
			gravity_scale = 0
			linear_velocity = Vector2.ZERO
		else: 
			is_grabbed = false
			gravity_scale = 1
