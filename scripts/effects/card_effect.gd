@abstract
extends Resource
class_name CardEffect

@export var target: Enums.SpellTargetType = Enums.SpellTargetType.NO_TARGET

func requires_target() -> bool:
	return target in [
		Enums.SpellTargetType.TARGET,
		Enums.SpellTargetType.NON_HERO_TARGET,
		Enums.SpellTargetType.ENEMY_TARGET,
		Enums.SpellTargetType.ALLY_TARGET,
		Enums.SpellTargetType.HERO
	]
	
@abstract func resolve(context) -> void
