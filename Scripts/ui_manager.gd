extends CanvasLayer

@onready var dimension_timer_label: Label = $DimensionTimerLabel

func _ready() -> void:
	EventBus.timer_updated.connect(_on_timer_updated)

func _on_timer_updated(time_left: float) -> void:
	dimension_timer_label.text = str(int(time_left + 1))
