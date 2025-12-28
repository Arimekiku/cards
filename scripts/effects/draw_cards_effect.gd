extends CardEffect
class_name DrawCardsEffect

@export var amount: int = 1

func resolve(context) -> void:
	if context == null:
		return

	var game := context.get_tree().get_first_node_in_group("game") as Game
	if not game:
		return

	var owner_type: Enums.CharacterType

	if context is Minion:
		owner_type = context.minion_owner
	elif context is Card:
		owner_type = context.card_owner
	else:
		return

	var character := game.get_character(owner_type)
	if character == null:
		return

	for i in range(amount):
		character.draw_card(character.deck)
