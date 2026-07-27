extends Control

@onready var label: RichTextLabel = $CanvasLayer/RichTextLabel

var text_lines: Array[String] = [
	"Dead and dispersed over time and space",
	"I find myself fragmented on times of regret",
	"My future is ceased, the only thing left for me",
	"[font=res://Assets/fonts/HelpMe.ttf][color=red]Is to kill them all ,\n[font_size=200]again[/font_size][/color]"
]
var shaking: bool = true
var original_y: float
var wait_time_text_shown: float = 3

func _ready() -> void:
	randomize()
	original_y = label.position.y
	label.visible = false
	display_labels_sequence()

func display_labels_sequence() -> void:
	for line in text_lines:
		label.text = line
		label.visible = true
		await get_tree().create_timer(wait_time_text_shown).timeout #Zeit wo der text gezeigt wird
		label.visible = false
		await get_tree().create_timer(2.2 if label.text != text_lines[2] else 2.46 ).timeout #Zeit wo die animation läuft
	
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _process(_delta: float) -> void:
	label.position = Vector2(
		randf_range(-5.0, 5.0), 
		original_y + randf_range(-5.0, 5.0))
