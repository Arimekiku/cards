extends Node2D
class_name CardBoard

@export var game: Game
@export var graphics : Sprite2D
@export var board_owner := Enums.CharacterType.PLAYER
@export var max_minions := 7
@export var spacing := 160.0
@export var drop_radius := 200.0
@export var turn_manager: TurnManager
@export var deck: Deck

var minions: Array[Minion] = []

func _ready() -> void:
	turn_manager.turn_changed.connect(on_turn_started)
	if board_owner == Enums.CharacterType.PLAYER: return;
	
	var minion := game.create_minion("frost_frog")
	minion.minion_owner = Enums.CharacterType.ENEMY
	add_card(minion)
	var minion2 := game.create_minion("frost_frog")
	minion2.minion_owner = Enums.CharacterType.ENEMY
	add_card(minion2)
	var minion3 := game.create_minion("frost_frog")
	minion3.minion_owner = Enums.CharacterType.ENEMY
	add_card(minion3)

func add_card(minion: Minion) -> bool:
	if minions.size() >= max_minions:
		return false
	
	minions.append(minion)
	minion.died_event.connect(_on_card_died)
	var parent = minion.get_parent()
	if parent:
		parent.remove_child(minion)
	add_child(minion)
	layout()
	return true

func remove_card(minion: Minion) -> void:
	if minions.has(minion): minions.erase(minion)
	layout()

func layout() -> void:
	var count := minions.size()
	if count == 0:
		return
	
	var total_width = spacing * (count - 1)
	var start_x = -total_width / 2.0
	
	for i in count:
		var offset := minions[i].size / 2
		var target := Vector2(global_position.x + start_x + i * spacing, global_position.y)
		animate_minion(minions[i], target - offset)

func animate_minion(minion: Minion, target: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(minion, "global_position", target, 0.25)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)

func can_accept(minion: Minion) -> bool:
	if minion.card_owner != board_owner:
		return false
	
	return minions.size() < max_minions

func is_mouse_inside() -> bool:
	return global_position.distance_to(get_global_mouse_position()) < drop_radius

func update_highlight(card) -> void:
	if card == null:
		graphics.self_modulate = Color.WHITE
		return
	
	graphics.self_modulate = Color.GREEN if can_accept(card) else Color.RED

func _on_card_died(minion: Minion) -> void:
	remove_card(minion)
	deck.add_to_discard_pile(minion)

func on_turn_started(turn):
	if turn != board_owner:
		return

	for minion in minions:
		minion.has_attacked = false
