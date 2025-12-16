extends CardContext
class_name SpellContext

@export var description: String

func get_card_type() -> CardType:
	return CardType.SPELL
