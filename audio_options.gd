extends Control

func _on_master_slider_value_changed(value: float) -> void:
	SoundManager.set_bus_volume("Master", value)


func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_bus_volume("Music", value)


func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_bus_volume("SFX", value)
