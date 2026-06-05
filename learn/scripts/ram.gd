extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var rampanel: Panel = $"../rampanel"

func _ready():
	learnpanel.visible = true
	rampanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	rampanel.visible = true


func _on_ram_pressed() -> void:
	_ready()
