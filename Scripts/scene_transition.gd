extends Control

@onready var rect_1: ColorRect = $Rect1
@onready var rect_2: ColorRect = $Rect2
@onready var level_label: Label = $level_label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glitch_material: ShaderMaterial = level_label.material as ShaderMaterial

var shake_amount = 10
var shaking = false
var original_position: Vector2

signal loading_time
signal shake_finished
signal transition_finished
signal scene_not_visible

func _ready() -> void:
	glitch_off()
	EventBus.level_completed.connect(play)

func play(level: int):
	show()
	var start: bool = false
	
	if start:
		rect_1.modulate = Color(1, 1, 1, 1)
		rect_2.modulate = Color(1, 1, 1, 1)
		level_label.modulate = Color(1, 1, 1, 1)
		scene_not_visible.emit()
	
	level_label.text = "Level " + str(level)
	
	if not start:
		animation_player.play("level_transition_animations/transition_in")
		await animation_player.animation_finished
	
	damage_shake(2.5)
	
	await get_tree().create_timer(1.0).timeout
	
	glitch_on()
	await get_tree().create_timer(0.3).timeout
	level_label.text = "Level α"
	await get_tree().create_timer(0.2).timeout
	glitch_off()
	
	
	await shake_finished
	animation_player.play("level_transition_animations/transition_out")
	EventBus.level_load.emit()
	await animation_player.animation_finished
	transition_finished.emit()

func damage_shake(duration: float = 0.12):
	if shaking: 
		return
	
	shaking = true
	original_position = level_label.position
	
	var t = get_tree().create_timer(duration)
	
	while t.time_left > 0:
		level_label.position = original_position + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		await get_tree().process_frame
	
	level_label.position = original_position
	shake_finished.emit()
	shaking = false

func glitch_on() -> void:
	glitch_material.set_shader_parameter("enabled", true)

func glitch_off() -> void:
	glitch_material.set_shader_parameter("enabled", false)
