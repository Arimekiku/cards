extends Node2D
class_name CardBoard

enum Owner { PLAYER, ENEMY }

@export var game: Game
@export var graphics : Sprite2D
@export var board_owner := Owner.PLAYER
@export var max_cards := 7
@export var spacing := 160.0
@export var drop_radius := 200.0
@export var turn_manager: TurnManager

var cards: Array[Card] = []

func _ready() -> void:
	if board_owner == Owner.PLAYER:
		return;
	
	turn_manager.turn_changed.connect(on_turn_started)
	
	var card = game.create_card("frost_frog")
	card.card_owner = Owner.ENEMY
	add_card(card)
	var card2 = game.create_card("frost_frog")
	card2.card_owner = Owner.ENEMY
	add_card(card2)
	var card3 = game.create_card("frost_frog")
	card3.card_owner = Owner.ENEMY
	add_card(card3)

func add_card(card: Card) -> bool:
	if cards.size() >= max_cards:
		return false
	
	cards.append(card)
	card.died.connect(_on_card_died)
	var parent = card.get_parent()
	if parent:
		parent.remove_child(card)
	card.placed = true
	add_child(card)
	layout()
	return true

func remove_card(card: Card) -> void:
	if cards.has(card):
		cards.erase(card)
	layout()


func layout() -> void:
	var count := cards.size()
	if count == 0:
		return
	
	var total_width = spacing * (count - 1)
	var start_x = -total_width / 2.0
	
	for i in count:
		var target := Vector2(global_position.x + start_x + i * spacing, global_position.y)
		animate_card(cards[i], target)

func animate_card(card: Card, target: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", target, 0.25)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)

func can_accept(card: Card) -> bool:
	if card.card_owner != board_owner:
		return false
	if card.data.card_context.get_card_type() == CardContext.CardType.SPELL:
		return false
	
	return cards.size() < max_cards

func is_mouse_inside() -> bool:
	return global_position.distance_to(get_global_mouse_position()) < drop_radius

func update_highlight(card) -> void:
	if card == null:
		graphics.self_modulate = Color.WHITE
		return
	
	graphics.self_modulate = Color.GREEN if can_accept(card) else Color.RED

func _on_card_died(card: Card) -> void:
	remove_card(card)

func on_turn_started(turn):
	if turn == TurnManager.Turn.PLAYER and board_owner == owner.PLAYER:
		for card in cards:
			if card is MinionCard:
				card.has_attacked = false
