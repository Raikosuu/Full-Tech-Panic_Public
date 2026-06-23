extends Control

const TUTORIALS = [
	[
		"Game Rules",
		"",
		""  # unused when rules_text is set
	],
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
	[
		"PC Diagnosis and Troubleshooting Tools",
		"res://assets/tutorials/tutorial_rj45a.ogv",
		"Read the Tickets on top. Then choose the right troubleshooting tool from the start menu. Scan then choose the right troubleshooting method."
	],
]

const RULES_TEXT = """[b]GAME RULES[/b]

[b]Objective[/b]
You work in an institution as a IT Infrastructure support. Users walk in with tasks that need to be completed correctly and on time. Keep them happy — or they walk out.

[b]Patience Bar[/b]
Every User has a [color=#ffdd44]patience bar[/color] that drains while you work. If it empties before you finish, the customer leaves and you lose a [color=#ff9933]life.[/color] You only have a limited number of lives per stage — don't waste them.

[b]Mini-Games[/b]
[color=#aaddff]PC Assembly[/color] — A User brings in loose parts. Install each component into the system unit in the correct order before time runs out.
[color=#aaddff]PC Disassembly[/color] — Remove all components from the system unit in the proper sequence. Order matters — don't yank the wrong part first.
[color=#aaddff]RJ45 Crimping (T568-B)[/color] — Arrange the eight wires in T568-B color order inside the connector, then hit CRIMP before the timer expires.
[color=#aaddff]RJ45 Crimping (T568-A)[/color] — Same as above but wired to the T568-A standard. Know the difference.

[b]Progression[/b]
Complete a set number of tasks to unlock the next stage. Stages get harder — customers arrive faster and patience drains quicker.

[b]Notes[/b]
- Watch each tutorials before attempting a task for the first time.
- Wrong steps fully drains the customer's patience.
- Speed and accuracy both matter — finishing early keeps the bar full.
- Memorize the wire color orders. You won't always have time to guess.
"""

var current_index: int = 0

@onready var video_player: VideoStreamPlayer = $VBox/VideoPlayer
@onready var title_label: Label = $VBox/TopBar/TitleLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var prev_button: Button = $VBox/NavRow/PrevButton
@onready var next_button: Button = $VBox/NavRow/NextButton
@onready var page_label: Label = $VBox/TopBar/PageLabel
@onready var back_button: Button = $VBox/TopBar/BackButton
@onready var rules_scroll: ScrollContainer = $VBox/RulesScroll
@onready var rules_label: RichTextLabel = $VBox/RulesScroll/RulesLabel


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	video_player.finished.connect(_on_video_finished)
	_load_tutorial(current_index)


func _load_tutorial(index: int) -> void:
	var entry = TUTORIALS[index]
	var is_rules_page = (index == 0)

	title_label.text = entry[0]
	page_label.text = "%d / %d" % [index + 1, TUTORIALS.size()]
	prev_button.disabled = (index == 0)
	next_button.disabled = (index == TUTORIALS.size() - 1)

	if is_rules_page:
		video_player.stop()
		video_player.visible = false
		desc_label.visible = false
		rules_scroll.visible = true
		rules_label.text = RULES_TEXT
	else:
		video_player.visible = true
		desc_label.visible = true
		rules_scroll.visible = false
		desc_label.text = entry[2]

		var stream = load(entry[1])
		if stream:
			video_player.stream = stream
			video_player.play()
		else:
			push_warning("Tutorial video not found: " + entry[1])


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
