extends Node2D

var enemies_spawned: bool = false

@onready var enemy_spawners: Node2D = $EnemySpawners
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
var index: int = 0
@onready var enemy_layer: Node2D = $EnemyLayer
@onready var walls: TileMapLayer = $Walls

@export var color: String

func try_spawn_enemies():
	if enemies_spawned:
		return
	
	enemies_spawned = true
	
	for child in enemy_spawners.get_children():
		if child.is_in_group("enemy_spawner"):
			child.spawn_enemy()
	
	setup(index)

func setup(num: int):
	index = num
	navigation_region.navigation_layers = index
	for enemy in enemy_layer.get_children():
		enemy.color = color
		enemy.navigation_agent.navigation_layers = index
	
	await get_tree().create_timer(0.05).timeout
	
	for enemy in enemy_layer.get_children():
		if enemy is EnemyBase:
			enemy.color = color

func dimension_on():
	walls.enabled = true
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	
	debug()

func dimension_off():
	walls.enabled = false
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	
	debug()

func debug():
	return
	
	var enemy_nav_agent_layer: Array
	for enemy in enemy_layer.get_children():
		if enemy is EnemyBase:
			enemy_nav_agent_layer.append(enemy.navigation_agent.navigation_layers)
	
	print("Dimension: ", str(index),
	 " NavRegion Layer: ", str(navigation_region.navigation_layers),
	" Enemy NavAgent Layer: ", str(enemy_nav_agent_layer))
