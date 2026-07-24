extends CanvasLayer

@onready var dimension_timer_label: Label = $DimensionTimerLabel
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var bullets_left: Label = $BulletsLeft

func _ready() -> void:
	bullets_left.text = "10"
	health_bar.value = 100
	EventBus.timer_updated.connect(_on_timer_updated)
	EventBus.health_changed.connect(health_changed)
	EventBus.bullets_changed.connect(bullets_changed)

func _on_timer_updated(time_left: float) -> void:
	dimension_timer_label.text = str(int(time_left + 1))

func health_changed(health):
	health_bar.value = health

func bullets_changed(bullets, is_reloading):
	if is_reloading:
		bullets_left.text = "Reloading"
	else:
		bullets_left.text = str(bullets)
