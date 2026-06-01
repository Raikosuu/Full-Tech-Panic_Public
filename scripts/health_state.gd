extends Node

signal health_changed(new_health: int)
signal game_over()

const MAX_HEALTH: int = 3
var health: int = MAX_HEALTH

func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("game_over")

func reset() -> void:
	health = MAX_HEALTH
	emit_signal("health_changed", health)
