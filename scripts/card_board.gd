class_name CardBoard
extends Node2D

@export var game: Game
@export var graphics : Sprite2D
var board_owner := Enums.CharacterType.PLAYER
@export var max_minions := 7
@export var spacing := 160.0
@export var drop_radius := 200.0
@export var deck: Deck

var minions: Array[Minion] = []

func init() -> void:
	if board_owner == Enums.CharacterType.PLAYER: return;
	
	var minion := game.create_minion_from_name("frost_frog")
	minion.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion)
	var minion2 := game.create_minion_from_name("frost_frog")
	minion2.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion2)
	var minion3 := game.create_minion_from_name("frost_frog")
	minion3.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion3)

func add_minion(minion: Minion) -> bool:
	if minions.size() >= max_minions: return false
	
	minions.append(minion)
	if minion.get_parent(): minion.reparent(self)
	else: add_child(minion)
	minion.position = Vector2.ZERO
	minion.died_event.connect(_on_minion_died)
	
	var is_enemy = minion.minion_owner == Enums.CharacterType.ENEMY
	minion.collision_detector.set_collision_layer_value(3, is_enemy)
	minion.collision_detector.set_collision_layer_value(4, not is_enemy)
	minion.collision_detector.set_collision_mask_value(3, not is_enemy)
	minion.collision_detector.set_collision_mask_value(4, is_enemy)
	
	layout()
	return true

func remove_minion(minion: Minion) -> void:
	minions.erase(minion)
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
		_normalize_minion(minions[i], target - offset)

func can_accept(minion: Minion) -> bool:
	if minion.minion_owner != board_owner: return false
	return minions.size() < max_minions

func _on_turn_started(turn):
	if turn != board_owner: return

	for minion in minions:
		minion.has_attacked = false

func _normalize_minion(minion: Minion, target: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(minion, "global_position", target, 0.25)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)

func _on_minion_died(minion: Minion) -> void:
	remove_minion(minion)
	deck.add_to_discard_pile(minion)
	minion.queue_free()
