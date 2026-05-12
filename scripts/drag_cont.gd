extends RigidBody2D

signal released(component)

var is_grabbed: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var snapped: bool = false
var component_type: String = ""
var _default_collision_layer: int = 0
var _default_collision_mask: int = 0
var _default_z_index: int = 0  # stores original z-index before grab
signal unsnapped(component)
@export var allow_unsnap: bool = false

func _ready() -> void:
	gravity_scale = 0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	linear_velocity = Vector2.ZERO
	set_physics_process(false)
	_default_z_index = z_index
	# Save original collision settings
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask

func _physics_process(delta: float) -> void:
	if snapped:
		set_physics_process(false)
		return

	if is_grabbed:
		if touch_index == -1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_release()
			return
		var target_pos: Vector2
		if touch_index == -1:
			target_pos = get_global_mouse_position() - drag_offset
		else:
			target_pos = _get_touch_position() - drag_offset
		global_position = global_position.lerp(target_pos, 0.3)

func _get_touch_position() -> Vector2:
	return get_viewport().get_touch_position(touch_index)

func _input(event: InputEvent) -> void:
	# Allow unsnapping by grabbing again
	if snapped:
		if allow_unsnap:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and touch_index == -1:
				var local_pos = to_local(get_global_mouse_position())
				if _is_point_inside(local_pos):
					_unsnap()
					drag_offset = local_pos
					_grab()
			elif event is InputEventScreenTouch and event.pressed:
				var local_pos = to_local(event.position)
				if _is_point_inside(local_pos):
					_unsnap()
					touch_index = event.index
					drag_offset = local_pos
					_grab()
			return
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
		
func _unsnap() -> void:
	snapped = false
	emit_signal("unsnapped", self)
	emit_signal("released", self)
	
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
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	z_index = 100
	z_as_relative = false
	# Keep layer 2 so snap zones (Area2D with mask=2) can still detect us,
	# but drop layer 1 so other RigidBodies stop bumping us
	collision_layer = 2
	collision_mask = 0
	set_physics_process(true)

func _release() -> void:
	is_grabbed = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	gravity_scale = 0
	z_index = _default_z_index
	z_as_relative = true
	# Restore collisions
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	set_physics_process(false)
	emit_signal("released", self)

func snap(target_position: Vector2) -> void:
	snapped = true
	is_grabbed = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	gravity_scale = 0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	global_position = target_position
	z_index = _default_z_index
	z_as_relative = true
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	set_physics_process(false)
	# removed set_process_input(false) so the component can still be grabbed

func drop() -> void:
	pass
