extends Node2D

@onready var base : CharacterBase = get_parent()
@onready var muzzle: Marker2D = $"../Sprites/Upper/Muzzle"
@onready var upper_body: AnimatedSprite2D = $"../Sprites/Upper"
@onready var shell_thingy: Marker2D = $"../Sprites/Upper/Shell_thingy"
@onready var flying_shell_marker: Marker2D = $"../Sprites/Upper/flying_shell_marker"
@onready var camera: Camera2D = $"../Camera"

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var shell = preload("res://Scenes/shell.tscn")
@onready var damage_label = preload("uid://c517qyr5kd11h")


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
	
	camera.shake(17, 0.7)
	
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
	await get_tree().create_timer(0.2).timeout
	upper_body.play("pump")
	await get_tree().create_timer(0.5).timeout
	dump_shell()
	upper_body.play("idle")
	pump = false

func reload():
	if is_reloading:
		return
	
	is_reloading = true
	EventBus.bullets_changed.emit(bullets, is_reloading)
	SoundManager.play_sfx("reload")
	upper_body.play("reload")
	await get_tree().create_timer(reload_time).timeout
	bullets = max_bullets
	is_reloading = false
	EventBus.bullets_changed.emit(bullets, is_reloading)

func dump_shell():
	var new_shell = shell.instantiate()
	get_tree().current_scene.add_child(new_shell)
	var direction = (flying_shell_marker.global_position - shell_thingy.global_position).normalized()
	new_shell.global_position = shell_thingy.global_position
	new_shell.angular_velocity = randf_range(200.0, 300.0)
	new_shell.linear_velocity = direction * randf_range(10.0, 100.0)
	var eject_speed = 500.0 + randf_range(-100.0, 200.0)
	new_shell.linear_velocity = direction * eject_speed
	

## -- Damage/Death System -- ##

func take_hit(damage : int, from_pos : Vector2):
	if base.movement_comp.invincible:
		return
	add_damage_label(damage)
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

func add_damage_label(damage):
	var new_damage_label = damage_label.instantiate() as Label
	new_damage_label.text = str(damage)
	new_damage_label.global_position = global_position - Vector2(0, 20)
	new_damage_label.add_theme_color_override("font_color", Color("C92C60"))
	new_damage_label.add_theme_color_override("font_size", 10)
	get_tree().current_scene.call_deferred("add_child", new_damage_label)


## -- Signals -- ##

#empty for now
