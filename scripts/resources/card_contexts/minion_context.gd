extends CardContext
class_name MinionContext

@export var health: int
@export var damage: int

func get_card_type() -> CardType:
	return CardType.MINION
