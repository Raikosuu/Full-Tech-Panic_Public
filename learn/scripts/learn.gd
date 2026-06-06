extends Control

@onready var cpupanel: Panel = $cpupanel
@onready var mobopanel: Panel = $mobopanel
@onready var rampanel: Panel = $rampanel
@onready var hddpanel: Panel = $hddpanel

@onready var cpu_btn: Button = $cpu
@onready var mobo_btn: Button = $mobo
@onready var ram_btn: Button = $ram
@onready var hdd_btn: Button = $hdd

var panels: Array
var buttons: Array

func _ready() -> void:
	panels = [cpupanel, mobopanel, rampanel, hddpanel]
	buttons = [cpu_btn, mobo_btn, ram_btn, hdd_btn]
	for panel in panels:
		panel.visible = false

func _close_others(except_index: int) -> void:
	for i in panels.size():
		if i != except_index:
			panels[i].visible = false
			buttons[i].button_pressed = false

func _on_cpu_toggled(pressed: bool) -> void:
	_close_others(0)
	cpupanel.visible = pressed

func _on_mobo_toggled(pressed: bool) -> void:
	_close_others(1)
	mobopanel.visible = pressed

func _on_ram_toggled(pressed: bool) -> void:
	_close_others(2)
	rampanel.visible = pressed

func _on_hdd_toggled(pressed: bool) -> void:
	_close_others(3)
	hddpanel.visible = pressed
