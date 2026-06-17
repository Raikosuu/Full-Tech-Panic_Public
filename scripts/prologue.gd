extends BaseCutscene

func _on_cutscene_ready() -> void:
	var bgm := load("res://sfx/freesound_community-gamemusic-6082.mp3") as AudioStream
	BGMManager.play(bgm, -10.0)

func get_title_label() -> String:
	return "Day 1"

func get_subtitle_label() -> String:
	return "IT Support Floor — 8:59 AM"

func get_dialogue() -> Array:
	return [
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Okay... first day in the ITRC. I can do this.\nJust fix computers. How hard can it be?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Oh good, you came! We've got\n[color=#ff9933]47 tickets[/color] from the users already\n and it's not even 9 AM."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "...forty-seven??"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Michael says his monitor\nis 'breathing.' Basti unplugged the server\nagain. And someone crimped a cable\n[color=#ff4444]with a stapler.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "A... stapler??!"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "And a good chunk of these aren't even\nbroken hardware. Computers just acting\n[color=#ffdd44]weird.[/color] Slow, crashing, throwing errors.\nYou'll have to actually figure out what's wrong."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "So I'm a technician AND a detective now?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Congratulations on the promotion.\nNo raise, though.\nJust use the diagnostic tools on the desktop\nand don't accuse the printer of anything."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Each user has a [color=#ffdd44]patience bar.[/color]\nLet it hit zero — they walk.\nYou get a mark on your record."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Three marks and I have to write up a\nvery strongly-worded email. I hate\nwriting emails. [color=#ff4444]Don't make me do that.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "Crystal clear."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Great. The queue's already piling up.\nGood luck. You'll need it."
		},
	]

func go_to_next() -> void:
	get_tree().change_scene_to_file(GameState.current_level_scene)
