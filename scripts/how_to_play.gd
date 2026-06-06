extends Control

const TUTORIALS = [
	[
		"Player Controls",
		"res://assets/tutorials/tutorial_move.ogv",
		"Drag the bottom left side of the screen to move. Press the button to interact with the seated NPC."
	],
	[
		"PC Assembly",
		"res://assets/tutorials/tutorial_assembly.ogv",
		"Drag and drop computer parts into the system unit in the correct order before time runs out."
	],
	[
		"PC Disassembly",
		"res://assets/tutorials/tutorial_disassembly.ogv",
		"Remove all components from the system unit by clicking and dragging them out in the right sequence."
	],
	[
		"RJ45 Crimping — T568-B",
		"res://assets/tutorials/tutorial_rj45b.ogv",
		"Arrange the wires in T568-B order in the slots, then press CRIMP before the timer runs out."
	],
	[
		"RJ45 Crimping — T568-A",
		"res://assets/tutorials/tutorial_rj45a.ogv",
		"Arrange the wires in T568-A order in the slots, then press CRIMP before the timer runs out."
	],
]

var current_index: int = 0

@onready var video_player: VideoStreamPlayer = $VBox/VideoPlayer
@onready var title_label: Label = $VBox/TopBar/TitleLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var prev_button: Button = $VBox/NavRow/PrevButton
@onready var next_button: Button = $VBox/NavRow/NextButton
@onready var page_label: Label = $VBox/TopBar/PageLabel
@onready var back_button: Button = $VBox/TopBar/BackButton


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	video_player.finished.connect(_on_video_finished)
	_load_tutorial(current_index)


func _load_tutorial(index: int) -> void:
	var entry = TUTORIALS[index]
	title_label.text = entry[0]
	desc_label.text = entry[2]

	var stream = load(entry[1])
	if stream:
		video_player.stream = stream
		video_player.play()
	else:
		push_warning("Tutorial video not found: " + entry[1])

	page_label.text = "%d / %d" % [index + 1, TUTORIALS.size()]
	prev_button.disabled = (index == 0)
	next_button.disabled = (index == TUTORIALS.size() - 1)


func _on_video_finished() -> void:
	video_player.play()


func _on_prev_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		_load_tutorial(current_index)


func _on_next_pressed() -> void:
	if current_index < TUTORIALS.size() - 1:
		current_index += 1
		_load_tutorial(current_index)


func _on_back_pressed() -> void:
	video_player.stop()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
