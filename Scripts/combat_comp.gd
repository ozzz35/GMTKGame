extends Node2D

@onready var base : CharacterBase = get_parent()
@onready var muzzle: Marker2D = $"../Sprites/Upper/Muzzle"
@onready var upper_body: AnimatedSprite2D = $"../Sprites/Upper"

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var dead : bool = false
var health : int
var max_health : int = 100
var bullets : int = 10
var max_bullets : int = 10
var reload_time : float = 3.0
var is_reloading : bool = false

signal is_dead
signal took_damage(damage: int, from_pos: Vector2)
signal shot
signal health_changed(health_val: int)


func _ready() -> void:
	health = max_health

## -- Shooting System -- ##

func shoot_bullet():
	if is_reloading:
		return
		
	if bullets < 0:
		reload()
		return
	
	
	EventBus.bullets_changed.emit(bullets, is_reloading)
	var direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	upper_body.play("shooting")
	SoundManager.play_sfx("gunshot")
	bullets -= 1
	shot.emit()
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.damage = randi_range(14, 25)
	bullet.fired_pos = global_position
	bullet.player = true
	bullet.global_position = muzzle.global_position
	bullet.direction = direction
	await upper_body.animation_finished
	upper_body.play("idle")

func reload():
	if is_reloading:
		return
	
	is_reloading = true
	EventBus.bullets_changed.emit(bullets, is_reloading)
	SoundManager.play_sfx("reload")
	await get_tree().create_timer(reload_time).timeout
	bullets = max_bullets
	is_reloading = false
	EventBus.bullets_changed.emit(bullets, is_reloading)


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
