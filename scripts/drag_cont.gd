extends RigidBody2D

var is_grabbed: bool = false
var touch_index: int = -1
var grab_offset: Vector2 = Vector2.ZERO  # ← offset from object center to grab point

var snap_target: Vector2 = Vector2.ZERO
var in_snap_zone: bool = false

func _ready() -> void:
	var zone = get_tree().get_first_node_in_group("snap_zone")
	if zone and zone.has_method("register"):
		zone.register(self)

func _process(_delta: float) -> void:
	if is_grabbed:
		var target_pos = get_global_mouse_position() if touch_index == -1 else _get_touch_position()
		# Subtract offset so object doesn't snap its center to your finger
		var direction = (target_pos - grab_offset) - global_position
		linear_velocity = direction * 5

func _get_touch_position() -> Vector2:
	return get_viewport().get_touch_position(touch_index)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and touch_index == -1:
		if event.pressed:
			var local_pos = to_local(get_global_mouse_position())
			if _is_point_inside(local_pos):
				grab_offset = local_pos  # ← store where on the object you clicked
				_grab()
		else:
			if is_grabbed:
				_release()

	elif event is InputEventScreenTouch:
		if event.pressed and not is_grabbed:
			var local_pos = to_local(event.position)
			if _is_point_inside(local_pos):
				grab_offset = local_pos  # ← store where on the object you touched
				touch_index = event.index
				_grab()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_release()

func _grab() -> void:
	is_grabbed = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO

func _release() -> void:
	is_grabbed = false
	gravity_scale = 1
	grab_offset = Vector2.ZERO
	if in_snap_zone and snap_target != Vector2.ZERO:
		_snap_to(snap_target)

func _snap_to(pos: Vector2) -> void:
	global_position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true

func _is_point_inside(local_pos: Vector2) -> bool:
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			var offset_pos = local_pos - child.position
			if shape is CircleShape2D:
				return offset_pos.length() <= shape.radius
			elif shape is RectangleShape2D:
				return Rect2(-shape.size / 2, shape.size).has_point(offset_pos)
	return false
