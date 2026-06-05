extends CanvasLayer

func _ready() -> void:
	# Don't pause the tree — just make sure this layer is on top
	# and blocks input to everything below it
	layer = 100  # guarantee it's above everything else
	$Dimmer.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks going through dimmer
	$Panel.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBoxContainer/ButtonMargin/ButtonBox/RetryButton.pressed.connect(_on_retry)
	$Panel/VBoxContainer/ButtonMargin/ButtonBox/MainMenuButton.pressed.connect(_on_main_menu)

func _on_retry() -> void:
	HealthState.reset()
	GameState.reset_level()
	var intro := GameState.get_intro_cutscene()
	queue_free()
	if intro != "":
		get_tree().change_scene_to_file(intro)
	else:
		get_tree().change_scene_to_file(GameState.current_level_scene)

func _on_main_menu() -> void:
	HealthState.reset()
	GameState.load_level(0)
	queue_free()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
