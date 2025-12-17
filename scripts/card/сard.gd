@abstract
extends Node2D
class_name Card

signal hovered(card)
signal exited(card)

var data: CardData
var placed := false

@abstract func setup(card_data: CardData) -> void

@abstract func input_phase(event: InputEventMouseButton) -> void

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("exited", self)
