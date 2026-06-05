extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var hddpanel: Panel = $"../hddpanel"

func _ready():
	learnpanel.visible = true
	hddpanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	hddpanel.visible = true


func _on_button_pressed() -> void:
	_ready()
