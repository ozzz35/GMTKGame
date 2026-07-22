extends LevelBase

@onready var dimension_1: Node2D = $Dimension1
@onready var dimension_2: Node2D = $Dimension2

func _ready() -> void:
	dimensions = [dimension_1, dimension_2]
	
	super._ready()
