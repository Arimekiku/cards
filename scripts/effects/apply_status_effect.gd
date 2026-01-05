extends CardEffect
class_name ApplyStatusEffect

@export var status: String
@export var duration: int = 1
@export var params: = {}

func resolve(context):
	if context == null:
		return
	var targets = TargetResolver.resolve(target, context)
	for t in targets:
		if t.has_method("add_status"):
			t.add_status(status, duration, params)
