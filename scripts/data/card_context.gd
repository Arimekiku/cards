@abstract
extends Resource
class_name CardContext

var on_draw_effects: Array[CardEffect] = []

@abstract func get_card_type() -> Enums.CardType

func requires_target() -> bool:
	return false
