extends Node2D

signal _on_hover
signal _on_exit

func _ready() -> void:
	get_parent().connect_card_signals(self)

func _process(_delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	emit_signal("_on_hover", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("_on_exit", self)
