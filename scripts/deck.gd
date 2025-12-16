extends Node2D

const COUNT = 36
const INITIAL = 5

@export var card_datas: Array[CardData]
@export var hand: Node2D
@export var card_handler: Node2D
@export var label: Label

var cards = []

func _ready() -> void:
	var minion_card_prefab = preload("res://scenes/cards/minion_card_prefab.tscn")
	var spell_card_prefab = preload("res://scenes/cards/spell_card_prefab.tscn")
	
	for i in range(COUNT):
		var data = card_datas.pick_random()
		var data_context = data.card_context
		var selected_card_prefab = minion_card_prefab if data_context.get_card_type() == data_context.CardType.MINION else spell_card_prefab
		
		var instance = selected_card_prefab.instantiate()
		instance.parse_card_data(data)
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
