extends Control

const MAIN = "uid://d3a1yipnafmhy"
@onready var audio_options: Control = $AudioOptions
@onready var scene_transition_rect: ColorRect = $SceneTransition
signal scene_transition_finished

var changing_scene: bool = false

func _ready() -> void:
	scene_transition("fade_in", 0.5)


func _on_play_button_pressed() -> void:
	if changing_scene: return
	
	changing_scene = true
	scene_transition("fade_out")
	SoundManager.switch_music("game", 0.5)
	await scene_transition_finished
	get_tree().change_scene_to_file(MAIN)


func _on_options_button_pressed() -> void:
	audio_options.visible = !audio_options.visible


func _on_quit_button_pressed() -> void:
	pass

func scene_transition(mode: String, duration: float = 1): #either fade_in or fade_out
	scene_transition_rect.show()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	
	match mode:
		"fade_in":
			scene_transition_rect.color = Color(0, 0, 0, 1)
			tween.tween_property(scene_transition_rect, "color", Color(0, 0, 0, 0), duration)
		"fade_out":
			scene_transition_rect.color = Color(0, 0, 0, 0)
			tween.tween_property(scene_transition_rect, "color", Color(0, 0, 0, 1), duration)
	
	await tween.finished
	
	scene_transition_finished.emit()
	tween.kill()
