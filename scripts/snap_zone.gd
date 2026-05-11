extends Area2D

@export var accepted_components: Array[NodePath] = []
@export var accepted_type: String = ""  # set this per slot in Inspector
@export var preview_modulate: Color = Color(1, 1, 1, 0.4)

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
	
	# Makes a preview of the object's position when snapped to position
	var sprite = _get_sprite(body)
	if sprite and _preview == null:
		# Copies the sprite as shown in the scene
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

# Removes preview when object is out of the snapzone area
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

# Object snap
func _on_component_released(component: RigidBody2D) -> void:
	if _preview:
		_preview.queue_free() # Removes preview when snapped
		_preview = null
	if not "component_type" in component:
		component.drop()
		return
	if component.component_type != accepted_type:
		component.drop()
		return
		
	# For debugging and to see where game conditions can be coded into
	if get_overlapping_bodies().has(component):
		component.snap(global_position)
		print("Connected: ", component.component_type, " → ", name)  # e.g. "Connected: RAM → RAMSnapZone"
	else:
		component.drop()

# Sprite finder
func _get_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
