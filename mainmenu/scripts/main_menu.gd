# res://mainmenu/scripts/main_menu.gd
extends Node2D

@onready var new_game_btn: Button = $"Panel/MainButtons/New Game"
@onready var continue_btn: Button = $Panel/MainButtons/Continue
@onready var delete_save: Button = $"Panel/Delete Save"

func _ready() -> void:
	_refresh_save_buttons()
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
		
func _refresh_save_buttons() -> void:
	var save_exists := GameState.has_save()
	continue_btn.visible = save_exists
	delete_save.visible = save_exists

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
	
func _on_statistics_pressed() -> void:
	$StatsMenu.refresh()
	$StatsMenu.show()
	
func _on_delete_save_pressed() -> void:
	GameState.delete_save()
	_refresh_save_buttons()
	
