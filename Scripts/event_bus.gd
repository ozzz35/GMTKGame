extends Node

signal timer_updated(time_left: float)
signal level_completed(next_level_index: int)
signal level_load
signal health_changed(health)
signal bullets_changed(bullets, is_reloading)

signal switched_dimensions

signal boss_died
signal character_died
