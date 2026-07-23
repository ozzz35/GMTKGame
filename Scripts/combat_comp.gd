extends Node2D

@onready var base : CharacterBase = get_parent()
@onready var muzzle: Marker2D = $"../Sprites/Upper/Muzzle"

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var dead : bool = false
var health : int
var max_health : int = 100

signal is_dead
signal took_damage(damage: int, from_pos: Vector2)
signal shot
signal health_changed(health_val: int)


func _ready() -> void:
	health = max_health

## -- Shooting System -- ##

func shoot_bullet():
	var direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	shot.emit()
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.damage = randi_range(14, 25)
	bullet.fired_pos = global_position
	bullet.player = true
	bullet.global_position = muzzle.global_position
	bullet.direction = direction



## -- Damage/Death System -- ##

func take_hit(damage : int, from_pos : Vector2):
	if not base.can_take_damage():
		return
	
	if base.movement_comp.invincible:
		return
	
	took_damage.emit(damage, from_pos)
	health_changed.emit(health)
	
	health -= damage
	
	if health <= 0:
		dead = true
		is_dead.emit()
		return

func death():
	is_dead.emit()
	base.queue_free()


## -- Signals -- ##

#empty for now
