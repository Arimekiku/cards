extends CardEffect
class_name TargetDamageEffect

@export var value: int = 1

func requires_target() -> bool:
	return true

func resolve(target):
	if target == null:
		push_warning("TargetDamageEffect: target is null")
		return

	if target.has_method("take_damage"):
		target.take_damage(value)
