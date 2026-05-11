extends Area2D

@export var accepted_components: Array[NodePath] = []
@export var accepted_type: String = ""              # set per slot in Inspector
@export var preview_modulate: Color = Color(1, 1, 1, 0.4)

# New configurable options
@export var remove_component: bool = false          # true for CPU slot, false for others
@export var target_sprite: NodePath                 # optional: sprite to update (e.g. motherboard)
@export var snapped_texture: Texture2D              # optional: texture to swap in
@export var allow_preview: bool = true              # disable preview for certain parts

var _preview: Sprite2D = null

func _ready() -> void:
	for path in accepted_components:
		var node = get_node_or_null(path)
		if node and node.has_signal("released"):
			node.released.connect(_on_component_released)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not "snapped" in body:
		return
	if not "component_type" in body:
		return
	if body.component_type != accepted_type:
		return
	if body.snapped:
		return
	if not allow_preview:   # NEW: respect the allow_preview flag
		return
	if not body.is_grabbed: # NEW: only show preview if the object is being grabbed
		return
	
	# Makes a preview of the object's position when snapped to position
	var sprite = _get_sprite(body)
	if sprite and _preview == null:
		_preview = Sprite2D.new()
		_preview.texture = sprite.texture
		_preview.modulate = preview_modulate
		_preview.scale = body.scale * sprite.scale
		_preview.rotation = body.rotation + sprite.rotation
		_preview.centered = sprite.centered
		_preview.offset = sprite.offset
		_preview.flip_h = sprite.flip_h  
		_preview.flip_v = sprite.flip_v  
		add_child(_preview)
		_preview.global_position = global_position

func _on_body_exited(body: Node) -> void:
	if not "snapped" in body:
		return
	if not "component_type" in body:
		return
	if body.component_type != accepted_type:
		return
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

	if get_overlapping_bodies().has(component):
		component.snap(global_position)
		print("Connected: ", component.component_type, " → ", name)

		# Hide/disappear component only if configured
		if remove_component:
			var sprite = _get_sprite(component)
			if sprite:
				sprite.visible = false
			var collision = component.get_node_or_null("CollisionShape2D")
			if collision:
				collision.disabled = true

		# Change another object’s sprite only if configured
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
