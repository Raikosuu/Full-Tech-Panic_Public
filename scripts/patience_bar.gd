extends ProgressBar

func _ready() -> void:
	min_value = 0
	max_value = 100
	value = 100
	show_percentage = false
	# Give each instance its own copy so NPCs don't share the same color state
	var fill_style := get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		add_theme_stylebox_override("fill", fill_style.duplicate())

func set_ratio(ratio: float) -> void:
	value = ratio * 100.0
	var fill_style := get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		fill_style.bg_color = Color(1.0 - ratio, ratio * 0.8, ratio * 0.3, 0.99)
