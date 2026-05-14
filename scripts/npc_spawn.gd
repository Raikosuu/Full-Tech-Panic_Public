extends Marker2D

@export var min_wait_time: float = 3.0
@export var max_wait_time: float = 8.0
# Imports the NPCs
@onready var npc_scenes = [
	preload("res://scenes/npc_1.tscn"),
	preload("res://scenes/npc_2.tscn")
]

# Set Limits for Spawn
var max_spawn = 22
var spawn_count = 0

func _ready() -> void:
	randomize()

func _on_timer_timeout() -> void:
	if spawn_count == max_spawn:
		$Timer.stop()
	else:
		var npc_scene = npc_scenes[randi() % npc_scenes.size()]
		var npcs = npc_scene.instantiate()
		
		# Add first, THEN set global position
		get_parent().get_node("npc_handler").add_child(npcs)
		npcs.global_position = global_position
		
		spawn_count += 1
		$Timer.wait_time = randf_range(min_wait_time, max_wait_time)
		$Timer.start()
