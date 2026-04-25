extends Node2D

@export var countdown_time: float = 5.0
var elapsed: float = 0.0
var active: bool = false

@onready var wait_meter: TextureProgressBar = $wait_meter
@onready var timer: Timer = $wait_meter/Timer


func _ready():
	wait_meter.min_value = 0
	wait_meter.max_value = countdown_time
	wait_meter.value = countdown_time
	wait_meter.visible = false
	timer.timeout.connect(_on_timer_tick)

func start_countdown():
	elapsed = 0.0
	wait_meter.value = countdown_time
	wait_meter.visible = true
	active = true
	timer.start()

func reset_countdown():
	timer.stop()
	wait_meter.visible = false
	active = false

func _on_timer_tick():
	if active:
		elapsed += timer.wait_time
		wait_meter.value = countdown_time - elapsed
		if elapsed >= countdown_time:
			timer.stop()
			wait_meter.visible = false
			active = false
			print("Seat timer finished!")
