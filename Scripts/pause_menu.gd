extends Control

@onready var main: Node2D = $"../.."

func _on_resume_button_pressed() -> void:
	main.pause_menu_on_off()


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
