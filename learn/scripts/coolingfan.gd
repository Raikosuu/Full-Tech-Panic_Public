extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var coolingfanpanel: Panel = $"../coolingfanpanel"

func _ready():
	learnpanel.visible = true
	coolingfanpanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	coolingfanpanel.visible = true


func _on_coolingfan_pressed() -> void:
	_ready()
