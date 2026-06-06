extends Node2D

const GAME_OVER_SCENE = preload("res://scenes/game_over_screen.tscn")

@onready var served_label: Label = $HUD/ServedLabel

func _ready() -> void:
	# Apply NPC spawner settings from current level data
	var spawner := get_node_or_null("npc_spawn")  # adjust path if yours is different
	if spawner:
		spawner.min_wait_time = GameState.get_npc_spawn_min()
		spawner.max_wait_time = GameState.get_npc_spawn_max()
		spawner.max_spawn     = GameState.get_npc_max_spawn()

	# Connect signals
	if not HealthState.game_over.is_connected(_on_game_over):
		HealthState.game_over.connect(_on_game_over)
	GameState.npcs_served_changed.connect(_on_npcs_served_changed)
	GameState.game_won.connect(_on_game_won)

	# Set the label from GameState, not from Inspector
	_update_label(GameState.npcs_served)

func _update_label(count: int) -> void:
	served_label.text = "%d / %d" % [count, GameState.npcs_to_win]

func _on_npcs_served_changed(count: int) -> void:
	_update_label(count)

func _on_game_over() -> void:
	GameState.is_game_over = true
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED  # ← freeze game scene
	var screen := GAME_OVER_SCENE.instantiate()
	get_tree().root.add_child(screen)

func _on_game_won() -> void:
	var outro := GameState.get_outro_cutscene()
	if outro != "":
		get_tree().change_scene_to_file(outro)
	else:
		GameState.advance_to_next_level()
