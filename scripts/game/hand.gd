extends Node2D
class_name Hand

@export_group("Logic")
@export var max_count := 8
@export var card_width := 140
@export var hand_y := 480

@export_group("Animation")
@export var hand_radius: float = 1000.0
@export var card_angle_spread: float = 5.0
@export var max_total_spread: float = 60.0
@export var animation_speed: float = 0.2

var hand_center: Vector2 
var cards: Array[Card] = []

func _ready():
	var screen_size = get_viewport_rect().size
	hand_center = Vector2(screen_size.x / 2, screen_size.y + hand_radius - 100)

func add_card(card: Card) -> void:
	if cards.size() >= max_count: return

	cards.append(card)
	add_child(card)
	update_hand_visuals()
	_connect_card_signals(card)

func remove_card(card: Card) -> void:
	cards.erase(card)
	remove_child(card)
	update_hand_visuals()
	_disconnect_card_signals(card)

func _connect_card_signals(card: Card) -> void:
	card.drag_finished.connect(_on_exit_signal)
	card.died.connect(remove_card)

func _disconnect_card_signals(card: Card) -> void:
	card.drag_finished.disconnect(_on_exit_signal)
	card.died.disconnect(remove_card)

func _on_exit_signal(card: Card) -> void:
	if (card.placed):
		return
	
	var index = cards.find(card)
	var card_count = cards.size()
	var current_spread = min(card_count * card_angle_spread, max_total_spread)
	var angle_step = deg_to_rad(current_spread) / (card_count - 1)
	var start_angle = deg_to_rad(-90) - (deg_to_rad(current_spread) / 2)
	var current_angle = start_angle + (angle_step * index)
	var target_pos = Vector2(
		hand_center.x + hand_radius * cos(current_angle),
		hand_center.y + hand_radius * sin(current_angle)
	)
	var target_rotation = current_angle + PI/2 
	
	animate_card_to_position(card, target_pos, target_rotation)

func update_hand_visuals():
	var card_count = cards.size()
	if card_count == 0: return

	var current_spread = min(card_count * card_angle_spread, max_total_spread)
	var angle_step = 0
	if card_count > 1: angle_step = deg_to_rad(current_spread) / (card_count - 1)
	
	var start_angle = deg_to_rad(-90) - (deg_to_rad(current_spread) / 2)

	for i in range(card_count):
		var card = cards[i]
		var current_angle = start_angle + (angle_step * i)
		var target_pos = Vector2(
			hand_center.x + hand_radius * cos(current_angle),
			hand_center.y + hand_radius * sin(current_angle)
		)
		var target_rotation = current_angle + PI/2 
		
		animate_card_to_position(card, target_pos, target_rotation)

func animate_card_to_position(card, target_pos, target_rot):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "global_position", target_pos, animation_speed)
	tween.parallel().tween_property(card, "rotation", target_rot, animation_speed)
