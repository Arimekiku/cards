extends CardContext
class_name SpellContext

@export var description: String
@export var on_play_effects: Array[CardEffect]
@export var on_draw_effects: Array[CardEffect] = []

func get_card_type() -> Enums.CardType:
	return Enums.CardType.SPELL
	
func requires_target() -> bool:
	for effect in on_play_effects:
		if effect.requires_target():
			return true
	return false
