extends CardEffect
class_name DamageEffect

@export var value: int

func resolve(context) -> void:
	if context == null:
		return

	if context.has_method("take_damage"):
		context.take_damage(value)
