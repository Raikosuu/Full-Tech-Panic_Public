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

var page_content = {
	"gpu": [
		"A graphics card renders images, videos, and 3D graphics for your display. It can be integrated into the motherboard or a discrete expansion card. Discrete GPUs are essential for gaming, 3D rendering, video editing, and AI tasks.",
		"The GPU contains thousands of small cores designed to handle many tasks simultaneously — perfect for graphics, which require the same math operation on millions of pixels at once. It has its own dedicated VRAM so it doesn't compete with system RAM.",
		"The term GPU was coined by NVIDIA in 1999 with the GeForce 256. Early computers had no GPU at all — games like Pong were drawn by the CPU directly. Today, GPUs are also used to train AI models and mine cryptocurrency."
	],
	"psu": [
		"A Power Supply Unit (PSU) converts AC power from your wall outlet into the DC voltages (3.3V, 5V, 12V) required by computer components. It supplies stable power to every part of the system.",
		"The PSU uses a transformer to step down wall voltage, then rectifiers and capacitors to convert AC to smooth DC. A feedback circuit constantly monitors output voltage and adjusts to keep it stable even as the load changes.",
		"PSU efficiency is rated with 80 Plus certifications (Bronze, Silver, Gold, Platinum, Titanium). A Titanium-rated PSU wastes less than 10% of power as heat. Cheap PSUs can damage components with unstable voltage spikes."
	],
	"coolingfan": [
		"A cooling fan removes excess heat from computer components by generating airflow. It prevents damage from overheating and maintains stable performance. Fans are found on CPUs, GPUs, cases, and power supplies.",
		"Fans use convective heat transfer — blades spin to push air over hot surfaces like heatsinks, carrying heat away into the case or outside. Case fans are arranged to create a front-to-back airflow path, pulling cool air in and pushing hot air out.",
		"The fastest cooling fans spin at over 10,000 RPM and can move enough air to cool a CPU generating over 300W of heat. Some gaming PCs use liquid cooling instead, where water absorbs heat and carries it to a radiator — just like a car engine."
	],
	"computertower": [
		"A computer tower (PC case or chassis) is the enclosure containing all core desktop components — motherboard, CPU, GPU, RAM, storage, and PSU. Its vertical design allows better airflow and more room for expansion than flat cases.",
		"Cases are designed with airflow paths in mind: vents and fan mounts at the front intake cool air, while top and rear exhausts expel hot air. Good cable management inside the case also improves airflow by reducing obstructions.",
		"PC cases come in three main sizes: Full Tower (for workstations with lots of expansion), Mid Tower (the most common), and Mini-ITX (compact builds). The smallest gaming PCs today are smaller than a lunchbox yet can outperform consoles."
	]
}

func _ready() -> void:
	panels = [gpupanel, psupanel, coolingfanpanel, computertowerpanel]
	buttons = [gpu_btn, psu_btn, coolingfan_btn, computertower_btn]
	for panel in panels:
		panel.visible = false
	_setup_tabs()

func _setup_tabs() -> void:
	var keys = ["gpu", "psu", "coolingfan", "computertower"]
	var panel_nodes = [gpupanel, psupanel, coolingfanpanel, computertowerpanel]
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
