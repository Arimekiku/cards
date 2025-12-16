@abstract
extends Resource
class_name CardContext

@abstract func get_card_type() -> CardType

enum CardType {
	SPELL,
	MINION
}
