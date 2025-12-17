extends Node2D
class_name CardZone

@export var max_cards := 7
@export var spacing := 160.0
@export var drop_radius := 200.0

var cards: Array[Card] = []

func add_card(card: Card) -> bool:
	if cards.size() >= max_cards:
		return false
	
	cards.append(card)
	card.get_parent().remove_child(card)
	card.placed = true
	add_child(card)
	layout()
	return true

func remove_card(card: Card) -> void:
	cards.erase(card)
	layout()

func layout() -> void:
	var count := cards.size()
	if count == 0:
		return
	
	var total_width = spacing * (count - 1)
	var start_x = -total_width / 2.0
	
	for i in count:
		var target := Vector2(start_x + i * spacing, 0)
		animate_card(cards[i], target)

func animate_card(card: Card, target: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "position", target, 0.25)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)

func can_accept(card: Card) -> bool:
	if card.data.card_context.get_card_type() == CardContext.CardType.SPELL:
		return false
	
	return cards.size() < max_cards

func is_mouse_inside() -> bool:
	return global_position.distance_to(get_global_mouse_position()) < drop_radius
