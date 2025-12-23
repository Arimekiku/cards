@abstract
extends Node2D
class_name Card

signal hovered(card)
signal exited(card)
signal died(card)
signal drag_finished(card)

var data: CardData
var card_owner := Enums.CharacterType.PLAYER
var placed := false

@abstract func setup(card_data: CardData) -> void

@abstract func input_phase(event: InputEventMouseButton) -> void

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	exited.emit(self)
