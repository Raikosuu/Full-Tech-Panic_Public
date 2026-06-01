extends Node2D

const GAME_OVER_SCENE = preload("res://scenes/game_over_screen.tscn")

func _ready() -> void:
	# Connect every time the scene is entered so it always works
	# (HealthState persists across scenes as an autoload)
	if not HealthState.game_over.is_connected(_on_game_over):
		HealthState.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	var screen := GAME_OVER_SCENE.instantiate()
	# Add at root so it sits above everything including CanvasLayers
	get_tree().root.add_child(screen)
