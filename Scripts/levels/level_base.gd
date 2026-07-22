class_name LevelBase extends Node2D
## Base class for levels

var dimensions: Array[Node2D] = []
var current_dimension: Node2D
var current_dimension_id: int = 0 #current dimension's position in dimensions array
var dimension_count: int

@export var switch_timer: Timer

func _ready() -> void:
	switch_timer.timeout.connect(switch_dimensions)
	dimension_count = dimensions.size()
	
	if dimension_count == 0:
		push_error("Dimensions not loaded")
		return
	
	for i in range(dimension_count): #set up current dimension
		if i == current_dimension_id:
			dimensions[i].visible = true
			dimensions[i].process_mode = Node.PROCESS_MODE_INHERIT
		else:
			dimensions[i].visible = false
			dimensions[i].process_mode = Node.PROCESS_MODE_DISABLED
	
	current_dimension = dimensions[current_dimension_id]
	print(current_dimension)

func switch_dimensions():
	current_dimension.visible = false
	current_dimension.process_mode = Node.PROCESS_MODE_DISABLED #to avoid any collisions with other dimensions
	
	current_dimension_id = wrapi(current_dimension_id + 1, 0, dimension_count)
	current_dimension = dimensions[current_dimension_id]
	
	current_dimension.visible = true
	current_dimension.process_mode = Node.PROCESS_MODE_INHERIT
	
	print(current_dimension)

func _process(delta: float) -> void:
	if switch_timer and not switch_timer.is_stopped():
		EventBus.timer_updated.emit(switch_timer.time_left)
