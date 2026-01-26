extends CharacterBody2D

@export var movement_speed: float = 300.0
var ACCEL = 2.0
var character_direction: Vector2
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process (_delta): 
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	
	# Normalize so diagonal speed is consistent
	character_direction = character_direction.normalized()
	
	#flip facing directions when moving
	if character_direction.x > 0:
		sprite.flip_h = false
	elif character_direction.x < 0:
		sprite.flip_h = true
		
	#switch to run when moving
	if character_direction:
		#accelerate when moving
		velocity = character_direction * movement_speed
		if sprite.animation != "run":
			sprite.animation = "run"
	#switch to run when not moving		
	else:
		#decelerate when stopping
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if sprite.animation != "idle":
			sprite.animation = "idle"
	
	#normalize values
	character_direction.normalized()			
	move_and_slide()


"""
movement with acceleration and deceleration

extends CharacterBody2D

@export var movement_speed: float = 300.0
var ACCEL: float = 2.0
var character_direction: Vector2 = Vector2.ZERO
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
    # Get input direction
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
    
    # Normalize so diagonal speed is consistent
    character_direction = character_direction.normalized()
    
    # Flip sprite depending on direction
    if character_direction.x > 0:
        sprite.flip_h = false
    elif character_direction.x < 0:
        sprite.flip_h = true
    
    # Handle animations and velocity
    if character_direction != Vector2.ZERO:
        # Accelerate toward movement
        velocity = lerp(velocity, character_direction * movement_speed, delta * ACCEL)
		if sprite.animation != "run":
			sprite.animation = "run"
    else:
        # Decelerate when idle
        velocity = velocity.move_toward(Vector2.ZERO, movement_speed * delta * ACCEL)
		if sprite.animation != "idle":
			sprite.animation = "idle"
    
    # Apply movement
    move_and_slide()
"""
