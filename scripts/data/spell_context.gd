extends CardContext
class_name SpellContext

@export var description: String
@export var on_play_effects: Array[CardEffect]

func get_card_type() -> Enums.CardType:
	return Enums.CardType.SPELL

func requires_target() -> bool:
	for effect in on_play_effects:
		if not effect.requires_target():
			continue
		
		return true
	
	return false

func get_target_groups(filter: Enums.TargetType) -> Array[Enums.TargetGroup]:
	var filtered := on_play_effects.filter(
		func(e: CardEffect):
			return e.target_type.has(filter)
	)
	
	var map := filtered.map(
		func(f: CardEffect):
			return f.target_group
	)
	
	var target_groups: Array[Enums.TargetGroup] = []
	#TODO: kostil'
	target_groups.assign(map[0])
	return target_groups
