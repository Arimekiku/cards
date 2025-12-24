extends CardContext
class_name MinionContext

@export var health: int
@export var damage: int

func get_card_type() -> Enums.CardType:
	return Enums.CardType.MINION
