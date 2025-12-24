extends CardContext
class_name SpellContext

@export var description: String

func get_card_type() -> Enums.CardType:
	return Enums.CardType.SPELL
