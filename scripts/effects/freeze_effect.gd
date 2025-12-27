extends CardEffect
class_name FreezeEffect

@export var target: String = "enemy_creature"

func resolve(context):
	if context == null:
		return
	print("freeze")

	if context.has_method("freeze"):
		context.freeze()
