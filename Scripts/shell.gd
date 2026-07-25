extends RigidBody2D

@onready var timer: Timer = $FallingTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lifetime: Timer = $Lifetime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	lifetime.wait_time = randf_range(2.0, 7.0)
	timer.wait_time = randf_range(0.0, 0.5)
	timer.start()
	lifetime.start()

func _on_timer_timeout() -> void:
	animation_player.play("shell_falling")

func _on_lifetime_timeout() -> void:
	animation_player.play("shell_remove")
	await animation_player.animation_finished
	queue_free()
