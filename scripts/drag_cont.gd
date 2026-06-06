extends RigidBody2D

signal released(component)
signal unsnapped(component)

var is_grabbed: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var _touch_pos: Vector2 = Vector2.ZERO
var snapped: bool = false
var component_type: String = ""
var _default_collision_layer: int = 0
var _default_collision_mask: int = 0
var _default_z_index: int = 0
var _from_hotbar: bool = false

@export var allow_unsnap: bool = false
@export var blocked_by_parts: Array[NodePath] = []
@export var _drag_min: Vector2 = Vector2(154, 80)
@export var _drag_max_x: float = 316.0
@export var hotbar_path: NodePath = NodePath("")

var _drag_max: Vector2 = Vector2(316, 166)


func _ready() -> void:
	gravity_scale = 0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	linear_velocity = Vector2.ZERO
	set_physics_process(false)
	_default_z_index = z_index
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	_update_bounds()
func _is_blocked() -> bool:
	for path in blocked_by_parts:
		var node = get_node_or_null(path)
		if node and "snapped" in node and node.snapped:
			return true
	return false

func _physics_process(_delta: float) -> void:
	if snapped:
		set_physics_process(false)
		return

	if is_grabbed:
		if not _from_hotbar and touch_index == -1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_release()
			return
		var target_pos: Vector2
		if touch_index == -1:
			target_pos = get_global_mouse_position() - drag_offset
		else:
			target_pos = _touch_pos - drag_offset
		var radius := _get_shape_radius()
		target_pos.x = clamp(target_pos.x, _drag_min.x + radius, _drag_max.x - radius)
		target_pos.y = clamp(target_pos.y, _drag_min.y + radius, _drag_max.y - radius)
		global_position = global_position.lerp(target_pos, 0.3)

func _input(event: InputEvent) -> void:
	if snapped:
		if allow_unsnap:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and touch_index == -1:
				if GameState.drag_active:
					return
				if _is_blocked():
					return
				var local_pos = to_local(get_global_mouse_position())
				if _is_point_inside(local_pos):
					drag_offset = local_pos
					_unsnap()
					_grab()
			elif event is InputEventScreenTouch and event.pressed:
				if GameState.drag_active:
					return
				if _is_blocked():
					return
				var local_pos = to_local(event.position)
				if _is_point_inside(local_pos):
					touch_index = event.index
					_touch_pos = event.position
					drag_offset = local_pos
					_unsnap()
					_grab()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
		if _from_hotbar:
			if event.pressed:
				_from_hotbar = false
				var local_pos = to_local(get_global_mouse_position())
				drag_offset = local_pos
			else:
				_from_hotbar = false
				_release()
			return
		if event.pressed:
			if GameState.drag_active:
				return
			if _is_blocked():
				return
			var local_pos = to_local(get_global_mouse_position())
			if _is_point_inside(local_pos):
				drag_offset = local_pos
				_grab()

	elif event is InputEventScreenTouch:
		if event.pressed and not is_grabbed:
			if GameState.drag_active:
				return
			if _is_blocked():
				return
			var local_pos = to_local(event.position)
			if _is_point_inside(local_pos):
				touch_index = event.index
				_touch_pos = event.position
				drag_offset = local_pos
				_grab()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_release()

	elif event is InputEventScreenDrag and event.index == touch_index:
		_touch_pos = event.position

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
	GameState.drag_active = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	z_index = 100
	z_as_relative = false
	collision_layer = 2
	collision_mask = 0
	set_physics_process(true)

	# Restore sprite and collision visibility — parts hidden by snap zones
	# (remove_component = true) need to reappear when dragged out.
	_restore_visibility()

func _restore_visibility() -> void:
	for child in get_children():
		if child is Sprite2D:
			child.visible = true
		elif child is CollisionShape2D:
			child.disabled = false

func _release() -> void:
	is_grabbed = false
	GameState.drag_active = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	gravity_scale = 0
	z_index = _default_z_index
	z_as_relative = true
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	set_physics_process(false)
	emit_signal("released", self)

func snap(target_position: Vector2) -> void:
	snapped = true
	is_grabbed = false
	GameState.drag_active = false
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

func drop() -> void:
	pass

func grab_from_hotbar(world_pos: Vector2) -> void:
	drag_offset = Vector2.ZERO
	global_position = world_pos
	_from_hotbar = true
	_grab()

func _update_bounds() -> void:
	_drag_max.x = _drag_max_x
	if hotbar_path:
		var hotbar = get_node_or_null(hotbar_path)
		if hotbar:
			var panel = hotbar.get_node_or_null("Panel")
			if panel:
				# Convert hotbar top edge from screen to world space
				var cam = get_viewport().get_camera_2d()
				if cam:
					var screen_top = panel.global_position.y
					var world_y = cam.global_position.y + (screen_top - get_viewport().get_visible_rect().size.y / 2.0) / cam.zoom.y
					_drag_max.y = world_y
					return
	_drag_max.y = 166.0  # fallback

func _get_shape_radius() -> float:
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			if child.shape is CircleShape2D:
				return child.shape.radius
			elif child.shape is RectangleShape2D:
				return max(child.shape.size.x, child.shape.size.y) / 2.0
	return 0.0
