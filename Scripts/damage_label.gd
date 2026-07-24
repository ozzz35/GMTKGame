extends Label

signal label_finished(label_node)

func _ready() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5).set_delay(0.3)
	tween.tween_property(self, "position:y", global_position.y - 80, 1.0).set_delay(0.4)
	
	await tween.finished
	
	label_finished.emit(self)
	
	await get_tree().process_frame
	
	queue_free()
