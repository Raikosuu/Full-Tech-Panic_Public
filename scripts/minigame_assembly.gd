extends BaseMinigame

const REQUIRED_PARTS: Array[String] = ["PANEL", "BATTERY", "MOBO", "CPU", "RAM", "HDD"]
const REQUIRED_SCREWS: int = 4
const PANEL_PREREQUISITES: Array[String] = ["MOBO", "CPU", "RAM", "HDD", "BATTERY", "CFAN"]

var _snapped_parts: Array[String] = []
var _snapped_screws: int = 0
var _hotbar: Node = null

func _on_minigame_ready() -> void:
	_hotbar = get_node_or_null("HotbarUI")  
	if _hotbar:
		_hotbar.set_slot_locked("PANEL", true)  # locked at start
	
	# Connect to any snap zones already in the scene.
	_connect_snap_zones(self)
	# Re-scan whenever the hotbar adds a new node (e.g. MoBo with its own snap zones).
	child_entered_tree.connect(_on_child_entered_tree)

func _on_child_entered_tree(node: Node) -> void:
	# A new node was added — defer so its full subtree is ready first,
	# then connect any snap zones it contains.
	call_deferred("_connect_snap_zones", node)

func _connect_snap_zones(node: Node) -> void:
	for child in node.get_children():
		if child.has_signal("part_snapped"):
			if not child.part_snapped.is_connected(_on_part_snapped):
				child.part_snapped.connect(_on_part_snapped)
		_connect_snap_zones(child)

func _on_part_snapped(slot_type: String) -> void:
	if slot_type == "SCREW":
		_snapped_screws += 1
		print("Screw snapped: %d / %d" % [_snapped_screws, REQUIRED_SCREWS])
	else:
		if slot_type not in _snapped_parts:
			_snapped_parts.append(slot_type)
			print("Snapped: %s  (%d / %d)" % [slot_type, _snapped_parts.size(), REQUIRED_PARTS.size()])
	
	if _hotbar:
		var prereqs_met := PANEL_PREREQUISITES.all(func(p): return p in _snapped_parts)
		_hotbar.set_slot_locked("PANEL", not prereqs_met)

	try_complete()

func _check_completion() -> bool:
	if _snapped_screws < REQUIRED_SCREWS:
		return false
	for part in REQUIRED_PARTS:
		if part not in _snapped_parts:
			return false
	return true

func _on_complete() -> void:
	print("PC assembly complete!")
