extends CharacterBody2D

@export var movement_speed: float = 300.0
@export var interaction_radius: float = 20.0
var ACCEL = 2.0
var character_direction: Vector2
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var nearby_npc: CharacterBody2D = null
var interact_label: Label = null

func _ready() -> void:
	interact_label = Label.new()
	interact_label.z_index = 100
	interact_label.text = "Interact"
	interact_label.position = Vector2(-13, -25)
	interact_label.visible = false
	
	# Create a dynamic font
	var font = FontFile.new()
	font.font_data = load("res://assets/fonts/PixelGamer-Regular.otf")
	
	# Apply the font to the label
	interact_label.add_theme_font_override("font", font)
	
	# You can still override size separately if needed
	interact_label.add_theme_font_size_override("font_size", 6)
	
	add_child(interact_label)

func _physics_process(_delta):
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()

	if character_direction.x > 0:
		sprite.flip_h = false
	elif character_direction.x < 0:
		sprite.flip_h = true

	if character_direction:
		velocity = character_direction * movement_speed
		if sprite.animation != "run":
			sprite.animation = "run"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if sprite.animation != "idle":
			sprite.animation = "idle"

	move_and_slide()
	_check_nearby_npcs()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearby_npc != null:
		GameState.interacted_npc = nearby_npc
		nearby_npc = null
		interact_label.visible = false
		GameState.enter_minigame("res://scenes/minigame1_assembly.tscn")

func _check_nearby_npcs() -> void:
	var closest: CharacterBody2D = null
	var closest_dist: float = interaction_radius

	var npc_handler = get_node_or_null("../npc_handler")
	if npc_handler:
		for npc in npc_handler.get_children():
			# Skip NPCs that are leaving or already exiting
			if npc.get("_leaving") or npc.get("is_exiting"):
				continue
			if npc.has_method("find_vacant_seat") and npc.get("target_seat") == null:
				var dist = global_position.distance_to(npc.global_position)
				if dist < closest_dist:
					closest = npc
					closest_dist = dist

	nearby_npc = closest
	interact_label.visible = (nearby_npc != null)
