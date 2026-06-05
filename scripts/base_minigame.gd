class_name BaseMinigame
extends Node2D

@export var completion_delay: float = 1.0
@export var time_limit: float = 120.0
@export var overlay_duration: float = 2.0   # how long the win/lose screen shows

@export var win_screen_scene: PackedScene
@export var lose_screen_scene: PackedScene

var _completed: bool = false
var _failed: bool = false
var _time_remaining: float = 0.0
var _overlay: CanvasLayer = null

@export var timer_label: NodePath = NodePath("")
@export var timer_bar: NodePath   = NodePath("")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_time_remaining = time_limit
	_on_minigame_ready()

func _process(delta: float) -> void:
	if _completed or _failed or time_limit <= 0.0:
		return
	_time_remaining -= delta
	_update_timer_ui()
	if _time_remaining <= 0.0:
		_time_remaining = 0.0
		_fail()

func _update_timer_ui() -> void:
	if timer_label:
		var n := get_node_or_null(timer_label)
		if n:
			var secs := int(_time_remaining)
			n.text = "%d:%02d" % [secs / 60, secs % 60]
	if timer_bar:
		var n := get_node_or_null(timer_bar)
		if n and n.has_method("set_ratio"):
			n.set_ratio(_time_remaining / time_limit)

func _on_minigame_ready() -> void:
	pass

func try_complete() -> void:
	if _completed or _failed:
		return
	if _check_completion():
		_completed = true
		_on_complete()
		_finish()

func _fail() -> void:
	if _completed or _failed:
		return
	_failed = true
	_on_fail()
	_finish_fail()

func _check_completion() -> bool:
	return false

func _on_complete() -> void:
	pass

func _on_fail() -> void:
	pass

func _show_overlay(scene: PackedScene) -> void:
	if scene == null:
		return
	_overlay = scene.instantiate()
	add_child(_overlay)

func _apply_blur() -> void:
	var env_node := get_node_or_null("WorldEnvironment")
	if env_node and env_node.environment:
		env_node.environment.adjustment_enabled = true
		env_node.environment.adjustment_brightness = 0.4
	var cl := CanvasLayer.new()
	cl.layer = 18
	add_child(cl)
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.0, 0.0, 0.0, 0.45)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE  # ← ADD THIS
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cl.add_child(dimmer)

func _finish() -> void:
	if completion_delay > 0.0:
		await get_tree().create_timer(completion_delay, true, false, true).timeout
	_apply_blur()
	if win_screen_scene:
		_show_overlay(win_screen_scene)
	await get_tree().create_timer(overlay_duration, true, false, true).timeout
	GameState.exit_minigame()

func _finish_fail() -> void:
	if completion_delay > 0.0:
		await get_tree().create_timer(completion_delay, true, false, true).timeout
	_apply_blur()
	if lose_screen_scene:
		_show_overlay(lose_screen_scene)
	await get_tree().create_timer(overlay_duration, true, false, true).timeout
	GameState.fail_minigame()
