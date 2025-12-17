extends Node2D
class_name Hand

@export var max_count := 8
@export var card_width := 140
@export var hand_y := 480

var cards: Array[Card] = []

func add_card(card: Card) -> void:
	if cards.size() >= max_count:
		return

	cards.append(card)
	add_child(card)
	update_positions()

func remove_card(card: Card) -> void:
	cards.erase(card)
	remove_child(card)
	update_positions()

func update_positions() -> void:
	var total := (cards.size() - 1) * card_width
	var center := get_viewport_rect().size.x / 2

	for i in cards.size():
		var x := center + i * card_width - total / 2.
		cards[i].position = Vector2(x, hand_y)
