extends Control

@onready var soundcardpanel: Panel = $soundcardpanel
@onready var soundcard_btn: Button = $soundcard

func _ready() -> void:
	soundcardpanel.visible = false

func _on_soundcard_toggled(pressed: bool) -> void:
	soundcardpanel.visible = pressed
