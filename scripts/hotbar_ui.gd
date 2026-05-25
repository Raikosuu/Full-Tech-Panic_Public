# hotbar_ui.gd
# Draggable hotbar — drag a slot icon into the game world to place a part.
extends CanvasLayer

# ── Per-minigame configuration (Inspector) ─────────────────────────────────
@export var part_scenes: Array[PackedScene] = []
@export var part_labels: Array[String]      = []
@export var part_types:  Array[String]      = []
@export var part_counts: Array[int]         = []

# ── Colour palette ─────────────────────────────────────────────────────────
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

# ── Internal state ─────────────────────────────────────────────────────────
var _minigame:      Node                 = null
var _slot_panels:   Array[PanelContainer] = []
var _counters:      Array[Label]         = []
var _live:          Array[Array]         = []

# Drag state
var _drag_slot:     int     = -1
var _drag_ghost:    Control = null
var _drag_instance: Node    = null

@onready var _slot_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/Slots

# ── Lifecycle ──────────────────────────────────────────────────────────────
func _ready() -> void:
	_minigame = get_parent()
	_validate_exports()
	_build_slots()

func _validate_exports() -> void:
	var n := part_scenes.size()
	while part_labels.size() < n: part_labels.append("Part %d" % part_labels.size())
	while part_types.size()  < n: part_types.append("")
	while part_counts.size() < n: part_counts.append(1)

# ── Build slots ────────────────────────────────────────────────────────────
func _build_slots() -> void:
	for child in _slot_container.get_children():
		child.queue_free()
	_slot_panels.clear()
	_counters.clear()
	_live.clear()

	for i in part_scenes.size():
		_live.append([])

		var ptype:    String = part_types[i]
		var base_col: Color  = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))

		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(58, 42)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP

		var slot_bg := StyleBoxFlat.new()
		slot_bg.bg_color     = base_col * 0.25
		slot_bg.border_color = base_col * 0.9
		slot_bg.set_border_width_all(1)
		slot_bg.set_corner_radius_all(6)
		slot_bg.set_content_margin_all(4)
		slot.add_theme_stylebox_override("panel", slot_bg)
		_slot_container.add_child(slot)
		_slot_panels.append(slot)

		var vbox := VBoxContainer.new()
		vbox.alignment    = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(vbox)

		var lbl := Label.new()
		lbl.text                 = part_labels[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size  = Vector2(54, 22)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_font_size_override("font_size", 8)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(lbl)

		var counter := Label.new()
		counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		counter.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		counter.add_theme_font_size_override("font_size", 8)
		counter.add_theme_color_override("font_color", base_col.lightened(0.3))
		vbox.add_child(counter)
		_counters.append(counter)

		slot.gui_input.connect(_on_slot_gui_input.bind(i))

	_refresh_all()

# ── Drag handling ──────────────────────────────────────────────────────────
func _on_slot_gui_input(event: InputEvent, i: int) -> void:
	if _drag_slot != -1:
		return
	var remaining: int = part_counts[i] - _live[i].size()
	if remaining <= 0:
		return

	var started := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		started = true
	elif event is InputEventScreenTouch and event.pressed:
		started = true
	if not started:
		return

	var packed: PackedScene = part_scenes[i]
	if not packed:
		push_error("HotbarUI: part_scenes[%d] is null" % i)
		return

	_drag_slot     = i
	_drag_instance = packed.instantiate()
	_minigame.add_child(_drag_instance)
	_drag_instance.global_position = Vector2(-99999, -99999)

	# Ghost: a Control holding a TextureRect with the part's sprite
	_drag_ghost = _build_ghost(_drag_instance)
	_drag_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_ghost.z_index = 200
	add_child(_drag_ghost)
	_reposition_ghost(get_viewport().get_mouse_position())

	_live[i].append(_drag_instance)
	_drag_instance.tree_exiting.connect(_on_instance_exiting.bind(i, _drag_instance))
	_refresh_slot(i)

func _input(event: InputEvent) -> void:
	if _drag_slot == -1:
		return

	if event is InputEventMouseMotion:
		_reposition_ghost(event.position)
	elif event is InputEventScreenDrag:
		_reposition_ghost(event.position)

	var released := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		released = true
	elif event is InputEventScreenTouch and not event.pressed:
		released = true
	if released:
		_drop_part()

func _drop_part() -> void:
	if _drag_ghost:
		_drag_ghost.queue_free()
		_drag_ghost = null

	if _drag_instance == null:
		_drag_slot = -1
		return

	var screen_pos: Vector2 = get_viewport().get_mouse_position()
	var panel: Control      = $Panel
	var panel_rect          := Rect2(panel.global_position, panel.size)

	if not panel_rect.has_point(screen_pos):
		# Convert screen position → world position using the scene's camera
		var world_pos: Vector2 = _screen_to_world(screen_pos)
		if _drag_instance.has_method("grab_from_hotbar"):
			_drag_instance.grab_from_hotbar(world_pos)
	else:
		# Dropped back on hotbar — cancel
		_live[_drag_slot].erase(_drag_instance)
		_drag_instance.queue_free()
		_refresh_slot(_drag_slot)

	_drag_instance = null
	_drag_slot     = -1

# ── Ghost builder ──────────────────────────────────────────────────────────
# Finds the first Sprite2D on the spawned instance and creates a TextureRect
# ghost that looks like the real part, scaled to a readable hotbar size.
func _build_ghost(instance: Node) -> Control:
	var container := Control.new()

	var sprite: Sprite2D = _find_sprite(instance)
	if sprite == null or sprite.texture == null:
		# Fallback: plain label
		var lbl := Label.new()
		lbl.text = part_labels[_drag_slot]
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		container.add_child(lbl)
		container.custom_minimum_size = lbl.size
		return container

	var tex_rect := TextureRect.new()
	tex_rect.texture        = sprite.texture
	tex_rect.expand_mode    = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_rect.stretch_mode   = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.flip_h         = sprite.flip_h
	tex_rect.flip_v         = sprite.flip_v

	# Scale the ghost to roughly 48×48 screen pixels so it's visible but not huge
	var tex_size: Vector2   = sprite.texture.get_size()
	var ghost_size: float   = 48.0
	var scale_factor: float = ghost_size / maxf(tex_size.x, tex_size.y)
	# Also factor in the sprite's own scale (e.g. scale = Vector2(0.3, 0.3))
	scale_factor *= maxf(abs(sprite.scale.x), abs(sprite.scale.y))
	scale_factor  = clampf(scale_factor, 0.5, 4.0)

	var display_size := tex_size * scale_factor
	tex_rect.custom_minimum_size = display_size
	tex_rect.size                = display_size
	container.custom_minimum_size = display_size
	container.add_child(tex_rect)
	return container

func _reposition_ghost(screen_pos: Vector2) -> void:
	if _drag_ghost == null:
		return
	# Centre the ghost on the cursor
	var half := _drag_ghost.custom_minimum_size * 0.5
	_drag_ghost.global_position = screen_pos - half

# ── World-space conversion ─────────────────────────────────────────────────
# Uses the minigame's Camera2D to correctly map screen → world,
# accounting for zoom and camera position.
func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var cam: Camera2D = _find_camera()
	if cam == null:
		return screen_pos
	var viewport_size := Vector2(get_viewport().get_visible_rect().size)
	var offset        := screen_pos - viewport_size * 0.5
	return cam.global_position + offset / cam.zoom

# ── Instance lifecycle ─────────────────────────────────────────────────────
func _on_instance_exiting(i: int, instance: Node) -> void:
	_live[i].erase(instance)
	_refresh_slot(i)

# ── UI refresh ─────────────────────────────────────────────────────────────
func _refresh_all() -> void:
	for i in part_scenes.size():
		_refresh_slot(i)

func _refresh_slot(i: int) -> void:
	var total:     int = part_counts[i]
	var remaining: int = total - _live[i].size()
	_counters[i].text = "%d / %d" % [remaining, total]

	var ptype:    String = part_types[i]
	var base_col: Color  = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))
	var sc := _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
	if sc:
		sc.bg_color     = (base_col * 0.25) if remaining > 0 else Color(0.10, 0.10, 0.10, 0.85)
		sc.border_color = (base_col * 0.9)  if remaining > 0 else Color(0.25, 0.25, 0.25)

# ── Helpers ────────────────────────────────────────────────────────────────
func _find_camera() -> Camera2D:
	for child in _minigame.get_children():
		if child is Camera2D:
			return child
	# Also check children of player node etc.
	return _find_camera_recursive(_minigame)

func _find_camera_recursive(node: Node) -> Camera2D:
	for child in node.get_children():
		if child is Camera2D:
			return child
		var found := _find_camera_recursive(child)
		if found:
			return found
	return null

func _find_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
