extends Node2D
class_name Hand

const MAX_COUNT = 8
const CARD_WIDTH = 142
const HAND_Y = 480

var hand = []

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func connect_card_signals(card: Node2D) -> void:
	card.connect("_on_exit", on_exit_signal)

func add_card_to_hand(card: Node2D) -> void: 
	hand.append(card)
	add_child(card)
	
	update_hand_position()

func remove_card_from_hand(card: Node2D) -> void:
	hand.erase(card)
	remove_child(card)
	
	update_hand_position()

func update_hand_position() -> void:
	for i in range(hand.size()):
		var total_width = (hand.size() - 1) * CARD_WIDTH
		var center_screen_x = get_viewport_rect().size.x / 2
		var x_offset = center_screen_x + i * CARD_WIDTH - total_width / 2.
		var y_offset = HAND_Y
		
		var pos = Vector2(x_offset, y_offset)
		animate_card_pos(hand[i], pos)

func animate_card_pos(card: Node2D, pos: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, 0.1)

func on_exit_signal(card: Node2D) -> void:
	if (card._placed):
		return
	
	var index = hand.find(card)
	var pos = calculate_card_pos(index)
	animate_card_pos(card, pos)

func calculate_card_pos(index: int) -> Vector2:
	var total_width = (hand.size() - 1) * CARD_WIDTH
	var center_screen_x = get_viewport_rect().size.x / 2
	
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2.
	var y_offset = HAND_Y
	return Vector2(x_offset, y_offset)
