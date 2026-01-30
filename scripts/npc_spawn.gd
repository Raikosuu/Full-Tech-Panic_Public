extends Marker2D

@onready var npc_scenes = [
	preload("res://scenes/npc_1.tscn"),
	preload("res://scenes/npc_2.tscn")
]

var max_spawn = 22
var spawn_count = 0

func _ready() -> void:
	randomize()

func _on_timer_timeout() -> void:
	if spawn_count == max_spawn:
		$Timer.stop()
	else:
		# Pick a random NPC scene
		var npc_scene = npc_scenes[randi() % npc_scenes.size()]
		var npcs = npc_scene.instantiate()
		
		# Set spawn position
		npcs.position = position
		
		# Add to handler
		get_parent().get_node("npc_handler").add_child(npcs)
		
		spawn_count += 1
		
		#spawn at random intervals
		$Timer.wait_time = randf_range(3, 8)
		$Timer.start()
