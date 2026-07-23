extends Node2D

@export var enemy_scene : PackedScene
@onready var enemy_root: Node2D = get_parent()

var last_spawned_enemy: EnemyBase
var player: CharacterBase

var spawned_enemy: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("character")

func spawn_enemy():
	if enemy_scene == null:
		push_error("Enemy scene not assigned.")
		return
	var enemy = enemy_scene.instantiate() as EnemyBase
	enemy.global_position = global_position
	enemy.character = player
	enemy_root.call_deferred("add_child", enemy)
	spawned_enemy = true
	last_spawned_enemy = enemy
