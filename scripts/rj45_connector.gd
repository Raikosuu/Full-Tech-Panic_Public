extends Node2D

@onready var slots = $Slots.get_children()

func _draw():
	# Plastic body
	draw_rect(Rect2(-24, -50, 48, 70), Color(0.15, 0.15, 0.18))
	# Top highlight bevel
	draw_line(Vector2(-24,-50), Vector2(24,-50), Color(0.4,0.4,0.45), 1.0)
	draw_line(Vector2(-24,-50), Vector2(-24,20), Color(0.4,0.4,0.45), 1.0)
	# Gold contacts (8 pins)
	for i in 8:
		var x = -20 + i * 5
		draw_rect(Rect2(x, -44, 3, 10), Color(0.8,0.7,0.1))
		draw_rect(Rect2(x, -44, 1, 10), Color(1.0,0.95,0.4))

func get_slot(index: int):
	return slots[index]

func get_all_wires() -> Array:
	var result = []
	for slot in slots:
		result.append(slot.held_wire.wire_name_id if slot.occupied else "")
	return result

func reset():
	for slot in slots:
		slot.clear_slot()
