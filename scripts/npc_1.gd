extends CharacterBody2D

const SPEED: float = 30.0

@export var seats: Node2D
@onready var nav_agent := $NavigationAgent2D
@onready var anim_sprite := $AnimatedSprite2D  

func _ready() -> void:
	makepath()

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		anim_sprite.play("idle")   # idle animation when not moving
	else:
		var dir = (nav_agent.get_next_path_position() - global_position).normalized()
		velocity = dir * SPEED
		move_and_slide()

		# Flip horizontally depending on direction
		if velocity.x != 0:
			anim_sprite.flip_h = velocity.x < 0

		# Play walk animation if moving
		if velocity.length() > 0.1:
			anim_sprite.play("walk")
		else:
			anim_sprite.play("idle")
	
		if global_position.distance_to(seats.global_position) < 5.0:
			velocity = Vector2.ZERO
			global_position = seats.global_position   # snap to seat
			

func makepath() -> void:
	if seats:
		nav_agent.target_position = seats.global_position

func _on_timer_timeout() -> void:
	makepath()
