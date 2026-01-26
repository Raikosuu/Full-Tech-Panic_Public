extends Control

@onready var fade_transition: ColorRect = $"../fade_transition"

var button_type = null

func _on_play_pressed() -> void:
	button_type = "play"
	$fade_transition.show()
	$fade_transition/Fade_timer.start()
	$fade_transition/AnimationPlayer.play("fade_in")
	
func _on_learn_pressed() -> void:
	pass # Replace with function body.


func _on_htp_pressed() -> void:
	pass # Replace with function body.


func _on_fade_timer_timeout() -> void:
	if button_type == "play":
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
