extends CardEffect
class_name PrintEffect

@export var value: String

func resolve(_context) -> void:
	print(value)
