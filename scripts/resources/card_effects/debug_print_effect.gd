extends CardEffect
class_name PrintEffect

@export var value: String

func apply(_context) -> void:
	print(value)
