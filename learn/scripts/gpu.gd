extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var gpupanel: Panel = $"../gpupanel"

func _ready():
	learnpanel.visible = true
	gpupanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	gpupanel.visible = true


func _on_gpu_pressed() -> void:
	_ready()
