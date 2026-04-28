extends RigidBody2D

var is_grabbed: bool = false
var touch_index: int = -1  # Track which finger is grabbing

func _process(delta: float) -> void:
	if is_grabbed:
		var target_pos = get_global_mouse_position() if touch_index == -1 else _get_touch_position()
		var direction = target_pos - global_position
		linear_velocity = direction * 5
		return

func _get_touch_position() -> Vector2:
	return get_viewport().get_touch_position(touch_index)

func _input(event: InputEvent) -> void:
	# Mouse input
	if event is InputEventMouseButton and touch_index == -1:
		if event.pressed:
			_grab()
		else:
			_release()

	# Touch input
	elif event is InputEventScreenTouch:
		if event.pressed and not is_grabbed:
			# Check if touch is on this object
			var local_pos = to_local(event.position)
			if _is_point_inside(local_pos):
				touch_index = event.index
				_grab()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_release()

	elif event is InputEventScreenDrag and event.index == touch_index:
		pass  # position is handled in _process via get_touch_position

func _is_point_inside(local_pos: Vector2) -> bool:
	# Works with CircleShape2D or RectangleShape2D on the first CollisionShape2D child
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			if shape is CircleShape2D:
				return local_pos.length() <= shape.radius
			elif shape is RectangleShape2D:
				return Rect2(-shape.size / 2, shape.size).has_point(local_pos)
	return false

func _grab() -> void:
	is_grabbed = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO

func _release() -> void:
	is_grabbed = false
	gravity_scale = 1
