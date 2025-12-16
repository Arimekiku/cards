extends Node2D

signal _on_hover
signal _on_exit

@export var _color_picker: Sprite2D

var _placed: bool = false

func _process(_delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("_on_hover", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("_on_exit", self)
