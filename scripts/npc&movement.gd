extends PathFollow2D

@export var run_speed: float = 50.0

func _process(delta: float) -> void:
	progress += run_speed * delta
	
	
