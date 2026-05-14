extends Area2D

@export var accepted_components: Array[NodePath] = []
@export var accepted_type: String = ""
@export var preview_modulate: Color = Color(1, 1, 1, 0.4)
@export var remove_component: bool = false
@export var target_sprite: NodePath
@export var snapped_texture: Texture2D
@export var allow_preview: bool = true
@export var required_snap_zone: NodePath   # NEW
@export var blocked_by_snap_zone: NodePath   # blocks this zone if that zone is filled

signal part_snapped(slot_type: String)

var _preview: Sprite2D = null
var is_filled: bool = false               # NEW

func _ready() -> void:
	for path in accepted_components:
		var node = get_node_or_null(path)
		if node and node.has_signal("released"):
			if not node.released.is_connected(_on_component_released):
				node.released.connect(_on_component_released)
		if node and node.has_signal("unsnapped"):
			if not node.unsnapped.is_connected(_on_component_unsnapped):
				node.unsnapped.connect(_on_component_unsnapped)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not "snapped" in body: return
	if not "component_type" in body: return
	if body.component_type != accepted_type: return
	if body.snapped: return
	if not body.is_grabbed: return

	# Connect released signal dynamically if not already connected
	if body.has_signal("released") and not body.released.is_connected(_on_component_released):
		body.released.connect(_on_component_released)
	if body.has_signal("unsnapped") and not body.unsnapped.is_connected(_on_component_unsnapped):
		body.unsnapped.connect(_on_component_unsnapped)

	# NEW: suppress preview if prerequisite isn't met
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
	if not "snapped" in body: return
	if not "component_type" in body: return
	if body.component_type != accepted_type: return
	if _preview:
		_preview.queue_free()
		_preview = null

func _on_component_released(component: RigidBody2D) -> void:
	if _preview:
		_preview.queue_free()
		_preview = null
	if not "component_type" in component:
		component.drop()
		return
	if component.component_type != accepted_type:
		component.drop()
		return
	if blocked_by_snap_zone:
		var blocker = get_node_or_null(blocked_by_snap_zone)
		if blocker and blocker is Area2D and blocker.is_filled:
			print("Snap blocked: panel is already placed")
			component.drop()
			return

	# NEW: enforce prerequisite
	if required_snap_zone:
		var prereq = get_node_or_null(required_snap_zone)
		if prereq and not prereq.is_filled:
			component.drop()
			return

	if get_overlapping_bodies().has(component):
		component.snap(global_position)
		is_filled = true                  # NEW
		print("Connected: ", component.component_type, " → ", name)
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
			target.texture = snapped_texture
	else:
		component.drop()

func _get_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
	
func _on_component_unsnapped(component: RigidBody2D) -> void:
	if component.component_type == accepted_type:
		is_filled = false
