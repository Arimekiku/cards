extends Node
class_name Deck

enum Owner { PLAYER, ENEMY }

@export var number_label: Label
@export var start_cards: DeckMetadata
@export var owned: Owner

var cards: Array[CardData] = []
var discard_pile: Array[CardData] = []

func initialize_deck(initial_cards: DeckMetadata) -> void:
	if initial_cards == null:
		initial_cards = start_cards
	
	for id in initial_cards.cards:
		var data = CardDatabase.get_from_registry(id)
		if data == null:
			push_error("Can't get requested card of type %s!" % id)
			continue
		
		cards.append(data)
	
	_update_label()

func draw_card() -> CardData:
	if cards.is_empty():
		return null
	
	var card: CardData = cards.pop_back()
	_update_label()
	return card

func _update_label() -> void:
	if number_label:
		number_label.text = str(cards.size())

func add_to_discard_pile(card):
	discard_pile.append(card)
	print(discard_pile)

func reshuffle():
	if cards.is_empty():
		discard_pile.shuffle()
		cards = discard_pile
		discard_pile = []
