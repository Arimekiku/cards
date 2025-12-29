@abstract
extends Resource
class_name CardContext

@abstract func get_card_type() -> Enums.CardType

func requires_target() -> bool:
	return false
