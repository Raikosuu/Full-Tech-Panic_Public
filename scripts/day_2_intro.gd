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
			"text":    "...thanks. I think. How's Michael?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Calmer. His monitor stopped breathing.\nNow his mouse is 'whispering.'\nWe're handling it in stages."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Right. Anyway, what's today's disaster?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Today's a different kind of problem.\nHalf the office can't connect to\nanything. Network cables everywhere."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Let me guess. Basti."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Some Ethernet Cables are wired [color=#ff4444]T568-A.[/color]\nSome are wired [color=#ff4444]T568-B.[/color]\nBasti mixed up the labeling on half of them\n'to make it more organized.'"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "So I just... pick one and use it everywhere?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "No! Each ticket tells you which standard\nthat jack needs. Get it wrong and it's\nstill dead on arrival. Just like Basti's logic."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Two standards, gotta check every time. Got it."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "White-Orange, Orange... or White-Green,\nGreen, depending which one you're on.\nDon't mix them up."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "T568-A, T568-B. Read the ticket first. Got it."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Oh — and the weird-computer tickets\ndidn't stop just because the cables\nexploded. A few are still possessed.\nMichael insists his is one of them."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Michael's computer is fine, Michael\nis just having a week."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Aren't we all.\nNow go [color=#ffdd44]fix it[/color] before the 9 AM\nmeeting that is already ruined."
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file(GameState.current_level_scene)
