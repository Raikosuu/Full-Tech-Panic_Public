extends Marker2D

@export var npc: PackedScene
@onready var npc_handler := get_parent().get_node("npc_handler")

var spawn_count: int = 0
const MAX_SPAWNS: int = 22

func _on_timer_timeout() -> void:
	if spawn_count >= MAX_SPAWNS:
		$Timer.stop()   # stop the timer so no more spawns
		return

	var npcs = npc.instantiate()
	npcs.position = position
	npc_handler.add_child(npcs)

	spawn_count += 1
