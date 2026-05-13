extends Node

# Stores the scene to return to after any minigame ends.
# Use GameState.enter_minigame() and GameState.exit_minigame() everywhere —
# never manually set get_tree().paused or change scenes for minigames.

var previous_scene: String = ""

# Call this from any trigger (NPC, interactable object, etc.) to launch a minigame.
func enter_minigame(minigame_path: String) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	get_tree().paused = true
	get_tree().change_scene_to_file(minigame_path)

# Call this from any minigame when it is finished.
# Unpauses the tree and returns to whatever scene launched the minigame.
func exit_minigame() -> void:
	var target := previous_scene if previous_scene != "" else "res://scenes/game_scene.tscn"
	previous_scene = ""
	get_tree().paused = false
	get_tree().change_scene_to_file(target)
