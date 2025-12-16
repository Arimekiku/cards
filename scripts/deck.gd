extends Node2D

const COUNT = 36
const INITIAL = 5

@export var hand: Node2D
@export var card_handler: Node2D
@export var label: Label

var cards = []

func _ready() -> void:
	var card = preload("res://scenes/card.tscn")
	
	for i in range(COUNT):
		var instance = card.instantiate()
		instance._color_picker.color_index = i
		instance.name = "card"
		
		add_card_to_deck(instance)
		label.text = str(cards.size())
	
	for i in range(INITIAL):
		var instance = remove_card_from_deck()
		
		card_handler.connect_card_signals(instance)
		hand.connect_card_signals(instance)
		hand.add_card_to_hand(instance)
		label.text = str(cards.size())

func _process(_delta: float) -> void:
	pass

func add_card_to_deck(card: Node2D) -> void:
	cards.push_front(card)
	add_child(card)

func remove_card_from_deck() -> Node2D:
	var card = cards.pop_front()
	remove_child(card)
	
	return card

func resupply_cards() -> void:
	var current_cards_num = hand.hand.size()
	
	for i in range(hand.MAX_COUNT - current_cards_num):
		var instance = remove_card_from_deck()
		
		card_handler.connect_card_signals(instance)
		hand.connect_card_signals(instance)
		hand.add_card_to_hand(instance)
	
	label.text = str(cards.size())

func _on_button_button_down() -> void:
	resupply_cards()
