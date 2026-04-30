extends RigidBody2D

signal released(component)

var is_grabbed: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var snapped: bool = false
var _snap_target: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if snapped:
		global_position = _snap_target  # force position every frame — physics cannot fight this
		return
	if is_grabbed:
		var still_held: bool = false
		if touch_index == -1:
			still_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		else:
			still_held = true
		if not still_held:
			_release()
			return
		var target_pos: Vector2
		if touch_index == -1:
			target_pos = get_global_mouse_position() - drag_offset
		else:
			target_pos = _get_touch_position() - drag_offset
		var direction = target_pos - global_position
		linear_velocity = direction * 15

func _get_touch_position() -> Vector2:
	return get_viewport().get_touch_position(touch_index)

func _input(event: InputEvent) -> void:
	if snapped:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
		if event.pressed:
			var local_pos = to_local(get_global_mouse_position())
			if _is_point_inside(local_pos):
				drag_offset = local_pos
				_grab()
	elif event is InputEventScreenTouch:
		if event.pressed and not is_grabbed:
			var local_pos = to_local(event.position)
			if _is_point_inside(local_pos):
				touch_index = event.index
				drag_offset = local_pos
				_grab()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_release()
	elif event is InputEventScreenDrag and event.index == touch_index:
		pass

func _is_point_inside(local_pos: Vector2) -> bool:
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
	emit_signal("released", self)

func snap(target_position: Vector2) -> void:
	snapped = true
	is_grabbed = false
	linear_velocity = Vector2.ZERO
	gravity_scale = 0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	_snap_target = target_position
	global_position = _snap_target

func drop() -> void:
	gravity_scale = 1
