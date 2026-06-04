extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	player.bus = "Music"

func play(stream: AudioStream) -> void:
	if player.stream == stream and player.playing:
		return  # already playing this track, don't restart
	player.stream = stream
	player.play()

func stop() -> void:
	player.stop()

func set_volume_db(db: float) -> void:
	player.volume_db = db
