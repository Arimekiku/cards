extends Resource
class_name CardContext

enum CardType { MINION, SPELL }

func get_card_type() -> CardType:
	return CardType.MINION
