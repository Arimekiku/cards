extends Node
class_name Deck

@export var number_label: Label
@export var database: CardDatabase
@export var start_cards := ["frost_frog", "fireball"]

var cards: Array[CardData] = []

func _ready():
	if database == null:
		database = get_parent().get_node_or_null("CardDatabase")

	if database == null:
		push_error("Deck: CardDatabase not found")
		return

	for id in start_cards:
		cards.append(database.cards[id])
	print(cards)
	_update_label()

	
func draw_card() -> CardData:
	if cards.is_empty():
		return null

	var card: CardData = cards.pop_back()
	_update_label()
	return card


func _update_label():
	if number_label:
		number_label.text = str(cards.size())
