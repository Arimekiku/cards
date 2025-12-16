@abstract
extends Node2D
class_name Card

signal _on_hover
signal _on_exit

var _placed: bool = false
var _effects: Array[CardEffect]

func _on_area_2d_mouse_entered() -> void:
	for effect in _effects:
		effect.apply(null)
	
	emit_signal("_on_hover", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("_on_exit", self)

@abstract func parse_card_data(data: CardData) -> void
