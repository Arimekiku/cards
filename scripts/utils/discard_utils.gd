class_name DiscardUtils

static func get_discard_count(context) -> int:
	var game := context.get_tree().get_first_node_in_group("game") as Game
	if not game:
		return 0

	var owner: Enums.CharacterType
	if context is Card:
		owner = context.card_owner
	elif context is Minion:
		owner = context.minion_owner
	else:
		return 0

	var character := game.get_character(owner)
	if not character:
		return 0

	return character.deck.discard_pile.size()
