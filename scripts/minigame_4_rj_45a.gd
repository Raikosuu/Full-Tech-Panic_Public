# res://scripts/minigame4_rj45a.gd
class_name Minigame4RJ45A
extends BaseMinigame

const CORRECT_ORDER: Array[String] = [
	"white_green", "green", "white_orange", "blue",
	"white_blue", "orange", "white_brown", "brown",
]

const WIRE_COLORS: Dictionary = {
	"white_orange": {"label": "W/Orange", "color": Color(1.0, 0.65, 0.3,  1.0), "stripe": true},
	"orange":       {"label": "Orange",   "color": Color(1.0, 0.50, 0.0,  1.0), "stripe": false},
	"white_green":  {"label": "W/Green",  "color": Color(0.2, 0.75, 0.3,  1.0), "stripe": true},
	"blue":         {"label": "Blue",     "color": Color(0.1, 0.3,  0.9,  1.0), "stripe": false},
	"white_blue":   {"label": "W/Blue",   "color": Color(0.35, 0.55, 1.0, 1.0), "stripe": true},
	"green":        {"label": "Green",    "color": Color(0.1, 0.6,  0.15, 1.0), "stripe": false},
	"white_brown":  {"label": "W/Brown",  "color": Color(0.72, 0.45, 0.2, 1.0), "stripe": true},
	"brown":        {"label": "Brown",    "color": Color(0.5,  0.25, 0.05,1.0), "stripe": false},
}

@export var snap_distance: float = 40.0
@export var wrong_crimp_lose_scene: PackedScene

var slots: Array[String] = ["", "", "", "", "", "", "", ""]

var _dragged_wire_id:   String  = ""
var _dragged_node:      Control = null
var _dragged_from_slot: int     = -1
var _drag_offset:       Vector2 = Vector2.ZERO

var _patience_bar = null
var _drag_layer:   Control = null

@onready var _ui_root:    Control       = $UI/Root
@onready var _tray:       HBoxContainer = $UI/Root/MainLayout/ContentRow/WorkArea/Tray/VBox/WireTray
@onready var _slots_root: HBoxContainer = $UI/Root/MainLayout/ContentRow/WorkArea/Crimper/VBox/SlotRow
@onready var _feedback:   Label         = $UI/Root/MainLayout/ContentRow/WorkArea/Crimper/VBox/Feedback
@onready var _crimp_btn:  Button        = $UI/Root/MainLayout/ContentRow/WorkArea/Crimper/VBox/SlotRow/CrimpButton

var _wire_nodes: Dictionary = {}
var _slot_nodes: Array      = []

func _on_minigame_ready() -> void:
	timer_label = NodePath("UI/Root/MainLayout/TopBar/TimerLabel")

	_drag_layer = Control.new()
	_drag_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drag_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_layer.z_index = 50
	$UI.add_child(_drag_layer)

	var bar_scene := load("res://scenes/patience_bar.tscn") as PackedScene
	if bar_scene:
		_patience_bar = bar_scene.instantiate()
		_ui_root.add_child(_patience_bar)
		_patience_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		_patience_bar.offset_left   = -70.0
		_patience_bar.offset_top    = 30.0
		_patience_bar.offset_right  = -8.0
		_patience_bar.offset_bottom = 36.0
		_patience_bar.set_ratio(1.0)

	_build_wire_tray()
	_build_slots()
	_crimp_btn.pressed.connect(_on_crimp_pressed)
	_feedback.text = "Drag wires into slots (pin 1 = left), then CRIMP!"

func _process(delta: float) -> void:
	super._process(delta)
	if _dragged_node:
		# Works for both mouse and touch since touch fires _end_drag directly
		_dragged_node.position = get_viewport().get_mouse_position() + _drag_offset
	if _patience_bar and time_limit > 0.0 and not _completed and not _failed:
		_patience_bar.set_ratio(_time_remaining / time_limit)
		
# ── Wire tray ──────────────────────────────────────────────────────────────────

func _build_wire_tray() -> void:
	for c in _tray.get_children():
		c.queue_free()
	var ids: Array = CORRECT_ORDER.duplicate()
	ids.shuffle()
	for wire_id in ids:
		var w := _make_wire_visual(wire_id, 14, 56)
		w.name = "wire_" + wire_id
		_tray.add_child(w)
		_wire_nodes[wire_id] = w
		w.gui_input.connect(_on_wire_gui_input.bind(wire_id))
		w.mouse_entered.connect(func(): w.modulate = Color(1.3, 1.3, 1.3))
		w.mouse_exited.connect( func(): w.modulate = Color(1.0, 1.0, 1.0))

# ── Slots ──────────────────────────────────────────────────────────────────────

func _build_slots() -> void:
	for c in _slots_root.get_children():
		if c.name != "CrimpButton":
			c.queue_free()
	_slot_nodes.clear()
	for i in range(8):
		var slot := _make_slot_visual(i)
		_slots_root.add_child(slot)
		_slots_root.move_child(slot, i)
		_slot_nodes.append(slot)

func _make_slot_visual(index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "Slot%d" % (index + 1)
	panel.custom_minimum_size = Vector2(20, 48)
	panel.tooltip_text = "Pin %d" % (index + 1)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_slot_style(panel, false)

	var lbl := Label.new()
	lbl.text = str(index + 1)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.add_child(lbl)

	panel.gui_input.connect(_on_slot_gui_input.bind(index))
	return panel

func _apply_slot_style(panel: PanelContainer, filled: bool, wire_id: String = "") -> void:
	var style := StyleBoxFlat.new()
	if filled and wire_id != "":
		style.bg_color     = WIRE_COLORS[wire_id]["color"].darkened(0.5)
		style.border_color = WIRE_COLORS[wire_id]["color"]
		style.set_border_width_all(2)
	else:
		style.bg_color     = Color(0.15, 0.15, 0.18, 1.0)
		style.border_color = Color(0.5,  0.5,  0.6,  1.0)
		style.set_border_width_all(1)
	style.corner_radius_top_left     = 3
	style.corner_radius_top_right    = 3
	style.corner_radius_bottom_left  = 3
	style.corner_radius_bottom_right = 3
	panel.add_theme_stylebox_override("panel", style)

# ── Wire visual ────────────────────────────────────────────────────────────────

func _make_wire_visual(wire_id: String, width: int, height: int) -> Control:
	var info: Dictionary = WIRE_COLORS[wire_id]
	var root := Control.new()
	root.custom_minimum_size = Vector2(width, height)

	var jacket := ColorRect.new()
	jacket.color = Color(0.45, 0.45, 0.45, 1.0)
	jacket.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	jacket.custom_minimum_size = Vector2(width, height)
	jacket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(jacket)

	var conductor := ColorRect.new()
	conductor.color = info["color"]
	conductor.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	conductor.offset_top    = -int(height * 0.70)
	conductor.offset_bottom = 0
	conductor.offset_left   = 3
	conductor.offset_right  = -3
	conductor.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	root.add_child(conductor)

	if info["stripe"]:
		var stripe := ColorRect.new()
		stripe.color = Color(1, 1, 1, 0.55)
		stripe.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		stripe.offset_top    = -int(height * 0.70)
		stripe.offset_bottom = 0
		stripe.offset_left   = 5
		stripe.offset_right  = -9
		stripe.mouse_filter  = Control.MOUSE_FILTER_IGNORE
		root.add_child(stripe)

	var lbl := Label.new()
	lbl.text = info["label"]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	lbl.offset_bottom = 0
	lbl.offset_top    = -14
	lbl.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	root.add_child(lbl)

	root.mouse_filter = Control.MOUSE_FILTER_STOP
	return root

# ── Input handlers ─────────────────────────────────────────────────────────────

func _on_wire_gui_input(event: InputEvent, wire_id: String) -> void:
	if _completed or _failed or _dragged_node:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag(wire_id, get_viewport().get_mouse_position(), -1)
	elif event is InputEventScreenTouch and event.pressed:
		_start_drag(wire_id, event.position, -1)

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if _completed or _failed or _dragged_node:
		return
	var pressed := false
	var pos := Vector2.ZERO
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressed = true
		pos = get_viewport().get_mouse_position()
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
		pos = event.position
	if pressed and slots[slot_index] != "":
		var wire_id := slots[slot_index]
		slots[slot_index] = ""
		_refresh_slot_visual(slot_index)
		_start_drag(wire_id, pos, slot_index)
		
func _input(event: InputEvent) -> void:
	if not _dragged_node:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_end_drag(get_viewport().get_mouse_position())
	elif event is InputEventScreenTouch and not event.pressed:
		_end_drag(event.position)
		
# ── Drag logic ─────────────────────────────────────────────────────────────────

func _start_drag(wire_id: String, screen_pos: Vector2, from_slot: int) -> void:
	if GameState.drag_active:
		return
	GameState.drag_active  = true
	_dragged_wire_id       = wire_id
	_dragged_from_slot     = from_slot
	_drag_offset           = Vector2(-7, -28)

	var visual := _make_wire_visual(wire_id, 14, 56)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.position     = screen_pos + _drag_offset
	_drag_layer.add_child(visual)
	_dragged_node = visual

	if from_slot == -1 and _wire_nodes.has(wire_id):
		_wire_nodes[wire_id].modulate.a = 0.3

func _end_drag(screen_pos: Vector2) -> void:
	if not _dragged_node:
		return

	var dropped := false
	var best_i    := -1
	var best_dist := INF

	for i in range(_slot_nodes.size()):
		var slot_node: Control = _slot_nodes[i]
		var rect: Rect2 = slot_node.get_global_rect()
		var center: Vector2 = rect.get_center()
		var dist: float = screen_pos.distance_to(center)
		if rect.grow(snap_distance * 2.0).has_point(screen_pos):
			if dist < best_dist:
				best_dist = dist
				best_i = i

	if best_i == -1:
		for i in range(_slot_nodes.size()):
			var center: Vector2 = _slot_nodes[i].get_global_rect().get_center()
			var dist: float = screen_pos.distance_to(center)
			if dist < snap_distance * 3.0 and dist < best_dist:
				best_dist = dist
				best_i = i

	if best_i >= 0:
		var i := best_i
		if slots[i] == "" or _dragged_from_slot == i:
			slots[i] = _dragged_wire_id
			_refresh_slot_visual(i)
			if _dragged_from_slot == -1 and _wire_nodes.has(_dragged_wire_id):
				_wire_nodes[_dragged_wire_id].queue_free()
				_wire_nodes.erase(_dragged_wire_id)
			dropped = true
		else:
			var other := slots[i]
			slots[i] = _dragged_wire_id
			_refresh_slot_visual(i)
			if _dragged_from_slot >= 0:
				slots[_dragged_from_slot] = other
				_refresh_slot_visual(_dragged_from_slot)
			else:
				_spawn_tray_wire(other)
			if _dragged_from_slot == -1 and _wire_nodes.has(_dragged_wire_id):
				_wire_nodes[_dragged_wire_id].queue_free()
				_wire_nodes.erase(_dragged_wire_id)
			dropped = true

	if not dropped:
		if _dragged_from_slot >= 0:
			slots[_dragged_from_slot] = _dragged_wire_id
			_refresh_slot_visual(_dragged_from_slot)
		else:
			if _wire_nodes.has(_dragged_wire_id):
				_wire_nodes[_dragged_wire_id].modulate.a = 1.0

	_dragged_node.queue_free()
	_dragged_node      = null
	_dragged_wire_id   = ""
	_dragged_from_slot = -1
	GameState.drag_active = false

func _spawn_tray_wire(wire_id: String) -> void:
	var w := _make_wire_visual(wire_id, 14, 56)
	w.name = "wire_" + wire_id
	_tray.add_child(w)
	_wire_nodes[wire_id] = w
	w.gui_input.connect(_on_wire_gui_input.bind(wire_id))
	w.mouse_entered.connect(func(): w.modulate = Color(1.3, 1.3, 1.3))
	w.mouse_exited.connect( func(): w.modulate = Color(1.0, 1.0, 1.0))

func _refresh_slot_visual(slot_index: int) -> void:
	var panel: PanelContainer = _slot_nodes[slot_index]
	for child in panel.get_children():
		if child.name.begins_with("wire_"):
			child.queue_free()

	var wire_id := slots[slot_index]
	if wire_id != "":
		var vis := _make_wire_visual(wire_id, 14, 48)
		vis.name = "wire_" + wire_id
		vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(vis)
		_apply_slot_style(panel, true, wire_id)
	else:
		_apply_slot_style(panel, false)

# ── Crimp ──────────────────────────────────────────────────────────────────────

func _on_crimp_pressed() -> void:
	if _completed or _failed:
		return
	for i in range(8):
		if slots[i] == "":
			_feedback.text = "Fill all 8 slots first!"
			_feedback.add_theme_color_override("font_color", Color(1.0, 0.8, 0.1))
			return
	if _check_completion():
		_feedback.text = "✓ Perfect T568-A crimp!"
		_feedback.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
		try_complete()
	else:
		_feedback.text = "✗ Wrong order — check the standard!"
		_feedback.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		_fail_wrong_crimp()

func _fail_wrong_crimp() -> void:
	if _failed:
		return
	_failed = true
	if wrong_crimp_lose_scene:
		var screen = wrong_crimp_lose_scene.instantiate()
		$UI.add_child(screen)
	await get_tree().create_timer(2.5).timeout
	GameState.fail_minigame()

func _check_completion() -> bool:
	for i in range(8):
		if slots[i] != CORRECT_ORDER[i]:
			return false
	return true
