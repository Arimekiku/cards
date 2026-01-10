@abstract
extends Resource
class_name CardContext

@export var tribes: Array[String]
@export var keywords: Array[String]
@export var on_draw_effects: Array[CardEffect] = []

@abstract func get_card_type() -> Enums.CardType

func get_card_tribes() -> Array[String]:
	return tribes
	
func get_card_keywords() -> Array[String]:
	return keywords

@abstract
func requires_target() -> bool
