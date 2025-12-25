class_name ManaController
extends Node

signal mana_changed(current: int, max: int)

var owned: Enums.CharacterType

@export var label: Label
@export var max_mana_cap := 20

var max_mana := 10
var current_mana := 10

func start_turn():
	if max_mana < max_mana_cap:
		max_mana += 1
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)

func can_pay(cost: int) -> bool:
	return current_mana >= cost

func spend(cost: int) -> bool:
	if not can_pay(cost):
		return false

	current_mana -= cost
	mana_changed.emit(current_mana, max_mana)
	update_label()
	return true
	
func _on_turn_started(turn):
	if turn == owned:
		start_turn()
		update_label()

func update_label():
	label.text = str(current_mana)+"/"+str(max_mana)
	return
