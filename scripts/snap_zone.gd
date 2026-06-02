extends Area2D

@export var accepted_type: String = ""
@export var preview_modulate: Color = Color(1, 1, 1, 0.4)
@export var remove_component: bool = false
@export var target_sprite: NodePath
@export var snapped_texture: Texture2D
@export var allow_preview: bool = true
@export var required_snap_zone: NodePath
@export var blocked_by_snap_zone: NodePath

# When true, clicking this filled zone ejects the snapped part to the cursor.
# Use this instead of allow_unsnap on the part itself, for zones where the
# part was hidden on snap (remove_component = true).
@export var eject_on_click: bool = false

signal part_snapped(slot_type: String)
signal part_removed(slot_type: String)

var _preview: Sprite2D = null
var is_filled: bool = false
var _snapped_component: Node = null   # kept so we can eject it later
var _original_texture: Texture2D = null  # restore mobo sprite on eject

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if not eject_on_click or not is_filled or _snapped_component == null:
		return
	if GameState.drag_active:
		return

	var pressed := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
	if not pressed:
		return

	# Check if the click/touch landed inside our collision area
	var click_pos: Vector2
	if event is InputEventMouseButton:
		click_pos = event.position
	else:
		click_pos = (event as InputEventScreenTouch).position

	var local_click := to_local(get_global_mouse_position() if event is InputEventMouseButton else click_pos)
	var shape_node := get_node_or_null("CollisionShape2D")
	if shape_node == null:
		return
	var shape = (shape_node as CollisionShape2D).shape
	var inside := false
	if shape is CircleShape2D:
		inside = local_click.length() <= (shape as CircleShape2D).radius
	elif shape is RectangleShape2D:
		inside = Rect2(-(shape as RectangleShape2D).size / 2, (shape as RectangleShape2D).size).has_point(local_click)
	if not inside:
		return

	_eject_component()

func _eject_component() -> void:
	var comp := _snapped_component
	if comp == null:
		return

	# Restore sprite visibility and collision on the part
	var sprite := _get_sprite(comp)
	if sprite:
		sprite.visible = true
	var col := comp.get_node_or_null("CollisionShape2D")
	if col:
		col.disabled = false

	# Restore the target sprite texture if it was swapped
	if _original_texture != null:
		var target := get_node_or_null(target_sprite)
		if target:
			target.texture = _original_texture
		_original_texture = null

	# Un-snap state on the zone
	is_filled = false
	_snapped_component = null
	emit_signal("part_removed", accepted_type)

	# Hand the part to the cursor
	if comp.has_method("grab_from_hotbar"):
		comp.grab_from_hotbar(get_global_mouse_position())

func _on_body_entered(body: Node) -> void:
	if not _is_valid_candidate(body):
		return
	if not ("is_grabbed" in body and body.is_grabbed):
		return

	if body.has_signal("released") and not body.released.is_connected(_on_component_released):
		body.released.connect(_on_component_released)
	if body.has_signal("unsnapped") and not body.unsnapped.is_connected(_on_component_unsnapped):
		body.unsnapped.connect(_on_component_unsnapped)

	if not allow_preview:
		return
	if required_snap_zone:
		var prereq = get_node_or_null(required_snap_zone)
		if prereq and not prereq.is_filled:
			return

	var sprite = _get_sprite(body)
	if sprite and _preview == null:
		_preview = Sprite2D.new()
		_preview.texture = sprite.texture
		_preview.modulate = preview_modulate
		_preview.scale = body.scale * sprite.scale
		_preview.transform = sprite.transform
		_preview.scale /= self.scale
		_preview.rotation = body.rotation + sprite.rotation
		_preview.centered = sprite.centered
		_preview.offset = sprite.offset
		_preview.flip_h = sprite.flip_h
		_preview.flip_v = sprite.flip_v
		add_child(_preview)
		_preview.global_position = global_position

func _on_body_exited(body: Node) -> void:
	if not _is_valid_candidate(body):
		return
	if not ("is_grabbed" in body and body.is_grabbed):
		return
	if _preview:
		_preview.queue_free()
		_preview = null

func _on_component_released(component: RigidBody2D) -> void:
	if _preview:
		_preview.queue_free()
		_preview = null

	if not _is_valid_candidate(component):
		component.drop()
		return

	if blocked_by_snap_zone:
		var blocker = get_node_or_null(blocked_by_snap_zone)
		if blocker and blocker is Area2D and blocker.is_filled:
			component.drop()
			return

	if required_snap_zone:
		var prereq = get_node_or_null(required_snap_zone)
		if prereq and not prereq.is_filled:
			component.drop()
			return

	if get_overlapping_bodies().has(component):
		component.snap(global_position)
		is_filled = true
		_snapped_component = component
		emit_signal("part_snapped", accepted_type)

		if remove_component:
			var sprite = _get_sprite(component)
			if sprite:
				sprite.visible = false
			var collision = component.get_node_or_null("CollisionShape2D")
			if collision:
				collision.disabled = true

		var target = get_node_or_null(target_sprite)
		if target and snapped_texture:
			# Remember original so we can restore on eject
			if _original_texture == null:
				_original_texture = target.texture
			target.texture = snapped_texture
	else:
		component.drop()

func _on_component_unsnapped(component: RigidBody2D) -> void:
	if component.component_type == accepted_type:
		is_filled = false
		_snapped_component = null
		emit_signal("part_removed", accepted_type)

# ── Pre-fill for disassembly scenes ────────────────────────────────────────
func pre_fill(component: Node) -> void:
	is_filled = true
	_snapped_component = component
	component.snap(global_position)
	if component.has_signal("unsnapped") and not component.unsnapped.is_connected(_on_component_unsnapped):
		component.unsnapped.connect(_on_component_unsnapped)

# ── Helpers ────────────────────────────────────────────────────────────────
func _is_valid_candidate(body: Node) -> bool:
	if not "component_type" in body:
		return false
	if body.component_type != accepted_type:
		return false
	if "snapped" in body and body.snapped:
		return false
	return true

func _get_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
