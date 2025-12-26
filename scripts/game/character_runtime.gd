class_name CharacterRuntime
extends Node

@export var side: Enums.CharacterType
@export var game: Game

@onready var deck: Deck = $deck
@onready var board: CardBoard = $board_player
@onready var mana: ManaController = $mana_controller
@onready var hand: Hand = $ui/hand
@onready var face: HeroFace = $hero_face
@onready var ai: EnemyAIController = $ai_controller


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
	
	if side == Enums.CharacterType.ENEMY:
		$ui.hide()
	
	turn_manager.turn_changed.connect(_on_turn_started)

func _on_turn_started(current_turn):
	board._on_turn_started(current_turn)
	mana._on_turn_started(current_turn)
	
	if side == Enums.CharacterType.ENEMY and current_turn == side:
		ai.play_turn()
		turn_manager.end_turn()
