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

var page_content = {
	"cpu": [
		"The CPU is a critical hardware component responsible for processing instructions from software and coordinating all other computer components. It interprets binary signals (1s and 0s) to perform calculations, make decisions, and control data flow, enabling tasks like gaming, video playback, and running applications.",
		"The CPU fetches instructions from memory, decodes what they mean, then executes the operation. Modern CPUs do this billions of times per second using multiple cores working in parallel. Each core can handle its own thread of instructions simultaneously.",
		"The first commercial CPU, the Intel 4004 (1971), had only 2,300 transistors. Today's CPUs have over 100 billion. If cars improved at the same rate, a trip across the country would take under a second!"
	],
	"mobo": [
		"A motherboard is the main circuit board of a computer that connects and allows communication between all essential components. Also called a mainboard or system board, it acts as the backbone of the entire system.",
		"The motherboard uses buses — electrical pathways — to carry data between the CPU, RAM, and other components. The chipset acts as a traffic controller, deciding which data goes where and when. Slots like PCIe allow expansion cards to plug in.",
		"Early motherboards were so large they filled entire rooms. The term 'motherboard' comes from the idea that it is the 'mother' of all other boards — smaller 'daughter boards' plug into it for extra features like sound or networking."
	],
	"ram": [
		"RAM (Random Access Memory) is your computer's short-term memory, temporarily storing data for fast access by the CPU. Unlike storage drives, RAM is volatile — all data is lost when the computer powers off.",
		"When you open an app, the OS copies it from storage into RAM because RAM is dramatically faster. The CPU then pulls instructions directly from RAM in nanoseconds, compared to milliseconds for a hard drive — a difference of millions of times in speed.",
		"The term 'random access' means any memory location can be read in the same time, unlike magnetic tape where you rewound to find data. Early RAM in the 1950s used tiny magnetic rings called 'core memory' and cost millions per megabyte."
	],
	"hdd": [
		"A hard disk drive (HDD) is a non-volatile storage device that uses spinning magnetic platters and read/write heads to store and retrieve digital data. It retains data even when the computer is powered off.",
		"A tiny read/write head floats nanometers above a spinning platter rotating at 5,400–7,200 RPM and magnetizes microscopic spots to represent 0s and 1s. The head never touches the platter — contact would cause a 'head crash' destroying data.",
		"The first hard drive, IBM's 350 RAMAC (1956), weighed over a ton, needed a forklift to move, and stored just 5 MB — about one low-quality photo. It rented for $3,200 per month. Today a $50 drive holds 1 TB."
	]
}

func _ready() -> void:
	panels = [cpupanel, mobopanel, rampanel, hddpanel]
	buttons = [cpu_btn, mobo_btn, ram_btn, hdd_btn]
	for panel in panels:
		panel.visible = false
	_setup_tabs()

func _setup_tabs() -> void:
	var keys = ["cpu", "mobo", "ram", "hdd"]
	var panel_nodes = [cpupanel, mobopanel, rampanel, hddpanel]
	for i in panel_nodes.size():
		var panel = panel_nodes[i]
		var key = keys[i]
		var tab_overview : Button = panel.get_node("VBoxContainer/tabs/tab_overview")
		var tab_howit    : Button = panel.get_node("VBoxContainer/tabs/tab_howit")
		var tab_facts    : Button = panel.get_node("VBoxContainer/tabs/tab_facts")
		var desc         : Label  = panel.get_node("VBoxContainer/ScrollContainer/desc")
		var desc_howit   : Label  = panel.get_node("VBoxContainer/ScrollContainer/desc_howit")
		var desc_facts   : Label  = panel.get_node("VBoxContainer/ScrollContainer/desc_facts")

		desc.text       = page_content[key][0]
		desc_howit.text = page_content[key][1]
		desc_facts.text = page_content[key][2]

		tab_overview.button_pressed = true
		desc.visible       = true
		desc_howit.visible = false
		desc_facts.visible = false

		tab_overview.pressed.connect(func():
			desc.visible = true; desc_howit.visible = false; desc_facts.visible = false)
		tab_howit.pressed.connect(func():
			desc.visible = false; desc_howit.visible = true; desc_facts.visible = false)
		tab_facts.pressed.connect(func():
			desc.visible = false; desc_howit.visible = false; desc_facts.visible = true)

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
