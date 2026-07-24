extends CanvasLayer

@onready var dimension_timer_label: Label = $DimensionTimerLabel
@onready var health_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	health_bar.value = 100
	EventBus.timer_updated.connect(_on_timer_updated)
	EventBus.health_changed.connect(health_changed)

func _on_timer_updated(time_left: float) -> void:
	dimension_timer_label.text = str(int(time_left + 1))

func health_changed(health):
	health_bar.value = health
