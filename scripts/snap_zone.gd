extends Area2D

@export var accepted_components: Array[NodePath] = []

func _ready() -> void:
	for path in accepted_components:
		var node = get_node_or_null(path)
		if node and node.has_signal("released"):
			node.released.connect(_on_component_released)

func _on_component_released(component: RigidBody2D) -> void:
	if get_overlapping_bodies().has(component):
		component.snap(global_position)  # pass target position INTO snap()
	else:
		component.drop()
