extends CardEffect
class_name TauntEffect

func resolve(context) -> void:
	print("add taunt")
	if context == null:
		return
	if context is Minion:
		context.add_status("taunt", -1)
