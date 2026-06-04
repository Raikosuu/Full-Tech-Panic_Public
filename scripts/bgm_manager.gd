extends Node

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "Music"
	player.volume_db = -10.0

func play(stream: AudioStream, volume_db: float = -10.0) -> void:
	if player.stream == stream and player.playing:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func stop() -> void:
	player.stop()

func set_volume_db(db: float) -> void:
	player.volume_db = db

func crossfade(new_stream: AudioStream, duration: float = 1.0, volume_db: float = -10.0) -> void:
	if player.stream == new_stream and player.playing:
		return
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished
	player.stream = new_stream
	player.volume_db = volume_db
	player.play()
