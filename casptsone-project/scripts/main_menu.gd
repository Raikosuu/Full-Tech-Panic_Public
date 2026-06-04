extends Node2D

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	settings.visible = false

func _on_game_start_pressed() -> void:
	pass # Replace with function body.


func _on_how_to_play_pressed() -> void:
	pass # Replace with function body.


func _on_learn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/learn.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings.visible = true

func _on_back_pressed() -> void:
	_ready()
