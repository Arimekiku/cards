@abstract
extends Resource
class_name CardContext

enum CardType { MINION, SPELL, NONE }

@abstract func get_card_type() -> CardType
