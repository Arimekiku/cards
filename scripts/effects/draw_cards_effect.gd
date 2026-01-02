extends CardEffect
class_name DrawCardsEffect

@export var amount: int = 1
@export var filter = ""

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
		if filter!="":
			character.draw_card_with_filter(character.deck, func(c):
				if filter == "spell":
					return c.card_context.get_card_type() == Enums.CardType.SPELL
				elif filter == "minion":
					return c.card_context.get_card_type() == Enums.CardType.MINION
				elif filter in c.tribes:
					return true
				elif filter in c.keywords:
					return true
				return false
			)
		else:
			character.draw_card(character.deck)
