extends CanvasLayer

signal resumed

var context: String = "game"

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var save_btn:   Button = $Panel/VBox/SaveButton
@onready var quit_btn:   Button = $Panel/VBox/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(_on_resume_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	emit_signal("resumed")

func _on_save_pressed() -> void:
	GameState.save_game()
	emit_signal("resumed")

func _on_quit_pressed() -> void:
	var owner_node = get_parent()
	if owner_node and owner_node.has_method("_do_resume"):
		owner_node._do_resume()
	get_tree().paused = false
	GameState.save_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
