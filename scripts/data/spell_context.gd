extends CardContext
class_name SpellContext

@export var description: String
@export var on_play_effects: Array[CardEffect]

func get_card_type() -> Enums.CardType:
	return Enums.CardType.SPELL
