extends BaseCutscene

func get_title_label() -> String:
	return "Day 2"

func get_subtitle_label() -> String:
	return "IT Support Floor — 8:57 AM"

func get_dialogue() -> Array:
	return [
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "You survived day one. Good.\nI was honestly not sure you would."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "...thanks. I think."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Today's a different kind of problem.\nHalf the office can't connect to\nanything. Network cables everywhere."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Okay, that sounds manageable."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Someone re-crimped [color=#ff4444]every cable[/color] in\nthe building over the weekend.\nUsing the [color=#ff4444]T568-A standard.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Instead of T568-B?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Instead of T568-B.\nWe think it was Basti.\nBasti thinks it was fine."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Was it fine?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Nothing works.\nSo. [color=#ff4444]No.[/color]\nYou'll need to re-crimp them correctly.\nPin order matters. Don't mix them up."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "T568-B. Got it.\nWhite-Orange, Orange, White-Green..."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Yes yes, you know the standard.\nNow go [color=#ffdd44]fix it[/color] before the 9 AM\nmeeting that is already ruined."
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file(GameState.current_level_scene)
