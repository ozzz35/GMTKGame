extends Node2D

var enemies_spawned: bool = false

@onready var enemy_spawners: Node2D = $EnemySpawners

func try_spawn_enemies():
	if enemies_spawned:
		return
	
	enemies_spawned = true
	
	for child in enemy_spawners.get_children():
		if child.is_in_group("enemy_spawner"):
			child.spawn_enemy()
