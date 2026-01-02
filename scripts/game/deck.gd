class_name Deck
extends Control

@export var number_label: Label
@export var discard_label: Label
@export var start_cards: DeckMetadata

var owned: Enums.CharacterType
var cards: Array[CardData] = []
var discard_pile: Array[CardData] = []
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

func initialize_deck(initial_cards: DeckMetadata) -> void:
	if initial_cards == null: initial_cards = start_cards
	
	for id in initial_cards.cards:
		var data = card_database.get_from_registry(id)
		if data == null:
			push_error("Can't get requested card of type %s!" % id)
			continue
		
		cards.append(data)
	
	_update_label()

func draw_card() -> CardData:
	if cards.is_empty(): return null
	
	var card: CardData = cards.pop_back()
	_update_label()
	return card
	
func draw_with_filter(predicate: Callable) -> CardData:
	for i in range(cards.size()):
		var card := cards[i]
		if predicate.call(card):
			cards.remove_at(i)
			_update_label()
			return card
	return null

func _update_label() -> void:
	if number_label: number_label.text = str(cards.size())
	if discard_label: discard_label.text = str(discard_pile.size())

func add_to_discard_pile(context):
	discard_pile.append(context.data)
	_update_label()

func reshuffle():
	if not cards.is_empty(): return
	
	discard_pile.shuffle()
	cards = discard_pile
	discard_pile = []
