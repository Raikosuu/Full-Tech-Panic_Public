extends ProgressBar

func _ready() -> void:
	min_value = 0
	max_value = 100
	value = 100
	show_percentage = false

func set_ratio(ratio: float) -> void:
	value = ratio * 100.0
