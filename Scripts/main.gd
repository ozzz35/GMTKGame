extends Node2D

@export var level_scenes: Array[PackedScene] = []

@onready var levels_container: Node2D = $Levels
@onready var pause_menu: Control = $UI/PauseMenu

var current_level_index: int = 0
var current_level_node: LevelBase = null

var pause_menu_on: bool = false

func _ready() -> void:
	EventBus.level_load.connect(next_level)
	load_level(0)


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

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		pause_menu_on_off()

func pause_menu_on_off():
	if pause_menu_on:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true
	
	pause_menu_on = !pause_menu_on

func quit_to_main_menu():
	pass
