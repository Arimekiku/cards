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
