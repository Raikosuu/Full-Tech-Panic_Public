extends Control

@onready var anim_player  = $AnimationPlayer
@onready var scroll_clip  = $ScrollClip
@onready var credits_text = $ScrollClip/CreditsText
@onready var skip_button  = $SkipButton

@export var scroll_speed: float = 35.0
@export var start_delay:  float = 1.5

var _scroll_tween: Tween

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	credits_text.visible = false
	credits_text.position.y = scroll_clip.size.y
	_start_scroll()

func _start_scroll() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	credits_text.position.y = scroll_clip.size.y
	credits_text.visible = true
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	var distance = scroll_clip.size.y + credits_text.size.y
	var duration = distance / scroll_speed
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(credits_text, "position:y", -credits_text.size.y, duration)
	_scroll_tween.finished.connect(_on_scroll_done)

func _on_scroll_done() -> void:
	anim_player.play("show_title")

func _on_skip_pressed() -> void:
	if _scroll_tween and _scroll_tween.is_valid():
		_scroll_tween.kill()
	_on_scroll_done()

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
