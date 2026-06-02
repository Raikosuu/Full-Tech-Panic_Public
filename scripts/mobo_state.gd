extends Sprite2D

const TEXTURE_MAP: Dictionary = {
	"":        "res://assets/Computer parts/Motherboard states/Motherboard.png",
	"CPU":     "res://assets/Computer parts/Motherboard states/MB-CPU_ins.png",
	"RAM":     "res://assets/Computer parts/Motherboard states/MB-RAM_ins.png",
	"CPU,RAM": "res://assets/Computer parts/Motherboard states/MB-CPU-RAM_ins.png",
}

# Parts that change the motherboard sprite
const VISUAL_PARTS: Array = ["CPU", "RAM"]

var installed: Array[String] = []

# Set to true in disassembly scenes — starts fully loaded, parts are removed.
@export var disassembly_mode: bool = false

func _ready() -> void:
	for snap_zone in get_parent().find_children("*", "Area2D", true, false):
		if snap_zone.has_signal("part_snapped"):
			snap_zone.part_snapped.connect(_on_part_snapped)
		if snap_zone.has_signal("part_removed"):
			snap_zone.part_removed.connect(_on_part_removed)

	if disassembly_mode:
		# Start with all visual parts installed
		installed = ["CPU", "RAM"]
		_update_texture()

func _on_part_snapped(slot_type: String) -> void:
	if slot_type not in installed:
		installed.append(slot_type)
	_update_texture()

func _on_part_removed(slot_type: String) -> void:
	installed.erase(slot_type)
	_update_texture()

func _update_texture() -> void:
	var visual_installed := installed.filter(func(p): return p in VISUAL_PARTS)
	visual_installed.sort()
	var key := ",".join(visual_installed)
	if key in TEXTURE_MAP:
		texture = load(TEXTURE_MAP[key])
	else:
		push_warning("mobo_state: no texture for combination: " + key)
