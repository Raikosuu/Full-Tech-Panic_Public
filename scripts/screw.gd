extends RigidBody2D
 
# How hard the screw pops off
@export var pop_force: float = 300.0
# How fast it spins when flying
@export var spin_force: float = 25.0
# The Y position of your world boundary (set this to match your boundary)
@export var boundary_y: float = 200.0
 
# Emitted when the screw is snapped back into place (screwed in)
signal screwed_in
# Required by snap_zone.gd - emitted when released so the snap zone can react
signal released(component)
 
var _screwed: bool = true
var _settled: bool = false
var _snapped: bool = false
var _snap_target: Vector2 = Vector2.ZERO
 
# For touch/drag support (mirrors drag_cont.gd behaviour)
var is_grabbed: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
 
func _ready() -> void:
	# Start frozen so it sits on the PC
	freeze = true
	gravity_scale = 0.0
	input_pickable = true
 
func _process(_delta: float) -> void:
	# If snapped, hold position every frame so physics can't fight it
	if _snapped:
		global_position = _snap_target
		return
 
	if is_grabbed:
		var still_held := false
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
		var direction := target_pos - global_position
		linear_velocity = direction * 15
 
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if _snapped:
		return
 
	# --- Tap while screwed in: pop off ---
	if _screwed and not is_grabbed:
		var tapped := false
		if event is InputEventScreenTouch and event.pressed:
			tapped = true
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			tapped = true
		if tapped:
			_pop_off()
			return
 
	# --- After settling: allow drag to pick up, same as drag_cont.gd ---
	if _settled and not is_grabbed:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
			if event.pressed:
				var local_pos := to_local(get_global_mouse_position())
				if _is_point_inside(local_pos):
					drag_offset = local_pos
					_grab()
		elif event is InputEventScreenTouch:
			if event.pressed and not is_grabbed:
				var local_pos := to_local(event.position)
				if _is_point_inside(local_pos):
					touch_index = event.index
					drag_offset = local_pos
					_grab()
			elif not event.pressed and event.index == touch_index:
				touch_index = -1
				_release()
 
func _physics_process(_delta: float) -> void:
	if _screwed or _settled or _snapped or is_grabbed:
		return
 
	# Settle at world boundary
	if global_position.y >= boundary_y:
		global_position.y = boundary_y
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		freeze = true
		gravity_scale = 0.0
		_settled = true
 
# ── Internal helpers ──────────────────────────────────────────────────────────
 
func _pop_off() -> void:
	_screwed = false
	freeze = false
	gravity_scale = 1.0
 
	var angle := randf_range(-PI, PI)
	var direction := Vector2(cos(angle), sin(angle) - 1.0).normalized()
	apply_central_impulse(direction * pop_force)
	apply_torque_impulse(randf_range(-spin_force, spin_force))
 
func _grab() -> void:
	is_grabbed = true
	_settled = false
	freeze = false
	gravity_scale = 0.0
	linear_velocity = Vector2.ZERO
 
func _release() -> void:
	is_grabbed = false
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
 
# ── Called by snap_zone.gd ────────────────────────────────────────────────────
 
# snap_zone.gd calls snap(global_position) when the screw overlaps the zone
func snap(target_position: Vector2) -> void:
	_snapped = true
	_screwed = true
	is_grabbed = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	gravity_scale = 0.0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	_snap_target = target_position
	global_position = _snap_target
	emit_signal("screwed_in")
 
# snap_zone.gd calls drop() when the screw is released outside the zone
func drop() -> void:
	_snapped = false
	_screwed = false
	gravity_scale = 1.0
	freeze = false
 
# ── Public helpers ────────────────────────────────────────────────────────────
 
func is_settled() -> bool:
	return _settled
 
func is_screwed() -> bool:
	return _screwed
