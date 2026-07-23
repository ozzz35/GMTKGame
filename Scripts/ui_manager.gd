extends CanvasLayer

@onready var dimension_timer_label: Label = $DimensionTimerLabel
@onready var bullets_label: Label = $Bullets

func _ready() -> void:
	EventBus.timer_updated.connect(_on_timer_updated)
	EventBus.bullets_changed.connect(_bullets_changed)
	bullets_label.text = "10"

func _on_timer_updated(time_left: float) -> void:
	dimension_timer_label.text = str(int(time_left + 1))

func _bullets_changed(bullets, is_reloading):
	if bullets > 0 and is_reloading == true:
		bullets_label.text = str(bullets)
	elif is_reloading == true:
		bullets_label.text = "Reloading"
	else:
		bullets_label.text = str(bullets)
