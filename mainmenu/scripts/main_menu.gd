extends Node2D

@onready var main_buttons: VBoxContainer = $Panel/MainButtons
@onready var settings_panel: Panel = $SettingsPanel

func _ready():
	var bgm = load("res://sfx/sergequadrado-menu-music-251877.mp3") as AudioStream
	BGMManager.play(bgm, 0.0)
	main_buttons.visible = true
	settings_panel.visible = false


func _on_game_start_pressed() -> void:
	get_tree().change_scene_to_file("res://cutscenes/prologue.tscn")


func _on_how_to_play_pressed() -> void:
	pass # Replace with function body.


func _on_learn_pressed() -> void:
	get_tree().change_scene_to_file("res://learn/scenes/learn.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings_panel.visible = true


func _on_back_pressed() -> void:
	_ready()
