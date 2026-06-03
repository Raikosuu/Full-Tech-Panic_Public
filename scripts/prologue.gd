extends Node2D
## Prologue — Day 1 cutscene
## Driven by AnimationPlayer + a typed-text dialogue system.
## All dialogue content lives in SCRIPT below; AnimationPlayer handles
## fade-ins, shake, and the title card.  The script advances on SPACE / click.

# ── Node references (set in _ready) ──────────────────────────────────────────
@onready var anim:          AnimationPlayer = $AnimationPlayer
@onready var backdrop:      ColorRect       = $UI/Backdrop
@onready var title_card:    VBoxContainer   = $UI/TitleCard
@onready var dialogue_box:  PanelContainer  = $UI/DialogueBox
@onready var speaker_name:  Label           = $UI/DialogueBox/HBox/VBox/SpeakerName
@onready var dialogue_text: RichTextLabel   = $UI/DialogueBox/HBox/VBox/DialogueText
@onready var prompt_label:  Label           = $UI/DialogueBox/HBox/VBox/PromptLabel
@onready var portrait_rect: ColorRect       = $UI/DialogueBox/HBox/SpeakerPortrait

# ── Dialogue script ───────────────────────────────────────────────────────────
# Each entry: { speaker, portrait_color, text }
# Use [shake] ... [/shake] or [color=#…] for BBCode flair.
const SCRIPT: Array[Dictionary] = [
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "Okay... first day in the ITRC. \n I can do this.\nJust fix computers. How hard can it be?"
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Oh good, you came! We've got\n[color=#ff9933]47 tickets[/color] from the students\n already and it's not even 9 AM."
	},
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "...Fourty-seven??"
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Karen from JHS says her monitor\nis 'breathing.' Dave from college dismembered a PC\nagain. And someone crimped a cable\n[color=#ff4444]with a stapler.[/color]"
	},
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "A... stapler??!"
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Each user has a [color=#ffdd44]patience bar.[/color]\nLet it hit zero — they walk.\nYou get a mark on your record."
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Three marks and I have to write up a\nvery strongly-worded email. I hate\nwriting emails. [color=#ff4444]Don't make me do that.[/color]"
	},
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "Crystal clear."
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Great. The queue's already piling up.\nGood luck. You'll need it."
	},
]

# ── State ─────────────────────────────────────────────────────────────────────
var _line_index:      int   = 0
var _typing:          bool  = false
var _full_text:       String = ""
var _visible_chars:   int   = 0
var _type_timer:      float = 0.0
const TYPE_SPEED:     float = 0.03   # seconds per character
var _waiting_advance: bool  = false  # true when line is fully shown
var _prologue_done:   bool  = false
var _title_shown:     bool  = false

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	prompt_label.modulate.a = 0.0
	dialogue_box.modulate.a = 0.0
	# Play opening animations defined in AnimationPlayer
	anim.play("intro_fade")

func _process(delta: float) -> void:
	if _typing:
		_type_timer += delta
		while _type_timer >= TYPE_SPEED and _visible_chars < _full_text.length():
			_type_timer -= TYPE_SPEED
			_visible_chars += 1
			dialogue_text.visible_characters = _visible_chars
		if _visible_chars >= _full_text.length():
			_typing = false
			_waiting_advance = true
			_blink_prompt(true)

func _input(event: InputEvent) -> void:
	if _prologue_done:
		return
	var advance := false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_Z:
			advance = true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true

	if not advance:
		return

	if not _title_shown:
		return   # wait for title animation to call show_dialogue()

	if _typing:
		# Skip typing — show all text immediately
		_visible_chars = _full_text.length()
		dialogue_text.visible_characters = _visible_chars
		_typing = false
		_waiting_advance = true
		_blink_prompt(true)
		return

	if _waiting_advance:
		_waiting_advance = false
		_blink_prompt(false)
		_line_index += 1
		if _line_index >= SCRIPT.size():
			_end_prologue()
		else:
			_show_line(_line_index)

# ── Called by AnimationPlayer "intro_fade" animation at its end ───────────────

func show_dialogue() -> void:
	_title_shown = true
	anim.play("dialogue_slide_in")

func on_dialogue_ready() -> void:
	_show_line(0)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _show_line(index: int) -> void:
	var entry: Dictionary = SCRIPT[index]
	speaker_name.text = entry["speaker"]
	speaker_name.add_theme_color_override("font_color", entry["color"])
	portrait_rect.color = entry["color"].darkened(0.6)

	_full_text = entry["text"]
	dialogue_text.text = _full_text          # set full BBCode source
	dialogue_text.visible_characters = 0
	_visible_chars = 0
	_type_timer    = 0.0
	_typing        = true

	# Animate the box with a tiny bounce for each new line
	anim.play("line_pop")

func _blink_prompt(on: bool) -> void:
	if on:
		var tween := create_tween().set_loops()
		tween.tween_property(prompt_label, "modulate:a", 0.0, 0.5)
		tween.tween_property(prompt_label, "modulate:a", 1.0, 0.5)
	else:
		# Stop tween by killing all tweens on this node; reset alpha
		get_tree().create_timer(0.0).timeout.connect(
			func(): prompt_label.modulate.a = 0.0
		)

func _end_prologue() -> void:
	_prologue_done = true
	anim.play("outro_fade")

# Called by AnimationPlayer "outro_fade" at the end via Animation Method Track
func go_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
