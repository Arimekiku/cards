extends CardEffect
class_name DamageEffect

@export var value: int

func resolve(context) -> void:
	if context is not MinionCard:
		printerr("Invalid spell context in DamageEffect")
		return
	
	context.take_damage(value)
