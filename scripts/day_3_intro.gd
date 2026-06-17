extends BaseCutscene

func get_title_label() -> String:
	return "Day 3"

func get_subtitle_label() -> String:
	return "IT Support Floor — 8:45 AM"

func get_dialogue() -> Array:
	return [
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Close the door."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "...that bad?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "The [color=#ff4444]entire IT queue[/color] from the last\ntwo weeks landed in my inbox\nat 6 AM this morning.\nAll of it. At once."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "How is that even possible."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Basti set up an auto-forward rule.\nHe thought it would [color=#ff4444]help.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "I am going to start keeping\na log of everything Basti does."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Good idea. Anyway — today you're\nhandling [color=#ffdd44]everything.[/color]\nAssembly, disassembly, cabling, diagnostics.\nAll of it."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "All of it."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "One user needs a PC built from scratch.\nAnother needs theirs stripped for parts.\nThree need cables re-done. [color=#ff4444]Again.[/color]\nAnd a pile of 'it's just acting weird' tickets,\nbecause there's always a pile of those."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "What about Michael?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Michael is [color=#ff4444]on leave.[/color]\nEffective this morning.\nI wrote a very strongly-worded email."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "You said you hated writing those."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "I meant every word.\nNow get out there.\n[color=#ffdd44]They're already lining up.[/color]"
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file(GameState.current_level_scene)
