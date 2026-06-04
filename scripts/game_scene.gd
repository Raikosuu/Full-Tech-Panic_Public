extends Node2D

const GAME_OVER_SCENE = preload("res://scenes/game_over_screen.tscn")

@export var npcs_to_win: int = 10   # ← set this in the Inspector on the game_scene node

@onready var served_label: Label = $HUD/ServedLabel

func _ready() -> void:
	# Apply inspector value to GameState
	GameState.npcs_to_win = npcs_to_win
	GameState.npcs_served = 0

	# Connect health
	if not HealthState.game_over.is_connected(_on_game_over):
		HealthState.game_over.connect(_on_game_over)

	# Connect win counter
	GameState.npcs_served_changed.connect(_on_npcs_served_changed)
	GameState.game_won.connect(_on_game_won)

	_update_label(0)

func _update_label(count: int) -> void:
	served_label.text = "%d / %d" % [count, GameState.npcs_to_win]

func _on_npcs_served_changed(count: int) -> void:
	_update_label(count)

func _on_game_over() -> void:
	var screen := GAME_OVER_SCENE.instantiate()
	get_tree().root.add_child(screen)

func _on_game_won() -> void:
	# Load your win screen here — swap path to your actual scene
	var win = load("res://scenes/win_screen.tscn").instantiate()
	get_tree().root.add_child(win)
