extends BaseCutscene

func get_title_label() -> String:
	return "Epilogue"

func get_subtitle_label() -> String:
	return "IT Support Floor — 5:58 PM"

func get_dialogue() -> Array:
	return [
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Queue's clear.\nEvery ticket. Closed."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Every single one?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Every single one.\nI checked three times.\nI don't know how you did it."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Honestly? Neither do I.\nI think I crimped cables\nin my sleep last night."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "That's the spirit.\nThat's exactly the kind of\n[color=#ffdd44]dedication[/color] this floor needs."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Was that a compliment?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Don't push it."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "What happens now?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Now? You go home.\nGet some sleep.\nBasti comes back on Monday."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "..."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "I know.\n[color=#ff4444]I know.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "See you Monday, I guess."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "See you Monday.\n[color=#ffdd44]Good work this week.[/color]\nDon't tell anyone I said that."
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
