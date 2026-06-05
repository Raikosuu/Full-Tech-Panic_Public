extends Button

@onready var learnpanel: Panel = $"../learnpanel"
@onready var soundcardpanel: Panel = $"../soundcardpanel"

func _ready():
	learnpanel.visible = true
	soundcardpanel.visible = false
	
func _on_pressed() -> void:
	learnpanel.visible = true
	soundcardpanel.visible = true


func _on_soundcard_pressed() -> void:
	_ready()
