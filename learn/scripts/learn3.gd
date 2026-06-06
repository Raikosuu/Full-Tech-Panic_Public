extends Control

@onready var soundcardpanel: Panel = $soundcardpanel
@onready var soundcard_btn: Button = $soundcard

func _ready() -> void:
	soundcardpanel.visible = false

func _on_soundcard_toggled(pressed: bool) -> void:
	soundcardpanel.visible = pressed

func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch and event.pressed):
		return
	if soundcard_btn.get_global_rect().has_point(event.position):
		soundcard_btn.button_pressed = not soundcard_btn.button_pressed
		soundcardpanel.visible = soundcard_btn.button_pressed
