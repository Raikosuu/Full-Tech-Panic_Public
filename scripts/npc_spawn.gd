extends Marker2D

@onready var npc = preload("res://scenes/npc_1.tscn")
var max_spawn = 22
var spawn_count = 0

func _on_timer_timeout() -> void:
	if spawn_count == max_spawn:
		$Timer.stop()
	else:
		var npcs = npc.instantiate()
		npcs.position = position
		get_parent().get_node("npc_handler").add_child(npcs)
		spawn_count += 1
	
	
		
	
