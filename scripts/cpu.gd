# Access main controls
extends "res://scripts/drag_cont.gd"

func _ready() -> void:
	component_type = "CPU"
	super._ready()  # calls DraggableComponent _ready()
