class_name Hand
extends Control

@export_group("Logic")
@export var max_count := 8

@export_group("Animation")
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var card_angle_spread: float = 5.0
@export var animation_speed: float = 0.2
@export var x_separation_pixels: int = -10
@export var y_min_local: int = 0
@export var y_max_local: int = 30

@export_group("References")
@export var deck: Deck

var input_enabled := true
var is_top_hand := false
var cards: Array[Card] = []

func init():
	if deck.owned == Enums.CharacterType.ENEMY: 
		is_top_hand = true
		input_enabled = false
	
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM, true)
	if is_top_hand:
		set_anchors_preset(Control.PRESET_CENTER_TOP, true)
		rotation_degrees = 180
		position.y -= 50

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
	var cards_count := cards.size()
	
	var all_cards_size: float = 0
	for card in cards:
		var card_size = card.size
		all_cards_size += card_size.x
	var total_size := all_cards_size + x_separation_pixels * (cards_count - 1)
	
	var final_x_separation: float = x_separation_pixels
	if total_size > size.x:
		final_x_separation = (size.x - all_cards_size) / (cards_count - 1.)
		total_size = size.x
	
	var offset := (size.x - total_size) / 2.
	for i in cards_count:
		var card := cards[i]
		var y_multi := hand_curve.sample(1. / (cards_count - 1) * i)
		var rot_multi := rotation_curve.sample(1. / (cards_count - 1) * i)
		
		if cards_count == 1:
			y_multi = 0.
			rot_multi = 0.
		
		var final_x := offset + card.size.x * i + final_x_separation * i
		var final_y := y_min_local - y_max_local * y_multi
		var final_rot := card_angle_spread * rot_multi
		
		_animate_card_to_position(card, Vector2(final_x, final_y), final_rot)

func _animate_card_to_position(card: Card, target_pos: Vector2, target_rot: float):
	if card.tween: card.tween.kill()
	card.state_machine.active = false
	
	card.tween = create_tween()
	card.tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	card.tween.parallel().tween_property(card, "position", target_pos, animation_speed)
	card.tween.parallel().tween_property(card, "rotation_degrees", target_rot, animation_speed)
	card.tween.parallel().tween_property(card, "scale", Vector2.ONE, animation_speed)
	card.tween.finished.connect(
		func(): 
			#TODO: one more kostil' ooohhh yeahhhhh give me kostils'
			if card == null: return
			
			card.state_machine.active = true
	)

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
