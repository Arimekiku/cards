class_name CharacterRuntime
extends Node

@export var side: Enums.CharacterType
@export var turn_manager: TurnManager
@export var player_meta_cards: DeckMetadata
@export var start_hand_size := 5
@export var hand: Hand

@onready var deck: Deck = $deck
@onready var board: CardBoard = $board_player
@onready var mana: ManaController = $mana_controller

var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

func init(cards_meta: DeckMetadata) -> void:
	player_meta_cards = cards_meta

func _ready():
	deck.owned = side
	board.board_owner = side
	mana.owned = side
	
	board.init()
	mana.update_label()
	
	turn_manager.turn_changed.connect(_on_turn_started)
	
	if not player_meta_cards: return
	deck.initialize_deck(player_meta_cards)
	print(deck, 123)
	_init_start_hand()

func _init_start_hand() -> void:
	draw_start_hand()

func draw_start_hand() -> void:
	for i in range(start_hand_size):
		draw_card(deck)

func draw_card(_deck: Deck) -> void:
	if hand == null: return
	
	var data: CardData = _deck.draw_card()
	if data == null and not _deck.discard_pile.is_empty():
		_deck.reshuffle()
		data = _deck.draw_card()
	elif data == null:
		return
	
	var card: Card = Game.create_card_from_data(data)
	hand.add_card(card)

func _on_turn_started(current_turn):
	board._on_turn_started(current_turn)
	mana._on_turn_started(current_turn)
	if current_turn != side: return
	
	for i in range(2):
		draw_card(deck)
