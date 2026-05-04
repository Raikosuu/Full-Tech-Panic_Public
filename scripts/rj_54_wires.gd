extends Node2D

@export var wire_color: Color = Color.ORANGE
@export var has_stripe: bool = false
@export var wire_name_id: String = "Orange"
@export var sag_amount: float = 18.0
@export var wire_width: float = 4.0

var dragging: bool = false
var touch_index: int = -1
var drag_offset: Vector2 = Vector2.ZERO
var home_position: Vector2
var slotted: bool = false
var assigned_slot = null

var anchor_point: Vector2
var free_point: Vector2

const STEPS: int = 14

@onready var line: Line2D = $Line2D
@onready var handle: Area2D = $GrabHandle

func _ready():
	home_position = global_position
	anchor_point = global_position + Vector2(0, -40)
	free_point = global_position
	_build_line()
	_apply_colors()

func setup(color: Color, stripe: bool, name_id: String):
	wire_color = color
	has_stripe = stripe
	wire_name_id = name_id
	if is_inside_tree():
		_apply_colors()

func _build_line():
	line.clear_points()
	for i in range(STEPS + 1):
		var t = float(i) / STEPS
		var p = anchor_point.lerp(free_point, t)
		p.y += sin(t * PI) * sag_amount
		line.add_point(to_local(p))

func _apply_colors():
	line.width = wire_width
	line.default_color = wire_color
	if has_stripe:
		var grad = Gradient.new()
		var offsets = []
		var colors = []
		for i in range(10):
			var t0 = float(i) / 10.0
			var t1 = t0 + 0.04
			offsets.append_array([t0, t1])
			colors.append_array([wire_color, Color.WHITE])
		grad.offsets = PackedFloat32Array(offsets)
		grad.colors = PackedColorArray(colors)
		line.gradient = grad
	else:
		line.gradient = null

func _draw():
	var tip = to_local(free_point)
	var anc = to_local(anchor_point)
	# Copper tip
	draw_circle(tip, 3.0, Color(0.8, 0.7, 0.1))
	draw_circle(tip, 2.0, Color(1.0, 0.9, 0.3))
	# Insulation cap
	draw_rect(Rect2(anc - Vector2(3,3), Vector2(6,6)), wire_color)

func _input(event: InputEvent):
	if slotted:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_index == -1 and _handle_hit(event.position):
				touch_index = event.index
				drag_offset = global_position - event.position
				_start_drag()
		else:
			if event.index == touch_index:
				touch_index = -1
				_end_drag()

	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_move_to(event.position + drag_offset)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not dragging and _handle_hit(event.global_position):
					drag_offset = global_position - event.global_position
					_start_drag()
			else:
				if dragging:
					_end_drag()

	elif event is InputEventMouseMotion:
		if dragging:
			_move_to(event.global_position + drag_offset)

func _handle_hit(pos: Vector2) -> bool:
	var local = handle.to_local(pos)
	var shape = handle.get_node("CollisionShape2D").shape as CircleShape2D
	return local.length() <= shape.radius * 2.0

func _start_drag():
	dragging = true
	z_index = 10

func _move_to(world_pos: Vector2):
	free_point = world_pos
	anchor_point = home_position + Vector2(0, -40)
	handle.global_position = free_point
	_build_line()
	queue_redraw()

func _end_drag():
	dragging = false
	z_index = 0
	touch_index = -1
	if not _try_snap_to_slot():
		_return_home()

func _try_snap_to_slot() -> bool:
	var slots = get_tree().get_nodes_in_group("wire_slots")
	for slot in slots:
		if not slot.is_occupied() and _is_near(free_point, slot.global_position, 24.0):
			slot.receive_wire(self)
			slotted = true
			assigned_slot = slot
			free_point = slot.global_position
			anchor_point = home_position + Vector2(0, -40)
			_build_line()
			handle.global_position = free_point
			queue_redraw()
			return true
	return false

func _return_home():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_method(_move_to, free_point, home_position, 0.25)

func unslot():
	slotted = false
	assigned_slot = null
	_return_home()

func _is_near(a: Vector2, b: Vector2, threshold: float) -> bool:
	return a.distance_to(b) <= threshold
