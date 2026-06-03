# disassembly_hotbar.gd
# A "collection bar" for disassembly — slots start empty and fill
# as parts are removed from the PC. Read-only; no dragging out.
extends CanvasLayer

@export var part_types:  Array[String] = []
@export var part_labels: Array[String] = []
@export var part_scenes: Array[PackedScene] = []

const SLOT_HEIGHT : int = 36
const ICON_HEIGHT : int = 26
const BADGE_SIZE  : int = 11

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

var _slot_panels:  Array[PanelContainer] = []
var _check_labels: Array[Label]          = []
var _collected:    Array[bool]           = []
var _screw_total:  int = 0
var _screw_count:  int = 0

@onready var _slot_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/Slots

func _ready() -> void:
	_validate_exports()
	_build_slots()

func _validate_exports() -> void:
	var n := part_types.size()
	while part_labels.size() < n: part_labels.append(part_types[part_labels.size()])
	while part_scenes.size() < n: part_scenes.append(null)

func _build_slots() -> void:
	for child in _slot_container.get_children():
		child.queue_free()
	_slot_panels.clear()
	_check_labels.clear()
	_collected.clear()

	for i in part_types.size():
		_collected.append(false)
		var ptype   := part_types[i]
		var acc_col = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))

		var icon_size := _icon_display_size(i, ptype == "RAM")
		var slot_w    := int(icon_size.x) + 8

		# ── Slot panel ──────────────────────────────────────────────────────
		var slot := PanelContainer.new()
		slot.custom_minimum_size   = Vector2(slot_w, SLOT_HEIGHT)
		slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		slot.mouse_filter          = Control.MOUSE_FILTER_IGNORE
		slot.tooltip_text          = part_labels[i]

		var slot_bg := StyleBoxFlat.new()
		slot_bg.bg_color     = Color(0.08, 0.08, 0.14, 1.0)
		slot_bg.border_color = acc_col * 0.4        # dim — not yet collected
		slot_bg.set_border_width_all(1)
		slot_bg.set_corner_radius_all(4)
		slot_bg.set_content_margin_all(2)
		slot.add_theme_stylebox_override("panel", slot_bg)
		_slot_container.add_child(slot)
		_slot_panels.append(slot)

		# ── Icon ────────────────────────────────────────────────────────────
		var center := CenterContainer.new()
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		center.mouse_filter          = Control.MOUSE_FILTER_IGNORE
		slot.add_child(center)

		var icon := TextureRect.new()
		icon.name                = "Icon"
		icon.expand_mode         = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = icon_size
		icon.mouse_filter        = Control.MOUSE_FILTER_IGNORE
		icon.modulate.a          = 0.25             # greyed — not collected
		center.add_child(icon)
		_set_icon_texture(icon, i)

		# ── Checkmark badge ─────────────────────────────────────────────────
		var overlay := Control.new()
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot.add_child(overlay)

		var check := Label.new()
		check.mouse_filter         = Control.MOUSE_FILTER_IGNORE
		check.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		check.grow_horizontal      = Control.GROW_DIRECTION_BEGIN
		check.grow_vertical        = Control.GROW_DIRECTION_BEGIN
		check.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		check.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
		check.add_theme_font_size_override("font_size", BADGE_SIZE)
		check.add_theme_color_override("font_color", acc_col.lightened(0.3))
		check.text                 = ""             # filled on collect
		overlay.add_child(check)
		_check_labels.append(check)

# ── Called by the minigame when a part is removed ─────────────────────────
func collect(part_type: String) -> void:
	if part_type == "SCREW":
		_screw_count += 1
		_refresh_screw_badge()
		return
	for i in part_types.size():
		if part_types[i] == part_type and not _collected[i]:
			_collected[i] = true
			_refresh_slot(i)
			return

func set_screw_total(total: int) -> void:
	_screw_total = total
	_refresh_screw_badge()

# ── Internal refresh ──────────────────────────────────────────────────────
func _refresh_slot(i: int) -> void:
	var ptype   := part_types[i]
	var acc_col = TYPE_COLORS.get(ptype, Color(0.35, 0.35, 0.35))
	var done    := _collected[i]

	var sc := _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
	if sc:
		sc.bg_color     = Color(0.05, 0.12, 0.07, 1.0) if done else Color(0.08, 0.08, 0.14, 1.0)
		sc.border_color = acc_col * (1.0 if done else 0.4)

	var icon := _slot_panels[i].get_node_or_null("CenterContainer/Icon") as TextureRect
	if icon:
		icon.modulate.a = 1.0 if done else 0.25

	_check_labels[i].text = "✓" if done else ""

func _refresh_screw_badge() -> void:
	# Find the SCREW slot index
	for i in part_types.size():
		if part_types[i] == "SCREW":
			var done := (_screw_count >= _screw_total and _screw_total > 0)
			var sc   := _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
			var acc  = TYPE_COLORS.get("SCREW", Color(0.75, 0.75, 0.75))
			if sc:
				sc.bg_color     = Color(0.05, 0.12, 0.07, 1.0) if done else Color(0.08, 0.08, 0.14, 1.0)
				sc.border_color = acc * (1.0 if done else 0.4)
			var icon := _slot_panels[i].get_node_or_null("CenterContainer/Icon") as TextureRect
			if icon:
				icon.modulate.a = 1.0 if done else 0.25
			_check_labels[i].text = "%d/%d" % [_screw_count, _screw_total]
			return

# ── Icon helpers (mirrors hotbar_ui.gd logic) ─────────────────────────────
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

func _set_icon_texture(icon: TextureRect, i: int) -> void:
	var packed: PackedScene = part_scenes[i]
	if not packed:
		return
	var tmp    := packed.instantiate()
	var sprite := _find_sprite(tmp)
	if sprite and sprite.texture:
		icon.texture  = sprite.texture
		icon.flip_h   = sprite.flip_h
		icon.modulate = Color(1, 1, 1, icon.modulate.a)
	tmp.free()

func _find_sprite(node: Node) -> Sprite2D:
	for child in node.get_children():
		if child is Sprite2D:
			return child
	return null
