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
			"text":    "Oh good, you came! We've got[color=#ff9933] 20 tickets[/color]\n from the users already and it's not even 9 AM."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "...twenty??"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Michael says his monitor is 'breathing.' Basti unplugged the server again.\n And someone crimped a cable[color=#ff4444] with a stapler.[/color]"
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "A... stapler??!"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "And a good chunk of these aren't even broken hardware. Computers just acting [color=#ffdd44]weird.[/color] \nSlow, crashing, throwing errors. You'll have to actually figure out what's wrong."
		},
		{
			"speaker": "You",
			"color":   Color(0.4, 0.8, 1.0),
			"text":    "So I'm a technician AND a detective now?"
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Congratulations on the promotion. No raise, though. Just use the diagnostic tools\non the desktop and don't accuse the printer of anything."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Each user has a [color=#ffdd44]patience bar.[/color]Let it hit zero — they walk.\n You get a mark on your record."
		},
		{
			"speaker": "Boss",
			"color":   Color(1.0, 0.6, 0.2),
			"text":    "Three marks and I have to write up a very strongly-worded email.\n I hate writing emails. [color=#ff4444]Don't make me do that.[/color]"
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
