class_name LevelBase extends Node2D
## Base class for levels

var level_index: int

var dimensions: Array[Node2D] = []
var current_dimension: Node2D
var current_dimension_id: int = 0 #current dimension's position in dimensions array
var dimension_count: int

const player_scene = preload("uid://fbqttmuh0e6b")

@onready var switch_timer: Timer = $SwitchTimer
@onready var level_finish_area: Area2D = $LevelFinishArea
@onready var entity_layer: Node2D = $EntityLayer
@onready var player_spawn_point: Node2D = $PlayerSpawnPoint

func _ready() -> void:
	switch_timer.timeout.connect(switch_dimensions)
	level_finish_area.area_entered.connect(_on_level_finished_area_entered)
	
	dimension_count = dimensions.size()
	
	if dimension_count == 0:
		push_error("Dimensions not loaded")
		return
	
	spawn_player()
	
	for i in range(dimension_count): #set up current dimension
		if i == current_dimension_id:
			dimensions[i].visible = true
			dimensions[i].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			dimensions[i].visible = false
			dimensions[i].process_mode = Node.PROCESS_MODE_DISABLED
	
	current_dimension = dimensions[current_dimension_id]

func switch_dimensions():
	EventBus.switched_dimensions.emit()
	
	await get_tree().create_timer(0.03).timeout
	
	current_dimension.visible = false
	current_dimension.process_mode = Node.PROCESS_MODE_DISABLED #to avoid any collisions with other dimensions
	
	current_dimension_id = wrapi(current_dimension_id + 1, 0, dimension_count)
	current_dimension = dimensions[current_dimension_id]
	
	current_dimension.visible = true
	current_dimension.process_mode = Node.PROCESS_MODE_INHERIT


func _process(delta: float) -> void:
	if switch_timer and not switch_timer.is_stopped():
		EventBus.timer_updated.emit(switch_timer.time_left)

func spawn_player() -> void:
	if player_scene == null:
		push_warning("Player Scene atanmamış!")
		return
		
	var player_instance = player_scene.instantiate() as Node2D
	
	if player_spawn_point:
		player_instance.global_position = player_spawn_point.global_position
	
	if entity_layer:
		entity_layer.add_child(player_instance)
	else:
		add_child(player_instance)

func _on_level_finished_area_entered(area: Area2D):
	if area.get_parent().is_in_group("character"):
		EventBus.level_completed.emit.call_deferred(level_index)
