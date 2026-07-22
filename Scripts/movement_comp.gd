extends Node2D

@onready var base : CharacterBase = get_parent()

var speed : int = 700
var acceleration := 5000.0
var friction := 3000.0
var input_vector = Vector2.ZERO

var knockback_strength : int = 700
var knockback_friction : float = 4000.0
var knockback_velocity : Vector2 = Vector2.ZERO

var can_recieve_input : bool = true

func _physics_process(delta: float) -> void:
	if not can_recieve_input:
		return
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * knockback_friction)
	
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
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

func apply_knockback(dir: Vector2):
	knockback_velocity = dir.normalized() * knockback_strength

## Signals ##

func _on_shot(dir, phase):
	knockback_strength = 700 + 100 * phase
	apply_knockback(-dir)
