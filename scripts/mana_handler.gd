class_name ManaHandler
extends Node2D

@export var current_max_mana: int
@export var max_mana: int

static var current_mana: int
var mana_owner: Enums.Turn = Enums.Turn.PLAYER

func _ready() -> void:
	current_mana = current_max_mana
	Events.turn_changed_event.connect(_on_turn_change)
	
	print("Begin. Current max mana value: %d" % current_max_mana)

func _on_turn_change(value: Enums.Turn) -> void:
	if mana_owner != value: return
	if current_max_mana < max_mana: current_max_mana += 1
	current_mana = current_max_mana
	print("Turn change. Current max mana value: %d" % current_mana)
