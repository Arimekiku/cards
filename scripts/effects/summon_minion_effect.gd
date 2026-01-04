extends CardEffect
class_name SummonMinionEffect

@export var minion_id: String
@export var amount: int = 1

func resolve(context) -> void:
	if context == null:
		return

	var game := context.get_tree().get_first_node_in_group("game") as Game
	if not game:
		return

	# визначаємо власника
	var owner_type: Enums.CharacterType
	if context is Card:
		owner_type = context.card_owner
	elif context is Minion:
		owner_type = context.minion_owner
	else:
		return

	var character := game.get_character(owner_type)
	if character == null:
		return

	var board := character.board
	if board == null:
		return

	for i in range(amount):
		if board._is_full():
			return

		var data = ServiceLocator.get_service(CardDatabase).get_from_registry(minion_id)
		if data == null:
			push_error("Summon failed, unknown minion_id: %s" % minion_id)
			return

		_summon_minion(character, data)

func _summon_minion(character: CharacterRuntime, data: CardData) -> void:
	character.board.spawn_minion_from_data(
		data,
		character.side
	)
