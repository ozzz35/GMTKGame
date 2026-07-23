extends Node

signal timer_updated(time_left: float)
signal level_completed(next_level_index: int)
signal level_load
signal bullets_changed(bullets, reloading)

signal switched_dimensions
