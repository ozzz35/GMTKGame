class_name CharacterBase extends CharacterBody2D

@onready var movement_comp: Node2D = $MovementComp
@onready var combat_comp: Node2D = $CombatComp

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		var dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
		combat_comp.shoot_bullet(dir, global_position)
