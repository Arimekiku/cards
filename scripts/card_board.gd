class_name CardBoard
extends Node2D

var game: Game
@export var graphics : Sprite2D
var board_owner := Enums.CharacterType.PLAYER
@export var max_minions := 7
@export var spacing := 100.0
@export var drop_radius := 200.0
@export var deck: Deck

var minions: Array[Minion] = []

func init() -> void:
	if board_owner == Enums.CharacterType.PLAYER: return;
	
	var minion := game.create_minion_from_name("frost_frog")
	minion.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion)
	minion.add_status("taunt", 3)
	var minion2 := game.create_minion_from_name("frost_frog")
	minion2.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion2)
	minion2.add_status("freeze", 3)
	var minion3 := game.create_minion_from_name("frost_frog")
	minion3.minion_owner = Enums.CharacterType.ENEMY
	add_minion(minion3)
	minion3.add_status("freeze", 3)
	minion3.add_status("taunt", 3)

func add_minion(minion: Minion, index: int = 0) -> bool:
	if minions.size() >= max_minions: return false
	
	minions.insert(index, minion)
	if minion.get_parent(): minion.reparent(self)
	else: add_child(minion)
	minion.died_event.connect(_on_minion_died)
	
	var is_enemy = minion.minion_owner == Enums.CharacterType.ENEMY
	minion.collision_detector.set_collision_layer_value(3, is_enemy)
	minion.collision_detector.set_collision_layer_value(4, not is_enemy)
	minion.collision_detector.set_collision_mask_value(3, not is_enemy)
	minion.collision_detector.set_collision_mask_value(4, is_enemy)
	
	layout()
	return true

func make_place_for_index(index: int = 0) -> void:
	layout(index)

func get_insertion_index(cursor_pos_x: float) -> int:
	if minions.size() == 0: return 0
	
	for i in minions.size():
		var minion_x := minions[i].global_position.x
		if cursor_pos_x < minion_x: return i
	
	return minions.size()

func remove_minion(minion: Minion) -> void:
	minions.erase(minion)
	layout()

func layout(phantom: int = -666) -> void:
	var count := minions.size()
	if count == 0: return
	
	var total_width = spacing * (count - 1)
	if phantom >= 0: total_width += spacing
	var start_x = -total_width / 2.0
	
	var j = 0
	for minion in minions:
		if j == phantom: j += 1
		
		var offset := minion.size / 2
		var target := Vector2(global_position.x + start_x + j * spacing, global_position.y)
		_normalize_minion(minion, target - offset)
		
		j += 1

func can_accept(minion: Minion) -> bool:
	if minion.minion_owner != board_owner: return false
	return minions.size() < max_minions

func _on_turn_started(turn):
	if turn != board_owner: return
	for minion in minions:
		minion.has_attacked = false
		minion.on_turn_start()

func _normalize_minion(minion: Minion, target: Vector2) -> void:
	var tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(minion, "global_position", target, 0.15)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(minion, "scale", Vector2.ONE, 0.15)\
	.set_trans(Tween.TRANS_LINEAR)\
	.set_ease(Tween.EASE_IN)

func _on_minion_died(minion: Minion, cause: Enums.DeathCause) -> void:
	remove_minion(minion)
	
	match cause:
		Enums.DeathCause.NORMAL:
			deck.add_to_discard_pile(minion)
		Enums.DeathCause.ERASE:
			pass
	
	minion.queue_free()

func _is_full():
	return minions.size() >= max_minions

func spawn_minion_from_data(
	data: CardData,
	owned: Enums.CharacterType
) -> bool:
	if minions.size() >= max_minions:
		return false
	
	var minion := Game.create_minion()
	minion.setup(data, true)
	minion.minion_owner = owned
	
	add_minion(minion)
	
	return true
