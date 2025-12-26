class_name CharacterRuntime
extends Node

@export var side: Enums.CharacterType
@export var game: Game

@onready var deck: Deck = $deck
@onready var board: CardBoard = $board_player
@onready var mana: ManaController = $mana_controller
@onready var hand: Hand = $ui/hand
@onready var face: HeroFace = $hero_face

@export var turn_manager: TurnManager

func _ready():
	deck.owned = side
	board.board_owner = side
	board.game = game
	mana.owned = side
	hand.deck = deck
	face.owned = side
	
	face.init()
	board.init()
	mana.update_label()
	
	turn_manager.turn_changed.connect(_on_turn_started)
	print(deck,123)

func _on_turn_started(current_turn):
	board._on_turn_started(current_turn)
	mana._on_turn_started(current_turn)
	pass
