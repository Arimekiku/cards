@abstract
extends Resource
class_name CardContext

@export var tribes: Array[String]
@export var keywords: Array[String]
@export var on_draw_effects: Array[CardEffect] = []

@abstract func get_card_type() -> Enums.CardType

func requires_target() -> bool:
	return false
