class_name Hand
extends Control

@export_group("Logic")
@export var max_count := 8
@export var card_width := 140
@export var hand_y := 480

@export_group("Animation")
@export var hand_radius: float = 1000.0
@export var card_angle_spread: float = 5.0
@export var max_total_spread: float = 60.0
@export var animation_speed: float = 0.2

@export var deck: Deck

var input_enabled := true
var is_top_hand := false
var hand_center: Vector2 
var cards: Array[Card] = []

func init():
	var screen_size = get_viewport_rect().size
	if deck.owned == Enums.CharacterType.ENEMY: 
		is_top_hand = true
		input_enabled = false
	
	if is_top_hand:
		hand_center = Vector2(
			screen_size.x / 2,
			-hand_radius + 100
		)
	else:
		hand_center = Vector2(
			screen_size.x / 2,
			screen_size.y + hand_radius - 100
		)

func add_card(card: Card) -> void:
	if cards.size() >= max_count: return
	
	cards.append(card)
	add_child(card)
	card.parent = self
	card.resolve_on_draw()
	update_hand_visuals()
	_connect_card_signals(card)

func remove_card(card: Card) -> void:
	cards.erase(card)
	update_hand_visuals()

func update_hand_visuals():
	var card_count = cards.size()
	if card_count == 0: return

	var current_spread = min(card_count * card_angle_spread, max_total_spread)
	var angle_step = 0
	if card_count > 1: angle_step = deg_to_rad(current_spread) / (card_count - 1)
	
	var base_angle = deg_to_rad(-90)
	if is_top_hand:
		base_angle = deg_to_rad(90)

	var start_angle = base_angle - (deg_to_rad(current_spread) / 2)

	for i in range(card_count):
		var card = cards[i]
		var current_angle = start_angle + (angle_step * i)
		var target_pos = Vector2(
			hand_center.x + hand_radius * cos(current_angle),
			hand_center.y + hand_radius * sin(current_angle)
		)
		var target_rotation = current_angle + (PI/2 if not is_top_hand else -PI/2)
		
		_animate_card_to_position(card, target_pos, target_rotation)

func _animate_card_to_position(card, target_pos, target_rot):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "global_position", target_pos, animation_speed)
	tween.parallel().tween_property(card, "rotation", target_rot, animation_speed)

func _connect_card_signals(card: Card) -> void:
	card.reparent_event.connect(_on_reparent_event) 
	card.played_event.connect(_on_played_event)

func _on_reparent_event(card: Card) -> void:
	card.reparent(self)
	update_hand_visuals()

func _on_played_event(card: Card) -> void:
	remove_card(card)
	
	if card is SpellCard: deck.add_to_discard_pile(card)
	
	card.queue_free()
