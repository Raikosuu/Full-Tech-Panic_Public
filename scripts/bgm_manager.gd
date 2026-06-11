extends Node

const BGM_MENU = preload("res://sfx/sergequadrado-menu-music-251877.mp3")
const BGM_GAME = preload("res://sfx/freesound_community-gamemusic-6082.mp3")

var player: AudioStreamPlayer

func _ready() -> void:
	# Use the existing child node from the scene instead of creating a new one
	player = $AudioStreamPlayer
	player.bus = "Music"
	player.volume_db = -10.0

func play(stream: AudioStream, volume_db: float = -10.0) -> void:
	if player == null:
		return
	if player.stream == stream and player.playing:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()

func stop() -> void:
	if player == null:
		return
	player.stop()

func set_volume_db(db: float) -> void:
	if player == null:
		return
	player.volume_db = db

func crossfade(new_stream: AudioStream, duration: float = 1.0, volume_db: float = -10.0) -> void:
	if player == null:
		return
	if player.stream == new_stream and player.playing:
		return
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished
	player.stream = new_stream
	player.volume_db = volume_db
	player.play()
