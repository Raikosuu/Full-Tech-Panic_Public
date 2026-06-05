extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var computertowerpanel: Panel = $"../computertowerpanel"

func _ready():
	learnpanel.visible = true
	computertowerpanel.visible = false

func _on_pressed() -> void:
	learnpanel.visible = true
	computertowerpanel.visible = true


func _on_computertower_pressed() -> void:
	_ready()
