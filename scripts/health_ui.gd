extends CanvasLayer

# Filled and empty heart characters (or swap for TextureRect if you have sprites)
const HEART_FULL  : String = "♥"
const HEART_EMPTY : String = "♡"

@onready var _container: HBoxContainer = $Panel/MarginContainer/Hearts

func _ready() -> void:
	HealthState.health_changed.connect(_on_health_changed)
	_refresh(HealthState.health)

func _on_health_changed(new_health: int) -> void:
	_refresh(new_health)

func _refresh(current: int) -> void:
	for i in _container.get_child_count():
		var lbl := _container.get_child(i) as Label
		if lbl:
			lbl.text = HEART_FULL if i < current else HEART_EMPTY
