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
	_connect_card_signals(card)
	_update_positions()

func remove_card(card: Card) -> void:
	cards.erase(card)
	remove_child(card)
	_disconnect_card_signals(card)
	_update_positions()

func _update_positions() -> void:
	for i in cards.size():
		var pos := _calculate_card_pos(i)
		_animate_card_pos(cards[i], pos)

func _connect_card_signals(card: Card) -> void:
	card.drag_finished.connect(_on_exit_signal)

func _disconnect_card_signals(card: Card) -> void:
	card.drag_finished.disconnect(_on_exit_signal)

func _on_exit_signal(card: Card) -> void:
	if (card.placed):
		return
	
	var index = cards.find(card)
	var pos = _calculate_card_pos(index)
	_animate_card_pos(card, pos)

func _animate_card_pos(card: Node2D, pos: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, 0.1)

func _calculate_card_pos(index: int) -> Vector2:
	var total_width = (cards.size() - 1) * card_width
	var center_screen_x = get_viewport_rect().size.x / 2
	
	var x_offset = center_screen_x + index * card_width - total_width / 2.
	var y_offset = hand_y
	return Vector2(x_offset, y_offset)
