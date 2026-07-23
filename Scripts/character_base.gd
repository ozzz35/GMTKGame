class_name CharacterBase extends CharacterBody2D

@onready var movement_comp: Node2D = $MovementComp
@onready var combat_comp: Node2D = $CombatComp

@onready var camera: Camera2D = $Camera

@onready var lower_body: AnimatedSprite2D = $Sprites/Lower
@onready var upper_body: Sprite2D = $Sprites/Upper

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		combat_comp.shoot_bullet()

func _ready() -> void:
	EventBus.switched_dimensions.connect(_on_dimension_changed)

func _physics_process(delta: float) -> void:
	animation()

func _on_dimension_changed():
	zoom_in_out_effect()

func zoom_in_out_effect():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property(camera, "zoom", Vector2(5.5, 5.5), 0.1)
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "zoom", Vector2(5, 5), 0.9).set_delay(0.07)

func animation():
	if velocity == Vector2.ZERO:
		lower_body.play("idle")
	else:
		lower_body.play("walk")
	var dir: Vector2 = (upper_body.global_position - get_global_mouse_position()).normalized()
	upper_body.rotation = dir.angle() + 80
	lower_body.rotation = dir.angle() + 80
