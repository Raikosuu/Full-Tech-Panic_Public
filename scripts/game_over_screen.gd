extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	$Panel/VBoxContainer/ButtonMargin/ButtonBox/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/ButtonMargin/ButtonBox/MainMenuButton.pressed.connect(_on_main_menu)

func _on_retry() -> void:
	get_tree().paused = false
	HealthState.reset()
	GameState.reset_level()
	var intro := GameState.get_intro_cutscene()
	queue_free()
	if intro != "":
		get_tree().change_scene_to_file(intro)
	else:
		get_tree().change_scene_to_file(GameState.current_level_scene)

func _on_main_menu() -> void:
	get_tree().paused = false
	HealthState.reset()
	GameState.load_level(0)
	queue_free()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
