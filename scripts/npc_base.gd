extends CharacterBody2D

const SPEED: float = 40.0

@export var seats: Array[Node] = []
@onready var nav_agent := $NavigationAgent2D
@onready var anim_sprite := $AnimatedSprite2D

var target_seat: Area2D = null

func _ready() -> void:
	seats = get_tree().get_nodes_in_group("computer_seats")
	await get_tree().physics_frame
	find_vacant_seat()

func _physics_process(_delta: float) -> void:
	if target_seat == null:
		return
	
	if target_seat.is_taken:
		find_vacant_seat()

	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		anim_sprite.play("idle")
		global_position = target_seat.global_position
		target_seat.occupy()
		target_seat = null
	else:
		var current_agent_position = global_position
		var next_path_position = nav_agent.get_next_path_position()
		var new_velocity = current_agent_position.direction_to(next_path_position) * SPEED
		
		if nav_agent.avoidance_enabled:
			nav_agent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
		move_and_slide()

		if velocity.x != 0:
			anim_sprite.flip_h = velocity.x < 0

		if velocity.length() > 0.1:
			anim_sprite.play("walk")
		else:
			anim_sprite.play("idle")

func find_vacant_seat() -> void:
	var nearest: Area2D = null
	var nearest_dist: float = INF

	for seat in seats:
		if not seat.is_taken:
			var dist = global_position.distance_to(seat.global_position)
			if dist < nearest_dist:
				nearest = seat
				nearest_dist = dist

	if nearest:
		target_seat = nearest
		nav_agent.target_position = nearest.global_position

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_timer_timeout() -> void:
	if target_seat != null and not nav_agent.is_navigation_finished():
		nav_agent.target_position = target_seat.global_position
