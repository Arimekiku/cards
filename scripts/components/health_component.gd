@icon("res://resources/icons/heart-2.png")
class_name HealthComponent
extends Node

@export_group("Logic")
@export var can_die: bool = true

@export_group("Graphics")
@export var health_label: Label

signal on_health_updated(value)
signal on_health_processed(value)

var health: int:
	get(): return _current_health
	set(v): _set_health(v)

var _current_health: int

func process_health() -> void:
	if not health_label:
		push_warning("Health can't be processed for this concrete instance")
		return
	
	health_label.text = str(_current_health)
	on_health_processed.emit(_current_health)

func should_die() -> bool:
	return can_die and _current_health <= 0

func _set_health(value: int) -> void:
	_current_health = value
	on_health_updated.emit(_current_health)
