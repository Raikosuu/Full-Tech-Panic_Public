extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var psupanel: Panel = $"../psupanel"

func _ready():
	learnpanel.visible = true
	psupanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	psupanel.visible = true


func _on_psu_pressed() -> void:
	_ready()
