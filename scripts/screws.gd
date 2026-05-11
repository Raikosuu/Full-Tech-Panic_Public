extends RigidBody2D

signal screwed_off

var is_removed: bool = false
var is_grabbed: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var snapped: bool = true
var _snap_target: Vector2 = Vector2.ZERO
var snap_zone: Area2D = null

func _ready() -> void:
	# Collision conflict resolver
	top_level = true  # makes it ignore parent transform for physics
	_snap_target = global_position
	freeze = true
	gravity_scale = 0
	
	_snap_target = global_position
	freeze = true
	gravity_scale = 0
	

func _process(_delta: float) -> void:
	if snapped:
		global_position = _snap_target
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
			target_pos = get_viewport().get_touch_position(touch_index) - drag_offset
		linear_velocity = (target_pos - global_position) * 15

func _input(event: InputEvent) -> void:
	if not is_removed:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_point_inside(to_local(get_global_mouse_position())):
				_pop_off()
		elif event is InputEventScreenTouch and event.pressed:
			if _is_point_inside(to_local(event.position)):
				_pop_off()
		return

	if snapped:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
		if event.pressed:
			if _is_point_inside(to_local(get_global_mouse_position())):
				drag_offset = to_local(get_global_mouse_position())
				_grab()
	elif event is InputEventScreenTouch:
		if event.pressed and not is_grabbed:
			if _is_point_inside(to_local(event.position)):
				touch_index = event.index
				drag_offset = to_local(event.position)
				_grab()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_release()

func _pop_off() -> void:
	is_removed = true
	snapped = false
	freeze = false
	gravity_scale = 0
	emit_signal("screwed_off")

func _grab() -> void:
	is_grabbed = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO

func _release() -> void:
	is_grabbed = false
	if snap_zone and snap_zone.get_overlapping_bodies().has(self):
		snap(_snap_target)
	else:
		gravity_scale = 0

func snap(target_position: Vector2) -> void:
	snapped = true
	is_grabbed = false
	is_removed = false
	linear_velocity = Vector2.ZERO
	gravity_scale = 0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	_snap_target = target_position
	global_position = _snap_target
	emit_signal("screwed_off")

func _is_point_inside(local_pos: Vector2) -> bool:
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			if shape is CircleShape2D:
				return local_pos.length() <= shape.radius
			elif shape is RectangleShape2D:
				return Rect2(-shape.size / 2, shape.size).has_point(local_pos)
	return false
