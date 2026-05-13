extends Sprite2D

# Map each combination of installed parts → a texture path.
# Key is a sorted, comma-joined string of installed part types.
# "" = bare board, "BATTERY" = battery only, "BATTERY,CPU" = both, etc.
const TEXTURE_MAP: Dictionary = {
	"":                   "res://assets/Computer parts/Motherboard states/Motherboard.png",
	#"BATTERY":            "res://assets/Computer parts/Motherboard states/MB_Battery.png",
	"CPU":                "res://assets/Computer parts/Motherboard states/MB-CPU_ins.png",
	"RAM":                "res://assets/Computer parts/Motherboard states/MB-RAM_ins.png",
	#"BATTERY,CPU":        "res://assets/Computer parts/Motherboard states/MB_Battery_CPU.png",
	#"BATTERY,RAM":        "res://assets/Computer parts/Motherboard states/MB_Battery_RAM.png",
	"CPU,RAM":            "res://assets/Computer parts/Motherboard states/MB-CPU-RAM_ins.png",
	#"BATTERY,CPU,RAM":    "res://assets/Computer parts/Motherboard states/MB_Full.png",
}

var installed: Array[String] = []

func _ready() -> void:
	# Connect every snap zone that belongs to this motherboard.
	# Adjust these paths to match your scene tree.
	for snap_zone in get_parent().find_children("*", "Area2D", true, false):
		if snap_zone.has_signal("part_snapped"):
			snap_zone.part_snapped.connect(_on_part_snapped)

# Parts that actually change the motherboard sprite
const VISUAL_PARTS: Array = ["CPU", "RAM"]

func _on_part_snapped(slot_type: String) -> void:
	if slot_type not in installed:
		installed.append(slot_type)
	_update_texture()

func _update_texture() -> void:
	var visual_installed := installed.filter(func(p): return p in VISUAL_PARTS)
	visual_installed.sort()
	var key = ",".join(visual_installed)

	if key in TEXTURE_MAP:
		texture = load(TEXTURE_MAP[key])
	else:
		push_warning("mobo_state: no texture for combination: " + key)
