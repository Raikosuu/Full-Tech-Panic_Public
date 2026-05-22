# hotbar_ui.gd
# Attach to the HotbarUI CanvasLayer scene.
# Instance hotbar_ui.tscn into any minigame and configure the slots
# via the exported arrays in the Inspector — no code changes needed.
extends CanvasLayer

# ── Per-minigame configuration (set in the Inspector) ─────────────────────
#
# All four arrays must be the same length — one entry per hotbar slot.
#
# part_scenes       : the PackedScene for each draggable part
# part_labels       : display name shown on the button
# part_types        : component_type string (must match drag_cont.gd)
# part_counts       : how many copies the player can spawn (e.g. 4 screws)
#
@export var part_scenes: Array[PackedScene] = []
@export var part_labels: Array[String]      = []
@export var part_types:  Array[String]      = []
@export var part_counts: Array[int]         = []

# Where spawned parts appear (world-space). Leave Vector2.ZERO to
# auto-detect from the parent's Camera2D.
@export var spawn_anchor: Vector2 = Vector2.ZERO

# Random spread applied to spawn_anchor so stacked parts fan out.
@export var spawn_spread: float = 14.0

# ── Colour palette (type → button tint) ───────────────────────────────────
const TYPE_COLORS: Dictionary = {
	"MOBO":    Color(0.40, 0.70, 0.40),
	"CPU":     Color(0.30, 0.55, 0.90),
	"CFAN":    Color(0.55, 0.85, 0.95),
	"RAM":     Color(0.90, 0.70, 0.20),
	"HDD":     Color(0.70, 0.50, 0.30),
	"BATTERY": Color(0.90, 0.40, 0.40),
	"PANEL":   Color(0.60, 0.60, 0.75),
	"SCREW":   Color(0.75, 0.75, 0.75),
	"GPU":     Color(0.80, 0.35, 0.80),
}

# ── Internal ───────────────────────────────────────────────────────────────
var _buttons:  Array[Button] = []
var _counters: Array[Label]  = []
var _live:     Array[Array]  = []   # _live[i] = array of live Node instances
var _minigame: Node          = null

@onready var _slot_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/Slots

# ── Lifecycle ──────────────────────────────────────────────────────────────
func _ready() -> void:
	_minigame = get_parent()
	_validate_exports()
	_build_slots()

func _validate_exports() -> void:
	var n := part_scenes.size()
	# Pad shorter arrays with safe defaults so we never crash.
	while part_labels.size() < n:
		part_labels.append("Part %d" % part_labels.size())
	while part_types.size() < n:
		part_types.append("")
	while part_counts.size() < n:
		part_counts.append(1)

# ── Build UI slots at runtime ──────────────────────────────────────────────
func _build_slots() -> void:
	# Remove placeholder children the scene might have.
	for child in _slot_container.get_children():
		child.queue_free()

	_buttons.clear()
	_counters.clear()
	_live.clear()

	for i in part_scenes.size():
		_live.append([])

		var ptype: String = part_types[i]
		var base_col: Color = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))

		# ── Slot container ─────────────────────────────────────────────────
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(58, 42)

		var slot_bg := StyleBoxFlat.new()
		slot_bg.bg_color          = base_col * 0.25
		slot_bg.border_color      = base_col * 0.9
		slot_bg.set_border_width_all(1)
		slot_bg.set_corner_radius_all(6)
		slot_bg.set_content_margin_all(4)
		slot.add_theme_stylebox_override("panel", slot_bg)
		_slot_container.add_child(slot)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_child(vbox)

		# ── Button ─────────────────────────────────────────────────────────
		var btn := Button.new()
		btn.text = part_labels[i]
		btn.custom_minimum_size = Vector2(54, 24)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 8)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

		var sc_normal := StyleBoxFlat.new()
		sc_normal.bg_color = base_col * 0.65
		sc_normal.set_corner_radius_all(5)
		sc_normal.set_content_margin_all(4)
		btn.add_theme_stylebox_override("normal", sc_normal)

		var sc_hover := sc_normal.duplicate() as StyleBoxFlat
		sc_hover.bg_color = base_col * 0.85
		btn.add_theme_stylebox_override("hover", sc_hover)

		var sc_pressed := sc_normal.duplicate() as StyleBoxFlat
		sc_pressed.bg_color = base_col * 0.45
		btn.add_theme_stylebox_override("pressed", sc_pressed)

		var sc_disabled := sc_normal.duplicate() as StyleBoxFlat
		sc_disabled.bg_color = Color(0.18, 0.18, 0.18, 0.9)
		btn.add_theme_stylebox_override("disabled", sc_disabled)

		btn.pressed.connect(_on_slot_pressed.bind(i))
		vbox.add_child(btn)
		_buttons.append(btn)

		# ── Counter label ──────────────────────────────────────────────────
		var counter := Label.new()
		counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		counter.add_theme_font_size_override("font_size", 8)
		counter.add_theme_color_override("font_color", base_col.lightened(0.3))
		vbox.add_child(counter)
		_counters.append(counter)

	_refresh_all()

# ── Slot logic ─────────────────────────────────────────────────────────────
func _on_slot_pressed(i: int) -> void:
	var remaining: int = part_counts[i] - _live[i].size()
	if remaining <= 0:
		return

	var packed: PackedScene = part_scenes[i]
	if not packed:
		push_error("HotbarUI: part_scenes[%d] is null" % i)
		return

	var instance: Node = packed.instantiate()
	_minigame.add_child(instance)

	# Position near spawn_anchor (or the minigame camera) + random jitter.
	var pos: Vector2 = spawn_anchor if spawn_anchor != Vector2.ZERO else _camera_center()
	var jitter := Vector2(
		randf_range(-spawn_spread, spawn_spread),
		randf_range(-spawn_spread, spawn_spread)
	)
	instance.global_position = pos + jitter

	_live[i].append(instance)
	instance.tree_exiting.connect(_on_instance_exiting.bind(i, instance))

	_refresh_slot(i)

func _on_instance_exiting(i: int, instance: Node) -> void:
	_live[i].erase(instance)
	_refresh_slot(i)

# ── Helpers ────────────────────────────────────────────────────────────────
func _refresh_all() -> void:
	for i in part_scenes.size():
		_refresh_slot(i)

func _refresh_slot(i: int) -> void:
	var total:     int = part_counts[i]
	var remaining: int = total - _live[i].size()

	_counters[i].text = "%d / %d" % [remaining, total]
	_buttons[i].disabled = (remaining <= 0)

func _camera_center() -> Vector2:
	for child in _minigame.get_children():
		if child is Camera2D:
			return child.global_position
	return Vector2(235, 126)
