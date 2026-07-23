extends Area2D

var speed = 3000
var direction = Vector2(1, 0)
var player : bool = true

var shield_dmg : int = 5

var fired_pos : Vector2 = Vector2.ZERO

var damage: int = 10

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite

func _enter_tree() -> void:
	rotation = direction.angle()

func _ready() -> void:
	visible = false
	rotation = direction.angle()
	visible = true
	
	if player:
		sprite.modulate = Color.BLUE
	else:
		sprite.modulate = Color.DARK_RED

func _physics_process(delta: float) -> void:
	rotation = direction.angle()
	
	position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if not area.get_parent():
		return
	
	if player:
		if area.get_parent().is_in_group("enemy"):
			area.get_parent().recieve_hit(damage, global_position)
			
			queue_free()
	else:
		if area.get_parent().is_in_group("character"):
			$AnimationPlayer.play("bullet")
			area.get_parent().recieve_hit(damage, global_position)
			await $AnimationPlayer.animation_finished
			
			queue_free()
