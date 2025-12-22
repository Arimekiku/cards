extends Node2D
class_name Game

@export var deck: Deck
@export var hand: Hand
@export var card_handler: CardHandler

@export var minion_card_scene: PackedScene
@export var spell_card_scene: PackedScene

@export var start_hand_size := 5

func initialize_game(deck_metadata: DeckMetadata) -> void:
	deck.start_cards = deck_metadata

func _ready() -> void:
	_init_start_hand()

func _init_start_hand() -> void:
	draw_start_hand()

func draw_start_hand() -> void:
	for i in range(start_hand_size):
		draw_card()

func draw_card() -> void:
	var data := deck.draw_card()
	if data == null:
		return
	
	var card := create_card_from_data(data)
	card_handler.connect_card(card)
	hand.add_card(card)

func create_card(value: String) -> Card:
	var data = CardDatabase.get_from_registry(value)
	if data == null:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	return create_card_from_data(data)

func create_card_from_data(value: CardData) -> Card:
	var card: Card
	
	match value.card_context.get_card_type():
		CardContext.CardType.MINION:
			card = minion_card_scene.instantiate() as Card
		CardContext.CardType.SPELL:
			card = spell_card_scene.instantiate() as Card
		_:
			push_warning("Unknown card type")
			return null
	
	card.setup(value)
	return card
