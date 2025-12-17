extends Node2D
class_name Game

@export var deck: Deck
@export var hand: Hand
@export var card_handler: CardHandler

@export var minion_card_scene: PackedScene
@export var spell_card_scene: PackedScene

@export var start_hand_size := 5

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
	
	var card: Card
	match data.card_context.get_card_type():
		CardContext.CardType.MINION:
			card = minion_card_scene.instantiate() as Card
		CardContext.CardType.SPELL:
			card = spell_card_scene.instantiate() as Card
		_:
			push_warning("Unknown card type")
			return
	
	card.setup(data)
	card_handler.connect_card(card)
	hand.add_card(card)
