class_name CharacterBase extends CharacterBody2D

@onready var movement_comp: Node2D = $MovementComp
@onready var combat_comp: Node2D = $CombatComp

@onready var camera: Camera2D = $Camera

@onready var lower_body: AnimatedSprite2D = $Sprites/Lower
@onready var upper_body: AnimatedSprite2D = $Sprites/Upper

var crosshair : CompressedTexture2D = preload("res://Assets/simple_crosshair.png")

func _input(event: InputEvent) -> void:
	get_tree().process_frame
	if Input.is_action_just_pressed("mouse_left"):
		combat_comp.shoot_shotgun(7, 40)
	
	if Input.is_action_just_pressed("dash"):
		movement_comp.dash()

func _ready() -> void:
	Input.set_custom_mouse_cursor(crosshair)
	EventBus.switched_dimensions.connect(_on_dimension_changed)

func _physics_process(delta: float) -> void:
	animation()

func _on_dimension_changed():
	camera.zoom_in_out_effect()

func animation():
	if velocity == Vector2.ZERO:
		lower_body.play("idle")
	else:
		lower_body.play("walk")
	var dir: Vector2 = (upper_body.global_position - get_global_mouse_position()).normalized()
	upper_body.rotation = dir.angle() + 80
	lower_body.rotation = dir.angle() + 80

func recieve_hit(damage, from_pos):
	combat_comp.take_hit(damage, from_pos)
