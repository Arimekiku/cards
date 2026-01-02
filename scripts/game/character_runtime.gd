class_name CharacterRuntime
extends Node

@export var side: Enums.CharacterType
@export var game: Game
@export var start_hand_size = 5

@onready var deck: Deck = $deck
@onready var board: CardBoard = $board_player
@onready var mana: ManaController = $mana_controller
@onready var hand: Hand = $ui/hand
@onready var face: HeroFace = $hero_face
@onready var ai: EnemyAIController = $ai_controller

@export var turn_manager: TurnManager

@export var minion_card_scene: PackedScene
@export var spell_card_scene: PackedScene

#var metadata: DeckMetadata

func _ready():
	deck.owned = side
	board.board_owner = side
	board.game = game
	mana.owned = side
	hand.deck = deck
	face.owned = side
	
	face.init()
	board.init()
	hand.init()
	mana.update_label()
	deck.initialize_deck(game.player_deck_metadata)
	draw_start_hand()
	
	if side == Enums.CharacterType.ENEMY:
		hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#$ui.hide()
		$hero_face.position = $hero_enemy_place.position
	
	turn_manager.turn_changed.connect(_on_turn_started)

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
	card.set_side(
		Enums.CardSide.FRONT if side == Enums.CharacterType.PLAYER\
		else Enums.CardSide.BACK
	)
	
	hand.add_card(card)

func draw_card_with_filter(_deck: Deck, predicate: Callable) -> void:
	var data: CardData = _deck.draw_with_filter(predicate)

	if data == null and not _deck.discard_pile.is_empty():
		_deck.reshuffle()
		data = _deck.draw_with_filter(predicate)

	if data == null:
		return

	var card: Card = create_card_from_data(data)
	hand.add_card(card)

func _on_turn_started(current_turn):
	board._on_turn_started(current_turn)
	mana._on_turn_started(current_turn)
	
	if current_turn == side:
		for i in range(2):
			draw_card(deck)
	
	if side == Enums.CharacterType.ENEMY and current_turn == side:
		ai.play_turn()
		turn_manager.end_turn()
		
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
