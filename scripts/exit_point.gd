extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.get("is_exiting"):
		return
	var anim: AnimationPlayer = body.get_node_or_null("AnimationPlayer")
	if anim and anim.has_animation("fade_out"):
		anim.play("fade_out")
		await anim.animation_finished
	body.queue_free()
