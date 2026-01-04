extends Button

@export var container_to_close: Node

func _pressed() -> void:
	container_to_close.hide()
