extends CardEffect
class_name TargetDamageEffect

@export var value: int = 1

func resolve(context):
	if context == null:
		return

	var targets = TargetResolver.resolve(target, context)
	for t in targets:
		if t.has_method("take_damage"):
			t.take_damage(value)
