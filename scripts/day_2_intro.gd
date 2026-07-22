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
			"text":    "Calmer. His monitor stopped breathing. Now his mouse is 'whispering.'\nWe're handling it in stages."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Right. Anyway, what's today's disaster?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Today's a different kind of problem. Half the office can't\n connect to anything. Network cables everywhere."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Let me guess. Basti."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Some Ethernet Cables are wired [color=#ff4444]T568-A.[/color] Some are wired [color=#ff4444]T568-B.[/color]\nBasti mixed up the labeling on half of them 'to make it more organized.'"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "So I just... pick one and use it everywhere?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "No! Each ticket tells you which standard that jack needs. Get it wrong \nand it's still dead on arrival. Just like Basti's logic."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Two standards, gotta check every time. Got it."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "White-Orange, Orange... or White-Green, Green, \ndepending which one you're on. Don't mix them up."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "T568-A, T568-B. Read the ticket first. Got it."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Oh — and the weird-computer tickets didn't stop just because the cables\nexploded. A few are still possessed. Michael insists his is one of them."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Michael's computer is fine, Michael\nis just having a week."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Aren't we all. Now go [color=#ffdd44]fix it[/color] before\n the 9 AM meeting that is already ruined."
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file(GameState.current_level_scene)
