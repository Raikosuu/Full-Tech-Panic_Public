extends Node2D
## Epilogue — End of shift cutscene

const PORTRAITS: Dictionary = {
	"You":  "res://assets/portraits/portrait_you.png",
	"Boss": "res://assets/portraits/portrait_boss.png",
}

const SCRIPT: Array[Dictionary] = [
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "That's the last of them.\nI genuinely did not think you'd pull it off."
	},
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "...Thanks. I think."
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "Queue's [color=#44ff88]cleared.[/color]\nNo marks on your record.\nEven the stapler guy got his cable fixed."
	},
	{
		"speaker": "You",
		"color":   Color(0.4, 0.8, 1.0),
		"text":    "So... same time tomorrow?"
	},
	{
		"speaker": "Boss",
		"color":   Color(1.0, 0.6, 0.2),
		"text":    "We've already got [color=#ff9933]31 new tickets.[/color]\nGet some sleep."
	},
]

@onready var anim:           AnimationPlayer   = $AnimationPlayer
@onready var backdrop:       ColorRect         = $UI/Backdrop
@onready var title_card:     Node              = $UI/TitlePanel
@onready var dialogue_box:   PanelContainer    = $UI/DialogueBox
@onready var speaker_name:   Label             = $UI/DialogueBox/VBox/SpeakerName
@onready var dialogue_text:  RichTextLabel     = $UI/DialogueBox/VBox/DialogueText
@onready var prompt_label:   Label             = $UI/DialogueBox/VBox/PromptLabel
@onready var portrait_you:   TextureRect       = $UI/PortraitYou
@onready var portrait_boss:  TextureRect       = $UI/PortraitBoss
@onready var skip_button:    Button            = $UI/SkipButton
@onready var typing_sound:   AudioStreamPlayer = $TypingSound
@onready var advance_sound:  AudioStreamPlayer = $AdvanceSound

const ALPHA_ACTIVE:   float = 1.0
const ALPHA_INACTIVE: float = 0.8
const TWEEN_SPEED:    float = 0.25

var _line_index:      int    = 0
var _typing:          bool   = false
var _full_text:       String = ""
var _visible_chars:   int    = 0
var _type_timer:      float  = 0.0
const TYPE_SPEED:     float  = 0.03
var _waiting_advance: bool   = false
var _epilogue_done:   bool   = false
var _title_shown:     bool   = false
var _prompt_tween:    Tween  = null

func _ready() -> void:
	# Reuse your existing BGM or swap to an ending track
	var bgm = load("res://sfx/freesound_community-gamemusic-6082.mp3") as AudioStream
	BGMManager.play(bgm, -10.0)
	skip_button.pressed.connect(_on_skip_pressed)
	prompt_label.modulate.a  = 0.0
	dialogue_box.modulate.a  = 0.0
	title_card.modulate.a    = 0.0
	portrait_you.modulate.a  = ALPHA_INACTIVE
	portrait_boss.modulate.a = ALPHA_INACTIVE

	_load_portrait(portrait_you,  "You")
	_load_portrait(portrait_boss, "Boss")
	portrait_boss.flip_h = true

	dialogue_box.gui_input.connect(_on_dialogue_box_input)
	anim.play("intro_fade")

func _load_portrait(rect: TextureRect, speaker: String) -> void:
	var path: String = PORTRAITS.get(speaker, "")
	if path != "" and ResourceLoader.exists(path):
		rect.texture = load(path)

func _process(delta: float) -> void:
	if not _typing:
		return
	_type_timer += delta
	while _type_timer >= TYPE_SPEED and _visible_chars < _full_text.length():
		_type_timer -= TYPE_SPEED
		_visible_chars += 1
		dialogue_text.visible_characters = _visible_chars
	if _visible_chars >= _full_text.length():
		_typing          = false
		_waiting_advance = true
		typing_sound.stop()
		_blink_prompt(true)

func _input(event: InputEvent) -> void:
	if _epilogue_done or not _title_shown:
		return
	var advance := false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_Z]:
			advance = true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance = true
	if advance:
		_try_advance()

func _on_dialogue_box_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_advance()
		get_viewport().set_input_as_handled()

func _try_advance() -> void:
	if _epilogue_done or not _title_shown:
		return
	if _typing:
		_visible_chars = _full_text.length()
		dialogue_text.visible_characters = _visible_chars
		_typing          = false
		_waiting_advance = true
		typing_sound.stop()
		_blink_prompt(true)
		return
	if _waiting_advance:
		_waiting_advance = false
		_blink_prompt(false)
		advance_sound.play()
		_line_index += 1
		if _line_index >= SCRIPT.size():
			_end_epilogue()
		else:
			_show_line(_line_index)

func show_dialogue() -> void:
	_title_shown = true
	anim.play("dialogue_slide_in")

func on_dialogue_ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_show_line(0)

func _show_line(index: int) -> void:
	var entry: Dictionary = SCRIPT[index]
	var speaker: String   = entry["speaker"]
	var is_boss: bool     = speaker == "Boss"

	speaker_name.text = speaker
	speaker_name.add_theme_color_override("font_color", entry["color"])
	speaker_name.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT if is_boss else HORIZONTAL_ALIGNMENT_LEFT
	dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if is_boss else HORIZONTAL_ALIGNMENT_LEFT

	_tween_alpha(portrait_you,  ALPHA_INACTIVE if is_boss else ALPHA_ACTIVE)
	_tween_alpha(portrait_boss, ALPHA_ACTIVE   if is_boss else ALPHA_INACTIVE)

	_full_text = entry["text"]
	dialogue_text.visible_characters = 0
	dialogue_text.text = ""
	dialogue_text.text = _full_text
	dialogue_text.visible_characters = 0

	_visible_chars = 0
	_type_timer    = 0.0
	_typing        = true
	typing_sound.play()
	anim.play("line_pop")

func _tween_alpha(node: TextureRect, target_alpha: float) -> void:
	var t := create_tween()
	t.tween_property(node, "modulate:a", target_alpha, TWEEN_SPEED)\
	 .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _blink_prompt(on: bool) -> void:
	if _prompt_tween:
		_prompt_tween.kill()
		_prompt_tween = null
	if on:
		_prompt_tween = create_tween().set_loops()
		_prompt_tween.tween_property(prompt_label, "modulate:a", 0.0, 0.5)
		_prompt_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.5)
	else:
		prompt_label.modulate.a = 0.0

func _end_epilogue() -> void:
	_epilogue_done = true
	_blink_prompt(false)
	anim.play("outro_fade")

func _on_skip_pressed() -> void:
	if _epilogue_done:
		return
	_epilogue_done = true
	_blink_prompt(false)
	anim.play("outro_fade")

func go_to_game() -> void:
	# Point to your actual win/credits screen, or main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
