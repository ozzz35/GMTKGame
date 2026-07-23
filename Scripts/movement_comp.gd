extends Node2D

@onready var base : CharacterBase = get_parent()

var speed : int = 200
var acceleration := 2000.0
var friction := 2000.0

var last_velocity: Vector2 = Vector2.ZERO

var dash_speed : int = 550
var dash_friction := 6000.0
var dash_duration: float = 0.02

@export var dash_cooldown := 0.3

var is_dashing := false
var invincible := false
var can_dash : bool = true

var input_vector = Vector2.ZERO

var knockback_strength : int = 700
var knockback_friction : float = 4000.0
var knockback_velocity : Vector2 = Vector2.ZERO

@onready var lower_body: AnimatedSprite2D = $"../Sprites/Lower"

var can_recieve_input : bool = true

func _physics_process(delta: float) -> void:
	if not can_recieve_input:
		return
	
	if is_dashing:
		base.move_and_slide()
		return
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * knockback_friction)
	
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	last_velocity = input_vector
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		base.velocity = base.velocity.move_toward(input_vector * speed, delta * acceleration)
	else:
		base.velocity = base.velocity.move_toward(Vector2.ZERO, delta * friction)
	
	
	
	var final_velocity = base.velocity + knockback_velocity
	
	var old_move_velocity = base.velocity
	base.velocity = final_velocity
	base.move_and_slide()
	base.velocity = old_move_velocity



func dash():
	if !can_dash:
		return
	
	var dash_direction = last_velocity.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = last_velocity
	
	can_dash = false
	is_dashing = true
	invincible = true
	
	var original_speed = speed
	var original_friction = friction
	speed = dash_speed
	friction = dash_friction
	base.velocity = dash_direction * dash_speed
	
	await get_tree().create_timer(dash_duration).timeout
	
	speed = original_speed
	is_dashing = false
	invincible = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	
	friction = original_friction
	
	can_dash = true



func apply_knockback(dir: Vector2):
	knockback_velocity = dir.normalized() * knockback_strength

## Signals ##

func _on_shot(dir, phase):
	knockback_strength = 700 + 100 * phase
	apply_knockback(-dir)
