extends Node

signal health_changed(new_health: int)
signal game_over()

const MAX_HEALTH: int = 3
var health: int = MAX_HEALTH
var _game_over_fired: bool = false

func take_damage() -> void:
	if health <= 0:
		return
	health -= 1
	emit_signal("health_changed", health)
	if health <= 0 and not _game_over_fired:
		_game_over_fired = true
		emit_signal("game_over")

func reset() -> void:
	health = MAX_HEALTH
	_game_over_fired = false
	emit_signal("health_changed", health)
