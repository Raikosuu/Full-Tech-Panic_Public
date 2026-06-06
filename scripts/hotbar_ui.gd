# hotbar_ui.gd
# Compact icon-only hotbar for mobile landscape / pixel art games.
# Each slot height is fixed; width expands to fit the icon's natural aspect ratio.
extends CanvasLayer

# ── Per-minigame configuration (Inspector) ─────────────────────────────────
@export var part_scenes:  Array[PackedScene] = []
@export var part_labels:  Array[String]      = []
@export var part_types:   Array[String]      = []
@export var part_counts:  Array[int]         = []

# ── Slot dimensions (pixels, screen-space) ─────────────────────────────────
const SLOT_HEIGHT : int = 36   # fixed height for every slot
const ICON_HEIGHT : int = 26   # icon is scaled to this height; width follows aspect ratio
const BADGE_SIZE  : int = 11   # count badge font size (px)

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
var _minigame:      Node                  = null
var _slot_panels:   Array[PanelContainer] = []
var _counters:      Array[Label]          = []
var _live:          Array[Array]          = []
var _locked_slots:  Dictionary            = {}

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

		var ptype:   String = part_types[i]
		var acc_col: Color  = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))

		# ── Work out icon display size ──────────────────────────────────────
		# RAM gets a wider slot to fit its landscape texture; all other parts
		# use a square slot (SLOT_HEIGHT x SLOT_HEIGHT).
		var icon_size := _icon_display_size(i, ptype == "RAM")

		# ── Slot — height fixed, width = icon width + padding ───────────────
		var slot_w: int = int(icon_size.x) + 8   # 4px padding each side
		var slot := PanelContainer.new()
		slot.custom_minimum_size   = Vector2(slot_w, SLOT_HEIGHT)
		slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		slot.mouse_filter          = Control.MOUSE_FILTER_STOP
		slot.tooltip_text          = part_labels[i]

		var slot_bg := StyleBoxFlat.new()
		slot_bg.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
		slot_bg.border_color = acc_col * 0.6
		slot_bg.set_border_width_all(1)
		slot_bg.set_corner_radius_all(4)
		slot_bg.set_content_margin_all(2)
		slot.add_theme_stylebox_override("panel", slot_bg)
		_slot_container.add_child(slot)
		_slot_panels.append(slot)

		# ── Inner: CenterContainer holds the icon so Godot centres it ──────
		var center := CenterContainer.new()
		center.name                 = "Center"
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		center.mouse_filter          = Control.MOUSE_FILTER_IGNORE
		slot.add_child(center)

		# ── Icon — fixed pixel size, centred by CenterContainer ─────────────
		var icon := TextureRect.new()
		icon.name                = "Icon"
		icon.expand_mode         = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = icon_size
		icon.mouse_filter        = Control.MOUSE_FILTER_IGNORE
		center.add_child(icon)

		_set_icon_texture(icon, i)

		# ── Count badge — overlaid at bottom-right via a second Control ──────
		# We use a MarginContainer anchored to the slot itself so it always
		# sits in the corner regardless of icon size.
		var overlay := Control.new()
		overlay.name            = "Overlay"
		overlay.mouse_filter    = Control.MOUSE_FILTER_IGNORE
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot.add_child(overlay)

		var badge := Label.new()
		badge.name                 = "Badge"
		badge.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		badge.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		badge.grow_horizontal      = Control.GROW_DIRECTION_BEGIN
		badge.grow_vertical        = Control.GROW_DIRECTION_BEGIN
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
		badge.add_theme_font_size_override("font_size", BADGE_SIZE)
		badge.add_theme_color_override("font_color", acc_col.lightened(0.25))
		overlay.add_child(badge)
		_counters.append(badge)

		slot.gui_input.connect(_on_slot_gui_input.bind(i))

	_refresh_all()

# ── Compute icon display size for slot i ───────────────────────────────────
# RAM gets width derived from its texture aspect ratio.
# All other parts get a square ICON_HEIGHT x ICON_HEIGHT slot.
func _icon_display_size(i: int, use_aspect: bool = false) -> Vector2:
	if not use_aspect:
		return Vector2(ICON_HEIGHT, ICON_HEIGHT)
	var packed: PackedScene = part_scenes[i]
	if not packed:
		return Vector2(ICON_HEIGHT, ICON_HEIGHT)
	var tmp    := packed.instantiate()
	var sprite := _find_sprite(tmp)
	var result := Vector2(ICON_HEIGHT, ICON_HEIGHT)
	if sprite and sprite.texture:
		var tex := sprite.texture.get_size()
		var w   := roundf(float(ICON_HEIGHT) * tex.x / maxf(tex.y, 1.0))
		result   = Vector2(w, ICON_HEIGHT)
	tmp.free()
	return result

# ── Set icon texture (texture already sized by _icon_display_size) ─────────
func _set_icon_texture(icon: TextureRect, i: int) -> void:
	var packed: PackedScene = part_scenes[i]
	if not packed:
		return
	var tmp    := packed.instantiate()
	var sprite := _find_sprite(tmp)
	if sprite and sprite.texture:
		icon.texture  = sprite.texture
		icon.flip_h   = sprite.flip_h
		icon.flip_v   = sprite.flip_v
		icon.modulate = Color(1, 1, 1, 1)
	tmp.free()

# ── Drag handling ──────────────────────────────────────────────────────────
# hotbar_ui.gd — replace these functions

func _on_slot_gui_input(event: InputEvent, i: int) -> void:
	if _drag_slot != -1:
		return
	if _locked_slots.get(i, false):
		return
	
	# Count only instances that are NOT yet snapped (still "live" / unplaced)
	var placed_count: int = _count_placed(i)
	var remaining: int = part_counts[i] - placed_count
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

	_drag_ghost = _build_ghost(_drag_instance)
	_drag_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_ghost.z_index      = 200
	add_child(_drag_ghost)
	_reposition_ghost(get_viewport().get_mouse_position())

	_live[i].append(_drag_instance)
	# Use tree_exiting to catch both free() and reparenting out of tree
	_drag_instance.tree_exiting.connect(_on_instance_exiting.bind(i, _drag_instance))
	_refresh_slot(i)

# NEW: count how many instances exist (placed or in-flight) for slot i
func _count_placed(i: int) -> int:
	# Clean up any nulls (freed nodes) first
	_live[i] = _live[i].filter(func(n): return is_instance_valid(n))
	return _live[i].size()

func _on_instance_exiting(i: int, instance: Node) -> void:
	# Only remove from live if it's actually being freed, not just reparented
	# We check on next frame so the tree operation completes first
	call_deferred("_deferred_remove_live", i, instance)

func _deferred_remove_live(i: int, instance: Node) -> void:
	if not is_instance_valid(instance):
		_live[i].erase(instance)
	_refresh_slot(i)

func _refresh_slot(i: int) -> void:
	# Clean nulls before reading size
	_live[i] = _live[i].filter(func(n): return is_instance_valid(n))
	
	var total:     int = part_counts[i]
	var remaining: int = total - _live[i].size()

	var badge: Label = _counters[i]
	if total == 1:
		badge.text = "" if remaining > 0 else "✕"
	else:
		badge.text = str(remaining)

	var ptype:   String = part_types[i]
	var acc_col: Color  = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))
	var sc := _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
	if sc:
		if remaining > 0:
			sc.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
			sc.border_color = acc_col * 0.6
		else:
			sc.bg_color     = Color(0.05, 0.05, 0.08, 1.0)
			sc.border_color = Color(0.18, 0.18, 0.22, 1.0)

	var icon := _slot_panels[i].get_node_or_null("Center/Icon") as TextureRect
	if icon:
		var is_locked: bool = _locked_slots.get(i, false)
		icon.modulate.a = 1.0 if (remaining > 0 and not is_locked) else 0.3
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

# hotbar_ui.gd
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
		var world_pos: Vector2 = _screen_to_world(screen_pos)
		if _drag_instance.has_method("grab_from_hotbar"):
			# Defer so the current mouse-release event finishes propagating
			# before the new grab starts — prevents immediate self-release
			_drag_instance.call_deferred("grab_from_hotbar", world_pos)
	else:
		_live[_drag_slot].erase(_drag_instance)
		_drag_instance.queue_free()
		_refresh_slot(_drag_slot)

	_drag_instance = null
	_drag_slot     = -1

# ── Ghost (drag preview) ───────────────────────────────────────────────────
func _build_ghost(instance: Node) -> Control:
	var container := Control.new()

	var sprite: Sprite2D = _find_sprite(instance)
	if sprite == null or sprite.texture == null:
		var lbl := Label.new()
		lbl.text = part_labels[_drag_slot]
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		container.add_child(lbl)
		container.custom_minimum_size = lbl.size
		return container

	var tex_rect := TextureRect.new()
	tex_rect.texture      = sprite.texture
	tex_rect.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.flip_h       = sprite.flip_h
	tex_rect.flip_v       = sprite.flip_v

	var tex_size: Vector2 = sprite.texture.get_size()
	var scale_f: float    = float(SLOT_HEIGHT) / maxf(tex_size.x, tex_size.y)
	scale_f               = clampf(scale_f, 0.5, 4.0)
	var display_size      := tex_size * scale_f
	tex_rect.custom_minimum_size  = display_size
	tex_rect.size                 = display_size
	container.custom_minimum_size = display_size
	container.add_child(tex_rect)
	return container

func _reposition_ghost(screen_pos: Vector2) -> void:
	if _drag_ghost == null:
		return
	var half := _drag_ghost.custom_minimum_size * 0.5
	_drag_ghost.global_position = screen_pos - half

# ── World-space conversion ─────────────────────────────────────────────────
func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var cam: Camera2D = _find_camera()
	if cam == null:
		return screen_pos
	var viewport_size := Vector2(get_viewport().get_visible_rect().size)
	var offset        := screen_pos - viewport_size * 0.5
	return cam.global_position + offset / cam.zoom



# ── UI refresh ─────────────────────────────────────────────────────────────
func _refresh_all() -> void:
	for i in part_scenes.size():
		_refresh_slot(i)

# ── Helpers ────────────────────────────────────────────────────────────────
func _find_camera() -> Camera2D:
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
	
func set_slot_locked(part_type: String, locked: bool) -> void:
	for i in part_types.size():
		if part_types[i] == part_type:
			_locked_slots[i] = locked
			_refresh_slot(i)
			return
