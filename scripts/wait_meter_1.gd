extends Node

@onready var wait_meter = $ProgressBar
@onready var timer = $Timer

func _ready():
	wait_meter.min_value = 0
	wait_meter.max_value = timer.wait_time
	wait_meter.value = timer.wait_time  # start full

func start_wait():
	wait_meter.value = timer.wait_time
	timer.start()

func _process(delta):
	if not timer.is_stopped():
		# Show remaining time directly (shrinks down)
		wait_meter.value = timer.time_left

func _on_Timer_timeout():
	wait_meter.value = 0  # make sure it ends empty
	print("Countdown finished!")
