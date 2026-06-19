extends Control

@onready var soundcardpanel: Panel = $soundcardpanel
@onready var soundcard_btn: Button = $soundcard

var page_content = {
	"soundcard": [
		"A sound card (audio card or soundboard) is either an expansion card or integrated motherboard component that allows a computer to produce and record sound. It translates between digital audio data and analog sound waves for speakers, headphones, and microphones.",
		"The sound card uses a Digital-to-Analog Converter (DAC) to turn stored audio data into electrical signals your speakers can play. An Analog-to-Digital Converter (ADC) does the reverse for recording. Higher-end cards use better DACs for cleaner, less distorted audio.",
		"Early PCs had no sound at all — the first IBM PC could only beep using a tiny internal speaker. Creative Labs' Sound Blaster (1989) became the industry standard for PC audio. Today most motherboards have a decent integrated sound chip, making discrete sound cards mostly used by audiophiles and musicians."
	]
}

func _ready() -> void:
	soundcardpanel.visible = false
	_setup_tabs()

func _setup_tabs() -> void:
	var tab_overview : Button = soundcardpanel.get_node("VBoxContainer/tabs/tab_overview")
	var tab_howit    : Button = soundcardpanel.get_node("VBoxContainer/tabs/tab_howit")
	var tab_facts    : Button = soundcardpanel.get_node("VBoxContainer/tabs/tab_facts")
	var desc         : Label  = soundcardpanel.get_node("VBoxContainer/ScrollContainer/desc")
	var desc_howit   : Label  = soundcardpanel.get_node("VBoxContainer/ScrollContainer/desc_howit")
	var desc_facts   : Label  = soundcardpanel.get_node("VBoxContainer/ScrollContainer/desc_facts")

	desc.text       = page_content["soundcard"][0]
	desc_howit.text = page_content["soundcard"][1]
	desc_facts.text = page_content["soundcard"][2]

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

func _on_soundcard_toggled(pressed: bool) -> void:
	soundcard_btn.button_pressed = pressed
	soundcardpanel.visible = pressed
