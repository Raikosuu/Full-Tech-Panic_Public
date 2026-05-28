extends Node

var _game_scene_instance: Node = null
var interacted_npc: CharacterBody2D = null

func enter_minigame(minigame_path: String) -> void:
	# Save reference to the current game scene and hide it
	_game_scene_instance = get_tree().current_scene

	# Detach from the scene tree without freeing it
	get_tree().root.remove_child(_game_scene_instance)

	# Load and add the minigame as the new current scene
	var minigame = load(minigame_path).instantiate()
	get_tree().root.add_child(minigame)
	get_tree().current_scene = minigame

func exit_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
		return

	# Remove the minigame
	var minigame = get_tree().current_scene
	get_tree().root.remove_child(minigame)
	minigame.queue_free()

	# Restore the saved game scene
	get_tree().root.add_child(_game_scene_instance)
	get_tree().current_scene = _game_scene_instance
	_game_scene_instance = null

	# Tell the NPC that was served to leave
	if interacted_npc != null and is_instance_valid(interacted_npc):
		interacted_npc.leave()
		interacted_npc = null

func fail_minigame() -> void:
	if _game_scene_instance == null:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
		return

	var minigame = get_tree().current_scene
	get_tree().root.remove_child(minigame)
	minigame.queue_free()

	get_tree().root.add_child(_game_scene_instance)
	get_tree().current_scene = _game_scene_instance
	_game_scene_instance = null

	# Force the NPC to leave immediately with zero patience
	if interacted_npc != null and is_instance_valid(interacted_npc):
		interacted_npc.fail_and_leave()   # <-- new method, see Step 3
		interacted_npc = null
