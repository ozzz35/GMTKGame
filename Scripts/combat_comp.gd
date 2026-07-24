extends Node2D

@onready var base : CharacterBase = get_parent()
@onready var muzzle: Marker2D = $"../Sprites/Upper/Muzzle"
@onready var upper_body: AnimatedSprite2D = $"../Sprites/Upper"

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var shell = preload("res://Scenes/shell.tscn")


var dead : bool = false
var health : int
var max_health : int = 100
var bullets : int = 10
var max_bullets : int = 10
var reload_time : float = 3.0
var is_reloading : bool = false
var pump : bool = false

signal is_dead
signal took_damage(damage: int, from_pos: Vector2)
signal shot
signal health_changed(health_val: int)


func _ready() -> void:
	health = max_health

## -- Shooting System -- ##

func shoot_shotgun(pellet_count: int, spread_angle_deg: float):
	if is_reloading:
		return
		
	if bullets <= 0:
		reload()
		return
	
	if pump:
		return
	
	pump = true
	bullets -= 1
	EventBus.bullets_changed.emit(bullets, is_reloading)
	upper_body.play("shooting")
	SoundManager.play_sfx("gunshot")
	shot.emit()
	
	var base_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	var spread_rad: float = deg_to_rad(spread_angle_deg) / 3.0
	
	for i in range(pellet_count):
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		var random_offset: float = randf_range(-spread_rad, spread_rad)
		var pellet_direction: Vector2 = base_direction.rotated(random_offset)
		
		bullet.damage = randi_range(10, 15)
		bullet.fired_pos = global_position
		bullet.player = true
		bullet.global_position = muzzle.global_position
		bullet.direction = pellet_direction
		
		bullet.speed *= randf_range(0.80, 1.2)
		
		var delay: float = randf_range(0.001, 0.001)
		await get_tree().create_timer(delay).timeout

	await upper_body.animation_finished
	
	upper_body.play("idle")
	pump_gun()


func pump_gun():
	
	SoundManager.play_sfx("pump")
	await get_tree().create_timer(0.5).timeout
	pump = false

func reload():
	if is_reloading:
		return
	
	is_reloading = true
	EventBus.bullets_changed.emit(bullets, is_reloading)
	SoundManager.play_sfx("reload")
	dump_shell()
	await get_tree().create_timer(reload_time).timeout
	bullets = max_bullets
	is_reloading = false
	EventBus.bullets_changed.emit(bullets, is_reloading)

func dump_shell():
	var new_shell = shell.instantiate()
	get_tree().current_scene.add_child(new_shell)
	new_shell.global_position = muzzle.global_position
	new_shell.angular_velocity = randf_range(20.0, 35.0)

	

## -- Damage/Death System -- ##

func take_hit(damage : int, from_pos : Vector2):
	if base.movement_comp.invincible:
		return
	
	health -= damage
	took_damage.emit(damage, from_pos)
	health_changed.emit(health)
	
	print(health)
	EventBus.health_changed.emit(health)
	
	if health <= 0:
		dead = true
		is_dead.emit()
		return

func death():
	is_dead.emit()
	base.queue_free()


## -- Signals -- ##

#empty for now
