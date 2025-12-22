extends Node
class_name Deck

@export var number_label: Label
@export var database: CardDatabase
@export var start_cards := ["frost_frog", "fireball", "fireball", "frost_frog", "fireball", "frost_frog", "fireball", "frost_frog", "fireball", "frost_frog"]

var cards: Array[CardData] = []

func _ready() -> void:
	if database == null:
		database = get_parent().get_node_or_null("CardDatabase")
	
	if database == null:
		push_error("Deck: CardDatabase not found")
		return

	for id in start_cards:
		cards.append(database.cards_registry[id])
	
	_update_label()

func draw_card() -> CardData:
	if cards.is_empty():
		return null
	
	var card: CardData = cards.pop_back()
	_update_label()
	return card

func _update_label() -> void:
	if number_label:
		number_label.text = str(cards.size())
