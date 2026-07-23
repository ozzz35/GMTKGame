extends Node


@onready var sfx_players: Node = $SFXPlayers

@onready var music_players: Node = $MusicPlayers
@onready var music1: AudioStreamPlayer = $MusicPlayers/Music1
@onready var music2: AudioStreamPlayer = $MusicPlayers/Music2

const SOUNDS: Dictionary = {
	"intense" : preload("uid://d1g8mnj0fesqt"),
	"game" : preload("uid://bv3fu5i0dmhjd")
	
}

var current_music: String = "game"
var current_music_player: AudioStreamPlayer

## -- MUSIC -- ##

func _ready() -> void:
	current_music_player = music1
	
	music1.playing = true
	music2.playing = true

func switch_music(music: String, duration: float):
	if current_music == music:
		return
	
	current_music = music
	
	var tween1: Tween = create_tween().set_parallel(true)
	tween1.tween_property(current_music_player, "volume_db", -80.0, duration)
	
	current_music_player = get_other_music_player(current_music_player)
	
	tween1.tween_property(current_music_player, "volume_db", 0.0, duration)



func get_other_music_player(music_player):
	for player in music_players.get_children():
		if not player == music_player:
			return player

## -- SFX -- ##

func play_sfx(sfx_key: String, volume_db: float = 0.0):
	if not SOUNDS.has(sfx_key): return
	
	var new_player = AudioStreamPlayer.new()
	_play(new_player, sfx_key, volume_db)

func play_sfx_2d(sfx_key: String, position: Vector2, volume_db: float = 0.0):
	if not SOUNDS.has(sfx_key): return
	
	var new_player = AudioStreamPlayer2D.new()
	new_player.global_position = position
	
	new_player.max_distance = 2000.0 
	
	_play(new_player, sfx_key, volume_db)


func _play(player: Node, sfx_key: String, volume_db: float):
	player.bus = "SFX"
	player.stream = SOUNDS[sfx_key]
	player.volume_db = volume_db
	
	player.pitch_scale = randf_range(0.8, 1.2)
	
	sfx_players.add_child(player)
	player.play()
	
	player.finished.connect(func(): player.queue_free())


func set_bus_volume(bus_name: String, value: float):
	print("Volume changed: ", bus_name)
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		push_error("Audio bus not found: " + bus_name)
		return
	
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func set_pitch_play_sfx(sfx_key: String, pitch: float, volume_db: float = 0.0):
	if not SOUNDS.has(sfx_key): return
	
	var new_player = AudioStreamPlayer.new()
	set_pitch_play(new_player, sfx_key, volume_db, pitch)

func set_pitch_play(player: Node, sfx_key: String, volume_db: float, pitch: float):
	player.bus = "SFX"
	
	player.stream = SOUNDS[sfx_key]
	player.volume_db = volume_db
	player.pitch_scale = pitch
	sfx_players.add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())
	
