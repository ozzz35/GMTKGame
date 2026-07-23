extends Node2D

@onready var base : CharacterBase = get_parent()

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var max_bullets : int = 10
var bullets_left : int = 10
var dead : bool = false
var health : int
var max_health : int = 100
var is_reloading : bool = false

signal is_dead
signal took_damage(damage: int, from_pos: Vector2)
signal shot
signal health_changed(health_val: int)


func _ready() -> void:
	randomize()
	health = max_health

## -- Shooting System -- ##

func shoot_bullet(direction, pos):
<<<<<<< Updated upstream
	shot.emit()
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.damage = randi_range(14, 25)
	bullet.fired_pos = global_position
	bullet.player = true
	bullet.global_position = pos
	bullet.direction = direction

=======
	if is_reloading:
		return
	
	if bullets_left > 0:
		bullets_left -= 1
		shot.emit()
		EventBus.bullets_changed.emit(bullets_left, is_reloading)
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.damage = randi_range(14, 25)
		bullet.fired_pos = global_position
		bullet.player = true
		bullet.global_position = muzzle.global_position
		bullet.direction = direction
	else:
		pass
		
func _process(delta: float) -> void:
	if bullets_left != 0 and is_reloading == false:
		pass
	else:
		await get_tree().root.window_input
		if Input.is_action_just_pressed("reload"):
			start_reloading()
>>>>>>> Stashed changes

func start_reloading():
	is_reloading = true
	EventBus.bullets_changed.emit(bullets_left, is_reloading)
	await get_tree().create_timer(2.0).timeout
	bullets_left = max_bullets
	is_reloading = false
	EventBus.bullets_changed.emit(bullets_left, is_reloading)
	
## -- Damage/Death System -- ##

func take_hit(damage : int, from_pos : Vector2):
	if not base.can_take_damage():
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
