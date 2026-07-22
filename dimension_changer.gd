extends Node

@onready var dimension_1: TileMap = $"../Dimension 1"
@onready var dimension_2: TileMap = $"../Dimension 2"

func _ready() -> void:
	randomize()
	loop()
	
func loop():
	while true:
		dimension_1.visible = !dimension_1.visible
		dimension_2.visible = !dimension_2.visible
		await get_tree().create_timer(randf_range(5, 10)).timeout
		dimension_1.visible = !dimension_1.visible
		dimension_2.visible = !dimension_2.visible
		await get_tree().create_timer(randf_range(5, 10)).timeout
