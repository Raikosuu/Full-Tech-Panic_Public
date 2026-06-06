extends Control

@onready var gpupanel: Panel = $gpupanel
@onready var psupanel: Panel = $psupanel
@onready var coolingfanpanel: Panel = $coolingfanpanel
@onready var computertowerpanel: Panel = $computertowerpanel

@onready var gpu_btn: Button = $gpu
@onready var psu_btn: Button = $psu
@onready var coolingfan_btn: Button = $coolingfan
@onready var computertower_btn: Button = $computertower

var panels: Array
var buttons: Array

func _ready() -> void:
	panels = [gpupanel, psupanel, coolingfanpanel, computertowerpanel]
	buttons = [gpu_btn, psu_btn, coolingfan_btn, computertower_btn]
	for panel in panels:
		panel.visible = false

func _close_others(except_index: int) -> void:
	for i in panels.size():
		if i != except_index:
			panels[i].visible = false
			buttons[i].button_pressed = false

func _on_gpu_toggled(pressed: bool) -> void:
	_close_others(0)
	gpupanel.visible = pressed

func _on_psu_toggled(pressed: bool) -> void:
	_close_others(1)
	psupanel.visible = pressed

func _on_coolingfan_toggled(pressed: bool) -> void:
	_close_others(2)
	coolingfanpanel.visible = pressed

func _on_computertower_toggled(pressed: bool) -> void:
	_close_others(3)
	computertowerpanel.visible = pressed
	
func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch and event.pressed):
		return
	var p = event.position
	for i in buttons.size():
		if buttons[i].get_global_rect().has_point(p):
			buttons[i].button_pressed = not buttons[i].button_pressed
			if buttons[i].button_pressed:
				_close_others(i)
				panels[i].visible = true
			else:
				panels[i].visible = false
