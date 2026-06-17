# res://mainmenu/scripts/main_menu.gd
extends Node2D

@onready var new_game_btn: Button = $"Panel/MainButtons/New Game"
@onready var continue_btn: Button = $Panel/MainButtons/Continue

func _ready() -> void:
	# Only show Continue if a save file exists
	continue_btn.visible = GameState.has_save()
	BGMManager.play(GameState.BGM_MENU)

func _on_continue_pressed() -> void:
	GameState.load_game()
	var intro := GameState.get_intro_cutscene()
	if intro != "":
		get_tree().change_scene_to_file(intro)
	else:
		get_tree().change_scene_to_file(GameState.GAME_SCENE)

func _on_new_game_pressed() -> void:
	_start_new_game()

func _start_new_game() -> void:
	GameState.delete_save()
	GameState.load_level(0)
	HealthState.reset()
	var intro := GameState.get_intro_cutscene()
	if intro != "":
		get_tree().change_scene_to_file(intro)
	else:
		get_tree().change_scene_to_file(GameState.GAME_SCENE)

func _on_learn_pressed() -> void:
	get_tree().change_scene_to_file("res://learn/scenes/learn.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	$SettingsPanel.visible = true

func _on_back_pressed() -> void:
	$SettingsPanel.visible = false
