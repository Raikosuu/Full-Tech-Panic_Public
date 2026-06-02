extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	$Panel/VBoxContainer/ButtonMargin/ButtonBox/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/ButtonMargin/ButtonBox/MainMenuButton.pressed.connect(_on_main_menu)

func _on_retry() -> void:
	get_tree().paused = false
	HealthState.reset()
	queue_free()
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_main_menu() -> void:
	get_tree().paused = false
	HealthState.reset()
	queue_free()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
