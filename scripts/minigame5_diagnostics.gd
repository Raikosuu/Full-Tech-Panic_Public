extends BaseMinigame

# ── Scenario data ──────────────────────────────────────────────────────────────
const SCENARIOS: Array[Dictionary] = [
	{
		"symptom":      "The computer is running very slowly.",
		"tool":         "Task Manager",
		"tool_icon":    "📊",
		"scan_results": [
			"CPU usage: 98% (abnormal)",
			"RAM usage: 45% (normal)",
			"Background processes: 47 running",
		],
		"options": [
			"End high-CPU background processes",
			"Reinstall Windows",
			"Replace the RAM",
		],
		"correct_fix": 0,
		"win_message": "Fixed! Ended runaway processes. CPU back to normal.",
	},
	{
		"symptom":      "A device is not being recognized.",
		"tool":         "Device Manager",
		"tool_icon":    "🖥",
		"scan_results": [
			"⚠ Unknown Device (error code 43)",
			"Network Adapter: OK",
			"Display Adapter: OK",
		],
		"options": [
			"Update driver for Unknown Device",
			"Disable the Network Adapter",
			"Roll back Display Adapter driver",
		],
		"correct_fix": 0,
		"win_message": "Fixed! Driver updated. Device recognized.",
	},
	{
		"symptom":      "Windows keeps showing disk errors on startup.",
		"tool":         "Check Disk (chkdsk)",
		"tool_icon":    "💾",
		"scan_results": [
			"File system errors detected: 3",
			"Bad sectors found: 0",
			"Free space: 45 GB",
		],
		"options": [
			"Run chkdsk /f to fix file system errors",
			"Format the drive immediately",
			"Ignore errors, they are harmless",
		],
		"correct_fix": 0,
		"win_message": "Fixed! File system errors repaired by chkdsk.",
	},
	{
		"symptom":      "Antivirus detected suspicious activity.",
		"tool":         "Windows Security",
		"tool_icon":    "🛡",
		"scan_results": [
			"Threat found: Trojan.GenericKD (HIGH)",
			"Last scan: 14 days ago",
			"Real-time protection: OFF",
		],
		"options": [
			"Quarantine the threat and re-enable protection",
			"Ignore the threat",
			"Uninstall Windows Security",
		],
		"correct_fix": 0,
		"win_message": "Fixed! Threat quarantined. Protection re-enabled.",
	},
	{
		"symptom":      "The screen flickers and display looks corrupted.",
		"tool":         "Device Manager",
		"tool_icon":    "🖥",
		"scan_results": [
			"Display Adapter: Driver version outdated",
			"Monitor: OK",
			"⚠ Display Adapter: Code 10 - Device failed to start",
		],
		"options": [
			"Update or reinstall the Display Adapter driver",
			"Replace the monitor cable",
			"Increase virtual memory",
		],
		"correct_fix": 0,
		"win_message": "Fixed! Display driver reinstalled. No more flickering.",
	},
	{
		"symptom":      "The computer crashes with a blue screen (BSOD).",
		"tool":         "Event Viewer",
		"tool_icon":    "📋",
		"scan_results": [
			"Critical error logged: KERNEL_SECURITY_CHECK_FAILURE",
			"Source: ntoskrnl.exe",
			"Last crash: 2 hours ago",
		],
		"options": [
			"Check for faulty drivers using the crash log",
			"Delete system32 folder",
			"Increase screen brightness",
		],
		"correct_fix": 0,
		"win_message": "Fixed! Faulty driver identified and removed via crash log.",
	},
]

const ALL_TOOLS: Array[Dictionary] = [
	{"name": "Task Manager",        "icon": "📊"},
	{"name": "Device Manager",      "icon": "🖥"},
	{"name": "Check Disk (chkdsk)", "icon": "💾"},
	{"name": "Windows Security",    "icon": "🛡"},
	{"name": "Event Viewer",        "icon": "📋"},
	{"name": "Disk Cleanup",        "icon": "🗑"},
	{"name": "System Restore",      "icon": "🔄"},
	{"name": "Control Panel",       "icon": "⚙"},
	{"name": "Registry Editor",     "icon": "📝"},
]

# ── Node references ────────────────────────────────────────────────────────────
var _symptom_label:   Label
var _start_button:    Button
var _start_menu:      Panel
var _app_grid:        GridContainer
var _diag_window:     Panel
var _window_title:    Label
var _status_label:    Label
var _scan_progress:   ProgressBar
var _results_list:    VBoxContainer
var _scan_button:     Button
var _fix_button:      Button
var _close_btn:       Button
var _title_bar:       Panel
var _toast:           Panel
var _toast_label:     Label
var _clock_label:     Label
var _desktop_icons:   GridContainer

# ── State ──────────────────────────────────────────────────────────────────────
var _scenario:         Dictionary  = {}
var _phase:            String      = "start"
var _dragging:         bool        = false
var _drag_offset:      Vector2     = Vector2.ZERO
var _fix_options:      Array       = []
var _correct_fix_text: String      = ""
var _button_group:     ButtonGroup = null

# No SubViewport — all nodes live directly under Desktop in ScreenUI
const _VP := "ScreenUI/MonitorFrame/Desktop"

# ── Fonts ──────────────────────────────────────────────────────────────────────
const _FONT_BOLD    := preload("res://assets/fonts/Pixelify_Sans/static/PixelifySans-Bold.ttf")
const _FONT_REGULAR := preload("res://assets/fonts/Pixelify_Sans/static/PixelifySans-Regular.ttf")

func _apply_font(node: Control, bold: bool = false, size: int = 10) -> void:
	node.add_theme_font_override("font", _FONT_BOLD if bold else _FONT_REGULAR)
	node.add_theme_font_size_override("font_size", size)

func _on_minigame_ready() -> void:
	_symptom_label  = get_node(_VP + "/SymptomBanner/SymptomLabel")
	_start_button   = get_node(_VP + "/Taskbar/CenterBox/StartButton")
	_start_menu     = get_node(_VP + "/StartMenu")
	_app_grid       = get_node(_VP + "/StartMenu/StartMenuLayout/AppGrid")
	_diag_window    = get_node(_VP + "/DiagnosticWindow")
	_window_title   = get_node(_VP + "/DiagnosticWindow/TitleBar/WindowTitle")
	_status_label   = get_node(_VP + "/DiagnosticWindow/WindowBody/StatusLabel")
	_scan_progress  = get_node(_VP + "/DiagnosticWindow/WindowBody/ScanProgress")
	_results_list   = get_node(_VP + "/DiagnosticWindow/WindowBody/ResultsScroll/ResultsList")
	_scan_button    = get_node(_VP + "/DiagnosticWindow/WindowBody/ActionButtons/ScanButton")
	_fix_button     = get_node(_VP + "/DiagnosticWindow/WindowBody/ActionButtons/FixButton")
	_close_btn      = get_node(_VP + "/DiagnosticWindow/TitleBar/WinButtons/CloseBtn")
	_title_bar      = get_node(_VP + "/DiagnosticWindow/TitleBar")
	_toast          = get_node(_VP + "/NotificationToast")
	_toast_label    = get_node(_VP + "/NotificationToast/ToastLabel")
	_clock_label    = get_node(_VP + "/Taskbar/ClockLabel")
	_desktop_icons  = get_node(_VP + "/DesktopIcons")

	_start_menu.visible  = false
	_diag_window.visible = false
	_toast.visible       = false

	_scenario = SCENARIOS[randi() % SCENARIOS.size()]
	_symptom_label.text = "⚠  Customer says: \"%s\"  — Open the correct tool from the Start Menu." % _scenario["symptom"]
	_clock_label.text = "10:24 AM\n6/13/2026"

	_build_start_menu()

	_start_button.pressed.connect(_toggle_start_menu)
	_scan_button.pressed.connect(_on_scan_pressed)
	_fix_button.pressed.connect(_on_fix_pressed)
	_close_btn.pressed.connect(_on_close_window)
	_title_bar.gui_input.connect(_on_titlebar_input)

func _build_start_menu() -> void:
	for child in _app_grid.get_children():
		child.queue_free()

	var tools := ALL_TOOLS.duplicate(true)
	tools.shuffle()
	var display_count := mini(tools.size(), 9)

	var correct_in_list := false
	for i in display_count:
		if tools[i]["name"] == _scenario["tool"]:
			correct_in_list = true
			break
	if not correct_in_list:
		tools[display_count - 1] = {"name": _scenario["tool"], "icon": _scenario["tool_icon"]}

	for i in display_count:
		var tool_data: Dictionary = tools[i]
		var btn := Button.new()
		btn.text = "%s\n%s" % [tool_data["icon"], tool_data["name"]]
		btn.custom_minimum_size = Vector2(40, 40)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_font(btn, false, 9)
		btn.pressed.connect(_on_tool_selected.bind(tool_data["name"]))
		_app_grid.add_child(btn)

func _toggle_start_menu() -> void:
	_start_menu.visible = not _start_menu.visible

func _on_tool_selected(tool_name: String) -> void:
	_start_menu.visible = false
	if tool_name == _scenario["tool"]:
		_diag_window.visible = true
		_window_title.text = tool_name
		_status_label.text = "Ready. Click 'Run Scan' to begin."
		_scan_button.disabled = false
		_fix_button.disabled = true
		_phase = "scan"
		for child in _results_list.get_children():
			child.queue_free()
		_fix_options.clear()
	else:
		_show_toast("⚠  This tool won't help. Try another.")
		_subtract_time(5.0)

func _on_scan_pressed() -> void:
	_scan_button.disabled = true
	_fix_button.disabled = true
	_status_label.text = "Scanning system..."
	_scan_progress.visible = true
	_scan_progress.value = 0

	for child in _results_list.get_children():
		child.queue_free()
	_fix_options.clear()

	var tween := create_tween()
	tween.tween_property(_scan_progress, "value", 100.0, 2.5)
	tween.tween_callback(_reveal_results)

func _reveal_results() -> void:
	_scan_progress.visible = false
	_status_label.text = "Scan complete. Select a fix."

	for line in _scenario["scan_results"]:
		var lbl := Label.new()
		lbl.text = "  • " + line
		_apply_font(lbl, false, 10)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
		_results_list.add_child(lbl)

	_results_list.add_child(HSeparator.new())

	var fix_hdr := Label.new()
	fix_hdr.text = "Select the correct fix:"
	_apply_font(fix_hdr, true, 10)
	fix_hdr.add_theme_color_override("font_color", Color(0.1, 0.1, 0.4))
	_results_list.add_child(fix_hdr)

	_button_group = ButtonGroup.new()
	_correct_fix_text = _scenario["options"][_scenario["correct_fix"]]
	var opts: Array = _scenario["options"].duplicate()
	opts.shuffle()

	for opt_text in opts:
		var cb := CheckBox.new()
		cb.text = opt_text
		cb.button_group = _button_group
		_apply_font(cb, false, 10)
		cb.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
		cb.add_theme_color_override("font_hover_color", Color(0.05, 0.05, 0.05))
		cb.add_theme_color_override("font_pressed_color", Color(0.05, 0.05, 0.05))
		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.75, 0.75, 0.75, 1)
		hover_style.corner_radius_top_left = 3
		hover_style.corner_radius_top_right = 3
		hover_style.corner_radius_bottom_left = 3
		hover_style.corner_radius_bottom_right = 3
		cb.add_theme_stylebox_override("hover", hover_style)
		cb.toggled.connect(_on_option_toggled)
		_results_list.add_child(cb)
		_fix_options.append(cb)

	_fix_button.disabled = false
	_phase = "fix"

func _on_option_toggled(_pressed: bool) -> void:
	_fix_button.disabled = false

func _on_fix_pressed() -> void:
	if _phase != "fix":
		return

	var selected_text: String = ""
	for cb: CheckBox in _fix_options:
		if cb.button_pressed:
			selected_text = cb.text
			break

	if selected_text == "":
		_show_toast("Please select a fix option first.")
		return

	if selected_text == _correct_fix_text:
		_scan_button.disabled = true
		_fix_button.disabled = true
		_phase = "done"
		_status_label.text = "✅ " + _scenario["win_message"]
		_show_toast("✅ " + _scenario["win_message"])
		try_complete()
	else:
		_show_toast("❌ Wrong fix. Re-scan and try again.")
		_subtract_time(8.0)
		_scan_button.disabled = false
		_fix_button.disabled = true
		_phase = "scan"

func _on_close_window() -> void:
	_diag_window.visible = false
	_phase = "start"

# ── TitleBar drag ──────────────────────────────────────────────────────────────
func _on_titlebar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if event.pressed:
			_drag_offset = _diag_window.position - event.global_position
	elif event is InputEventMouseMotion and _dragging:
		var desktop: Control = get_node(_VP)
		var vp_size: Vector2 = desktop.size
		var new_pos: Vector2 = event.global_position + _drag_offset
		new_pos.x = clamp(new_pos.x, 0.0, vp_size.x - _diag_window.size.x)
		new_pos.y = clamp(new_pos.y, 0.0, vp_size.y - _diag_window.size.y)
		_diag_window.position = new_pos

# ── Helpers ────────────────────────────────────────────────────────────────────
func _show_toast(msg: String) -> void:
	_toast_label.text = msg
	_toast.visible = true
	await get_tree().create_timer(2.5).timeout
	if is_instance_valid(_toast):
		_toast.visible = false

func _subtract_time(seconds: float) -> void:
	var bar := get_node_or_null(timer_bar)
	if bar and bar.has_method("add_time"):
		bar.add_time(-seconds)

# ── BaseMinigame overrides ─────────────────────────────────────────────────────
func _check_completion() -> bool:
	return _phase == "done"

func _on_complete() -> void:
	print("Minigame 5 - Diagnostics complete!")
	GameState.record_npc_served()

func _on_pause_button_pressed() -> void:
	_toggle_pause()
