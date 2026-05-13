extends BaseMinigame

const REQUIRED_PARTS: Array[String] = ["PANEL", "BATTERY", "MOBO", "CPU", "RAM", "HDD"]

var _snapped_parts: Array[String] = []

func _on_minigame_ready() -> void:
	_connect_snap_zones(self)

func _connect_snap_zones(node: Node) -> void:
	for child in node.get_children():
		if child.has_signal("part_snapped"):
			if not child.is_connected("part_snapped", _on_part_snapped):
				child.part_snapped.connect(_on_part_snapped)
		_connect_snap_zones(child)

func _on_part_snapped(slot_type: String) -> void:
	if slot_type not in _snapped_parts:
		_snapped_parts.append(slot_type)
		print("Snapped: %s  (%d / %d)" % [slot_type, _snapped_parts.size(), REQUIRED_PARTS.size()])
	try_complete()

func _check_completion() -> bool:
	for part in REQUIRED_PARTS:
		if part not in _snapped_parts:
			return false
	return true

func _on_complete() -> void:
	print("PC assembly complete!")
