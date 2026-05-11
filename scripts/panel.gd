extends "res://scripts/drag_cont.gd"

func _ready() -> void:
	freeze = true
	gravity_scale = 0
	_disable_screw_snap_zones()
	for screw in $screws.get_children():
		screw.screwed_off.connect(_on_screw_removed)
		screw.snap_zone = screw.get_node("SnapZone")

func _on_screw_removed() -> void:
	var removed_count = 0
	for screw in $screws.get_children():
		if screw.is_removed:
			removed_count += 1
	if removed_count >= $screws.get_child_count():
		freeze = false
	else:
		freeze = true

func _disable_screw_snap_zones() -> void:
	for screw in $screws.get_children():
		var sz = screw.get_node_or_null("SnapZone")
		if sz:
			sz.monitoring = false
			sz.monitorable = false

func enable_screw_snap_zones() -> void:
	for screw in $screws.get_children():
		var sz = screw.get_node_or_null("SnapZone")
		if sz:
			sz.monitoring = true
			sz.monitorable = true
