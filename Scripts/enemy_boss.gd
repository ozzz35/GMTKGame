extends EnemyBase
class_name EnemyBoss

## Boss'a özel yeni durumlar
enum BossAction { NONE, RADIAL_ATTACK, DASH, SUMMON }
var current_boss_action: BossAction = BossAction.NONE

@export_category("Boss Settings")
@export var minion_scene: PackedScene
@export var max_health: int = 500
@export var dash_speed: float = 600.0

@export_category("Burst Settings")
@export var burst_count: int = 8
@export var burst_fire_rate: float = 0.08
@export var spread_angle_deg: float = 8.0
var is_shooting_burst: bool = false

var special_attack_timer: float = 0.0
var special_attack_cooldown: float = 4.0

var is_phase_two: bool = false
var has_summoned_minions: bool = false
var is_performing_special: bool = false

func _ready() -> void:
	damage = randi_range(2, 7)
	super._ready()
	health = max_health
	update_health_bar()
	health_bar.max_value = health
	
	await get_tree().process_frame
	character = get_tree().get_first_node_in_group("character")

func _physics_process(delta: float) -> void:
	if not character:
		return
		
	if is_performing_special:
		animation()
		return

	super._physics_process(delta)
	
	if current_state == State.ACTION:
		special_attack_timer -= delta
		if special_attack_timer <= 0.0:
			trigger_random_special_attack()

## -- Action Stuff -- ##

func state_action(delta):
	shoot_timer -= delta
	
	if shoot_timer <= 0 and not is_shooting_burst and not is_performing_special:
		var dir = (global_position - character.global_position).normalized()
		fire_burst(dir)
		shoot_timer = randf_range(1.5, 3.0)
	
	strafe_timer += delta
	if strafe_timer >= strafe_change_interval:
		strafe_timer = 0.0
		var rand = randf()
		if rand < 0.4:
			strafe_direction = Vector2(1, 0).rotated(global_position.angle_to_point(character.global_position) + PI/2)
		elif rand < 0.9:
			strafe_direction = Vector2(1, 0).rotated(global_position.angle_to_point(character.global_position) - PI/2)
		else:
			strafe_direction = Vector2.ZERO
	
	if strafe_direction != Vector2.ZERO:
		var strafe_target = global_position + strafe_direction * 50
		go_to(strafe_target)
		pathfind(delta)
	else:
		velocity = Vector2.ZERO
	
	if dist_to_player <= retreat_threshold:
		change_state(State.RETREAT)
	
	if not await can_see_player():
		change_state(State.CHASE)

## Taramalı Ateş Etme Fonksiyonu
func fire_burst(dir: Vector2) -> void:
	is_shooting_burst = true
	damage = randi_range(2, 5)
	for i in range(burst_count):
		
		if not is_instance_valid(character) or is_performing_special:
			break
			
		var current_dir = (global_position - character.global_position).normalized()
		shoot(current_dir)
		
		await get_tree().create_timer(burst_fire_rate).timeout
		
	is_shooting_burst = false

func shoot(dir: Vector2):
	if !dimention_change and bullet_scene:
		var bullet: Area2D = bullet_scene.instantiate()
		var spawn_pos = muzzle.global_position if muzzle else global_position
		bullet.global_position = spawn_pos
		
		var error = deg_to_rad(spread_angle_deg)
		dir = dir.rotated(randf_range(-error, error))
		bullet.damage = damage
		bullet.rotation = dir.angle()
		bullet.direction = -dir.normalized()
		bullet.player = false
		
		var bullets_root = get_parent()
		if bullets_root:
			bullets_root.add_child(bullet)

## -- Damage and Phase Control -- ##

func take_damage(damage: int) -> void:
	super.take_damage(damage)
	
	if not is_phase_two and health <= (max_health / 2):
		enter_phase_two()

func enter_phase_two() -> void:
	is_phase_two = true
	
	chase_speed *= 1.3
	action_speed *= 1.2
	special_attack_cooldown = 2.5
	
	burst_count = 14 
	burst_fire_rate = 0.05
	spread_angle_deg = 12.0
	
	sprites.modulate = Color.DARK_RED
	
	if not has_summoned_minions:
		summon_minions()

## -- Special Attacks -- ##

func trigger_random_special_attack() -> void:
	special_attack_timer = special_attack_cooldown
	
	var attack_choice = randi() % 2
	match attack_choice:
		0:
			radial_bullet_spray()
		1:
			dash_towards_player()

func radial_bullet_spray() -> void:
	is_performing_special = true
	velocity = Vector2.ZERO
	
	var bullet_count: int = 18 if is_phase_two else 12
	var step: float = (2.0 * PI) / bullet_count
	
	for i in range(bullet_count):
		if bullet_scene:
			var bullet = bullet_scene.instantiate() as Area2D
			bullet.global_position = muzzle.global_position if muzzle else global_position
			
			var dir = Vector2.RIGHT.rotated(i * step)
			bullet.rotation = dir.angle()
			bullet.direction = dir
			bullet.player = false
			
			get_parent().add_child(bullet)
	
	await get_tree().create_timer(0.6).timeout
	is_performing_special = false

func dash_towards_player() -> void:
	is_performing_special = true
	
	var target_dir = (character.global_position - global_position).normalized()
	var dash_duration = 0.4
	var timer = 0.0
	
	while timer < dash_duration:
		velocity = target_dir * dash_speed
		move_and_slide()
		timer += get_physics_process_delta_time()
		await get_tree().process_frame
		
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.4).timeout
	is_performing_special = false

func summon_minions() -> void:
	if not minion_scene:
		return
	
	has_summoned_minions = true
	is_performing_special = true
	velocity = Vector2.ZERO
	
	for i in range(2):
		var minion = minion_scene.instantiate()
		var offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
		minion.global_position = global_position + offset
		
		
		minion.character = character
			
		get_parent().call_deferred("add_child", minion)
		
	await get_tree().create_timer(0.8).timeout
	is_performing_special = false
