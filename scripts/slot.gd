extends Node2D

@export var slot_index: int = 0

var occupied: bool = false
var held_wire = null

@onready var highlight: ColorRect = $Highlight

func _ready():
	add_to_group("wire_slots")

func is_occupied() -> bool:
	return occupied

func receive_wire(wire):
	occupied = true
	held_wire = wire
	highlight.color = wire.wire_color

func clear_slot():
	if held_wire:
		held_wire.unslot()
	occupied = false
	held_wire = null
	highlight.color = Color(0.2, 0.2, 0.2)

func flash_error():
	var tween = create_tween()
	tween.tween_property(highlight, "color", Color.RED, 0.1)
	tween.tween_property(highlight, "color", Color(0.2,0.2,0.2), 0.1)
	tween.set_loops(3)
