extends CharacterBody2D
class_name EnemyBase

signal enemy_died

var speed: float = 200
var chase_threshold: int = 1000
var retreat_threshold: int = 500
var movement_direction: Vector2 
var detection_range: float = 1000.0

var character: CharacterBase
@onready var muzzle: Marker2D = %Muzzle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var nav_timer: Timer = $NavTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var collision_shape: CollisionShape2D = $Area/CollisionShape



enum State { CHASE, RETREAT, IDLE, ACTION }
var current_state: State = State.IDLE
var health: int = 100

var dodge_direction: Vector2 = Vector2.ZERO
var change_dir_timer: float = 0.0
var shoot_timer: float = 0.0
var dist_to_player
var chase_timeout: float = 3.0

var strafe_direction : Vector2 = Vector2.ZERO
var strafe_timer : float = 0.0
var strafe_change_interval : float = 1.0

var dimention_change : bool = false

@export var bullet_scene: PackedScene
@onready var damage_label = preload("uid://c517qyr5kd11h")

@export var chase_speed: float = 200
@export var action_speed: float = 150
@export var retreat_speed: float = 200

var shake_amount = 10
var shake_time = 0.3
var shaking = false
var original_position: Vector2

@onready var lower_body: AnimatedSprite2D = $Sprites/Lower
@onready var upper_body: Sprite2D = $Sprites/Upper
@onready var sprites: Node2D = $Sprites

var color: String # either "blue" or "red"

var current_labels: Array[Label] = []
var last_damage_label: Label
var last_damage: int

func _ready() -> void:
	
	EventBus.switched_dimensions.connect(_on_dimentions_changed)
	
	chase_timer.wait_time = chase_timeout
	change_state(State.IDLE)
	
	await get_tree().create_timer(0.1).timeout
	update_health_bar()
	match color:
		"blue":
			sprites.modulate = Color.DODGER_BLUE
		"red":
			sprites.modulate = Color.RED

func _physics_process(delta: float) -> void:
	if not character:
		return
	animation()
	dist_to_player = global_position.distance_to(character.global_position)
	rotation = (character.global_position - global_position).angle()
	
	process_ai(delta)

##-- Health --##

func _on_area_2d_area_entered(area: Area2D) -> void:
	var bullet = area.get_parent() as Area2D
	if bullet and bullet.source == "player":
		take_damage(bullet.damage)

func take_damage(damage: int):
	health -= damage
	add_damage_label(damage)
	last_damage = damage
	animation_player.stop()
	animation_player.play("damage")
	damage_shake()
	
	if health <= 0:
		health = 0
		die()
	
	update_health_bar()

func die():
	collision_shape.set_deferred("disabled", true)
	animation_player.play("death_animation")
	await animation_player.animation_finished
	enemy_died.emit()
	queue_free()

func update_health_bar():
	health_bar.value = health

func add_damage_label(damage: int) -> void:
	var total_damage: int = damage
	
	if not current_labels.is_empty():
		var old_label = current_labels.pop_back()
		if is_instance_valid(old_label):
			total_damage += old_label.get("current_total_damage") if "current_total_damage" in old_label else old_label.text.to_int()
			old_label.queue_free()
	
	var new_damage_label = damage_label.instantiate() as Label
	new_damage_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	new_damage_label.add_theme_constant_override("outline_size", 10)
	new_damage_label.text = str(total_damage)
	new_damage_label.global_position = global_position - Vector2(0, 20)
	
	new_damage_label.set("current_total_damage", total_damage)
	
	current_labels.append(new_damage_label)
	get_tree().current_scene.call_deferred("add_child", new_damage_label)
	
	await new_damage_label.label_finished
	
	if is_instance_valid(new_damage_label):
		current_labels.erase(new_damage_label)

## -- AI -- ##

func process_ai(delta):
	match current_state:
		State.CHASE:
			state_chase(delta)
		State.RETREAT:
			state_retreat(delta)
		State.IDLE:
			state_idle(delta)
		State.ACTION:
			state_action(delta)

func change_state(new_state: State):
	current_state = new_state
	print(new_state)
	match current_state:
		State.CHASE:
			speed = chase_speed
		State.RETREAT:
			speed = retreat_speed
		State.ACTION:
			speed = action_speed
	




## -- States -- ##

func state_chase(delta):	
	go_to(character.global_position)
	pathfind(delta)
	
	if dist_to_player <= chase_threshold and can_see_player():
		change_state(State.ACTION)


func state_retreat(delta):
	
	var retreat_dir = (global_position - character.global_position).normalized()
	go_to(global_position + retreat_dir * 100)
	pathfind(delta)
	
	
	if dist_to_player >= retreat_threshold:
		change_state(State.ACTION)

func state_action(delta):
	 #Action state: dodge bullets by moving randomly and shoot
	
	shoot_timer -= delta
	
	if shoot_timer <= 0:
		shoot((global_position - character.global_position).normalized())
		shoot_timer = randf_range(2.0, 4.0)
	
	
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

func state_idle(delta):
	velocity = Vector2.ZERO
	
	
	if await can_see_player():
		change_state(State.CHASE)

## -- Utility Methods -- ##

func pathfind(delta):
	var next_point: Vector2 = navigation_agent.get_next_path_position()
	var dir: Vector2 = (next_point - global_position).normalized()
	var move_velocity = speed * dir
	velocity = velocity.lerp(move_velocity, 0.1)
	
	move_and_slide()

func go_to(pos: Vector2):
	navigation_agent.target_position = pos


func shoot(dir : Vector2):
	if !dimention_change:
		var bullet : Area2D = bullet_scene.instantiate()
		
		bullet.global_position = global_position
		
		var error = deg_to_rad(5)
		dir = dir.rotated(randf_range(-error, error))
		
		bullet.rotation = dir.angle()
		bullet.direction = -dir.normalized()
		bullet.player = false
		
		var bullets_root = get_parent()
		if bullets_root:
			bullets_root.add_child(bullet)
		else:
			print("Bullets Root not found")

func _on_dimentions_changed():
	dimention_change = true
	await get_tree().create_timer(0.5).timeout
	dimention_change = false
	

func can_see_player() -> bool:
	if dist_to_player <= detection_range and not has_wall_between(character):
		return true
	return false

func has_wall_between(target: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		target.global_position
	)
	query.collision_mask = 1
	query.exclude = [self, target]
	var result = space_state.intersect_ray(query)
	return !result.is_empty()

func damage_shake():
	if shaking: 
		return
	
	shaking = true
	original_position = sprites.position
	
	var t = get_tree().create_timer(shake_time)
	
	while t.time_left > 0:
		sprites.position = original_position + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		await get_tree().process_frame
	
	sprites.position = original_position
	shaking = false


func animation():
	if velocity == Vector2.ZERO:
		lower_body.play("idle")
	else:
		lower_body.play("walk")
