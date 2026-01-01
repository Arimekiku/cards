extends CardEffect
class_name EraseTargetEffect

func resolve(context):
	if context == null:
		return
		
	var targets = TargetResolver.resolve(target, context)
	for t in targets:
		if t is Minion:
			t.die(Enums.DeathCause.ERASE)
