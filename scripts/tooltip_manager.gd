extends CanvasLayer

const TOOLTIP_TEXT := {
	"MOBO":    "Motherboard",
	"CPU":     "CPU",
	"CFAN":    "Cooling Fan",
	"HDD":     "Hard Disk Drive",
	"RAM":     "RAM",
	"BATTERY": "Power Supply",
	"PANEL":   "Computer Panel",
	"SCREW":   "Screw",
}

var _panel: Panel
var _label: Label

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_panel = Panel.new()
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.position = Vector2(6, 4)
	_panel.add_child(_label)

func show_for(component_type: String, screen_pos: Vector2) -> void:
	var text: String = TOOLTIP_TEXT.get(component_type, component_type)
	_label.text = text
	var min_size := _label.get_minimum_size()
	_panel.size = min_size + Vector2(12, 8)
	_panel.position = screen_pos + Vector2(14, -min_size.y - 20)
	_panel.visible = true

func move_to(screen_pos: Vector2) -> void:
	if _panel.visible:
		var min_size := _label.get_minimum_size()
		_panel.position = screen_pos + Vector2(14, -min_size.y - 20)

func hide_tooltip() -> void:
	_panel.visible = false
