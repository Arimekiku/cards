extends CardEffect
class_name DiscoverAndSummonEffect

@export var tribe: String
@export var choices: int = 3

func resolve(context) -> void:
	if context == null:
		return

	var events: EventBus = ServiceLocator.get_service(EventBus)
	var game := context.get_tree().get_first_node_in_group("game") as Game

	var owner: Enums.CharacterType
	if context is Card:
		owner = context.card_owner
	elif context is Minion:
		owner = context.minion_owner
	else:
		return

	var character := game.get_character(owner)
	if character == null:
		return

	var picked := _pick_cards(character.deck.cards)
	if picked.is_empty():
		return
	
	if owner == Enums.CharacterType.ENEMY:
		_auto_pick_for_ai(context, picked, character)
		return

	var callback := Callable(self, "_on_discover_finished").bind(
		context,
		character
	)

	events.discover_finished.connect(callback)
	events.discover_requested.emit(context, picked)

func _auto_pick_for_ai(
	context,
	cards: Array[CardData],
	_character: CharacterRuntime
) -> void:
	var events: EventBus = ServiceLocator.get_service(EventBus)
	
	var selected = cards.pick_random()

	var timer = context.get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		events.discover_finished.emit(context, selected)
	)

func _on_discover_finished(
	ctx,
	selected: CardData,
	expected_ctx,
	character: CharacterRuntime
) -> void:
	if ctx != expected_ctx:
		return

	var events: EventBus = ServiceLocator.get_service(EventBus)
	events.discover_finished.disconnect(
		Callable(self, "_on_discover_finished").bind(expected_ctx, character)
	)

	_summon_selected(character, selected)


func _summon_selected(character: CharacterRuntime, data: CardData) -> void:
	if character.board._is_full():
		return

	character.board.spawn_minion_from_data(
		data,
		character.side
	)


func _pick_cards(deck: Array[CardData]) -> Array[CardData]:
	var result: Array[CardData] = []

	for data in deck:
		if data.card_context.get_card_type() != Enums.CardType.MINION:
			continue
		if tribe.is_empty() or tribe in data.tribes:
			result.append(data)

	result.shuffle()
	return result.slice(0, choices)
