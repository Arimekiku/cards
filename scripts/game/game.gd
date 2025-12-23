extends Node2D
class_name Game

@onready var deck := %deck
@onready var enemy_deck := %enemy_deck
@onready var hand := %hand
@onready var card_handler := %card_handler

@export var minion_card_scene: PackedScene
@export var spell_card_scene: PackedScene

@export var start_hand_size := 5

@export var turn_manager: TurnManager

var player_meta_cards: DeckMetadata

func initialize_game(deck_metadata: DeckMetadata) -> void:
	player_meta_cards = deck_metadata

func _ready() -> void:
	deck.initialize_deck(player_meta_cards)
	turn_manager.turn_changed.connect(on_turn_started)
	
	_init_start_hand()

func _init_start_hand() -> void:
	draw_start_hand()

func draw_start_hand() -> void:
	for i in range(start_hand_size):
		draw_card(deck)

func draw_card(_deck: Deck) -> void:
	var data: CardData = _deck.draw_card()
	if data == null and not _deck.discard_pile.is_empty():
		_deck.reshuffle()
		data = _deck.draw_card()
	elif data == null:
		return
	
	var card: Card = create_card_from_data(data)
	hand.add_card(card)

func create_card(value: String) -> Card:
	var data := CardDatabase.get_from_registry(value)
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

func create_minion(value: String) -> Minion:
	var data := CardDatabase.get_from_registry(value)
	if data == null or data.card_context.get_card_type() != CardContext.CardType.MINION:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	return create_minion_from_data(data)

static func create_minion_from_data(value: CardData) -> Minion:
	var temp_minion_scene := load("res://scenes/minion.tscn")
	
	var minion: Minion = temp_minion_scene.instantiate()
	minion.setup(value)
	return minion

func on_turn_started(current_turn):
	if current_turn == turn_manager.Turn.PLAYER:
		for i in range(2):
			draw_card(deck)
	else:
		print("enemy soslo")
		pass
