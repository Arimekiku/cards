extends Node2D
class_name Game

@export var player: CharacterRuntime
@export var enemy: CharacterRuntime
@onready var hand := player.hand

@export var minion_card_scene: PackedScene
@export var spell_card_scene: PackedScene
@export var start_hand_size := 5
@export var turn_manager: TurnManager

var player_meta_cards: DeckMetadata
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

func initialize_game(deck_metadata: DeckMetadata) -> void:
	player_meta_cards = deck_metadata

func _ready() -> void:
	player.deck.initialize_deck(player_meta_cards)
	turn_manager.turn_changed.connect(on_turn_started)
	
	_init_start_hand()

func _init_start_hand() -> void:
	draw_start_hand()

func draw_start_hand() -> void:
	for i in range(start_hand_size):
		draw_card(player.deck)

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
	var data := card_database.get_from_registry(value)
	if data == null:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	return create_card_from_data(data)

func create_card_from_data(value: CardData) -> Card:
	var card: Card
	
	match value.card_context.get_card_type():
		Enums.CardType.MINION:
			card = minion_card_scene.instantiate() as Card
		Enums.CardType.SPELL:
			card = spell_card_scene.instantiate() as Card
		_:
			push_warning("Unknown card type")
			return null
	
	card.setup(value)
	return card

func create_minion_from_name(value: String) -> Minion:
	var data := card_database.get_from_registry(value)
	if data == null or data.card_context.get_card_type() != Enums.CardType.MINION:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	var minion = create_minion()
	minion.setup(data)
	return minion

static func create_minion() -> Minion:
	var temp_minion_scene := load("res://scenes/minion.tscn")
	
	var minion: Minion = temp_minion_scene.instantiate()
	return minion

func on_turn_started(current_turn: Enums.CharacterType) -> void:
	var character := get_character(current_turn)
	print(character)
	if current_turn == Enums.CharacterType.PLAYER:
		for i in range(2):
			draw_card(player.deck)

func get_character(character_type: Enums.CharacterType) -> CharacterRuntime:
	return player if character_type == Enums.CharacterType.PLAYER else enemy
