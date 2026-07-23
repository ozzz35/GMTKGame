extends Node2D

@export var level_scenes: Array[PackedScene] = []

@onready var levels_container: Node2D = $Levels

var current_level_index: int = 0
var current_level_node: LevelBase = null

func _ready() -> void:
	EventBus.level_load.connect(next_level)
	load_level(0)
	await get_tree().create_timer(5.0).timeout
	SoundManager.switch_music("intense", 4)
	await get_tree().create_timer(10.0).timeout
	SoundManager.switch_music("game", 4)


func load_level(index: int) -> void:
	if index < 0 or index >= level_scenes.size():
		print("Invalid level index")
		return
		
	if current_level_node != null:
		current_level_node.queue_free()
		
	var new_level_scene = level_scenes[index]
	current_level_node = new_level_scene.instantiate() as LevelBase
	
	levels_container.add_child(current_level_node)
	current_level_index = index

func next_level() -> void:
	load_level(current_level_index + 1)
