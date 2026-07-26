extends Control

@onready var main: Node2D = $"../.."

func _on_resume_button_pressed() -> void:
	main.pause_menu_on_off()


func _on_quit_button_pressed() -> void:
	main.quit_to_main_menu()
