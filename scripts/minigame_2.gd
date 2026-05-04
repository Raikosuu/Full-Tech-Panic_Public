extends Node2D

const WireScene = preload("res://scenes/rj_54_wires.tscn")
const CORRECT_ORDER = [
	"OrangeWhite","Orange","GreenWhite","Blue",
	"BlueWhite","Green","BrownWhite","Brown"
]
const WIRE_DATA = [
	{name="OrangeWhite", color=Color(0.96,0.55,0.18), stripe=true},
	{name="Orange",      color=Color(0.93,0.38,0.05), stripe=false},
	{name="GreenWhite",  color=Color(0.30,0.80,0.35), stripe=true},
	{name="Blue",        color=Color(0.15,0.30,0.90), stripe=false},
	{name="BlueWhite",   color=Color(0.40,0.60,0.97), stripe=true},
	{name="Green",       color=Color(0.05,0.62,0.15), stripe=false},
	{name="BrownWhite",  color=Color(0.78,0.55,0.38), stripe=true},
	{name="Brown",       color=Color(0.45,0.24,0.08), stripe=false},
]

@export var time_limit: float = 30.0
var time_left: float
var game_active: bool = false

@onready var wire_pool = $WirePool
@onready var connector = $rj45_connector
@onready var crimp_btn = $CrimpButton
@onready var feedback = $FeedbackLabel
@onready var timer_bar = $TimerBar

func _ready():
	Input.use_accumulated_input = false
	crimp_btn.pressed.connect(_on_crimp_pressed)
	timer_bar.max_value = time_limit
	start_game()

func start_game():
	#feedback.text = ""
	time_left = time_limit
	game_active = true

	# Clear old wires
	for child in wire_pool.get_children():
		child.queue_free()
	connector.reset()

	# Spawn and shuffle wires
	var shuffled = WIRE_DATA.duplicate()
	shuffled.shuffle()
	for i in 8:
		var wire = WireScene.instantiate()
		wire_pool.add_child(wire)
		wire.global_position = Vector2(40 + i * 34, 150)
		wire.setup(shuffled[i].color, shuffled[i].stripe, shuffled[i].name)

var flash_timer: float = 0.0

func _process(delta):
	if not game_active:
		return

	time_left -= delta
	timer_bar.value = time_left
	_update_timer_color()

	# Flash effect under 25%
	if time_left < time_limit * 0.25:
		flash_timer += delta
		timer_bar.modulate.a = 1.0 if fmod(flash_timer, 0.5) < 0.25 else 0.3
	else:
		flash_timer = 0.0
		timer_bar.modulate.a = 1.0

	if time_left <= 0:
		_on_time_up()

func _update_timer_color():
	var fill_style = timer_bar.get_theme_stylebox("fill").duplicate()
	if time_left > time_limit * 0.5:
		fill_style.bg_color = Color(0.13, 0.80, 0.27)
	elif time_left > time_limit * 0.25:
		fill_style.bg_color = Color(0.93, 0.70, 0.05)
	else:
		fill_style.bg_color = Color(0.90, 0.15, 0.15)
	timer_bar.add_theme_stylebox_override("fill", fill_style)

func on_wire_placed(slot_index: int, wire_name: String):
	pass   # hook for future logic (sound, particles, etc.)

func _on_crimp_pressed():
	if not game_active:
		return
	var placed = connector.get_all_wires()
	if placed == CORRECT_ORDER:
		_win()
	else:
		_show_errors(placed)

func _win():
	game_active = false
	feedback.text = "PERFECT CRIMP!"
	feedback.modulate = Color.GREEN

func _on_time_up():
	game_active = false
	feedback.text = "TIME'S UP!"
	feedback.modulate = Color.RED

func _show_errors(placed: Array):
	feedback.text = "WRONG ORDER!"
	feedback.modulate = Color.RED
	for i in 8:
		if placed[i] != CORRECT_ORDER[i]:
			connector.get_slot(i).flash_error()
