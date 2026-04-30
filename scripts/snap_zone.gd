extends Area2D

# Assign every draggable component that can snap here via the Inspector
@export var accepted_components: Array[NodePath] = []

func _ready() -> void:
	# Connect to the released signal of each registered component
	for path in accepted_components:
		var node = get_node(path)
		if node and node.has_signal("released"):
			node.released.connect(_on_component_released)

func _on_component_released(component: RigidBody2D) -> void:
	if get_overlapping_bodies().has(component):
		component.global_position = global_position
		component.snap()
	else:
		component.drop()
