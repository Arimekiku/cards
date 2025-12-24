class_name CardHandler
extends Node2D

const COLLISION_MASK_I := 4

@export var hand: Hand
@export var turn_manager: TurnManager

var selected_attacker: Minion

func _input(event) -> void:
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.pressed:
		var potential_minion = _ray_minion()
		if potential_minion == null: return
		
		if potential_minion is Minion:
			if potential_minion.has_attacked: return
			_handle_attack_click(potential_minion)
			return

func _ray_minion() -> Minion:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = COLLISION_MASK_I
	
	var r = space.intersect_point(q)
	if r.is_empty(): return null
	
	r.sort_custom(_sort_highest_z)
	return r[0].collider.get_parent()

func _handle_attack_click(minion: Minion) -> void:
	if selected_attacker == null:
		if minion.minion_owner != Enums.CharacterType.PLAYER: return
		
		selected_attacker = minion
		_highlight_attacker(minion)
		_highlight_enemies(Color.GREEN)
		return
	
	if minion.minion_owner == Enums.CharacterType.ENEMY:
		selected_attacker.attack(minion)
		_clear_attack_selection()
		_highlight_enemies(Color.WHITE)

func _highlight_enemies(color: Color) -> void:
	for in_zone: CardBoard in get_tree().get_nodes_in_group("card_zones"):
		if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
		
		for minion in in_zone.minions:
			minion.modulate = color

func _highlight_attacker(card: Minion) -> void:
	card.scale = Vector2(1.15, 1.15)
	card.z_index = 200

func _clear_attack_selection() -> void:
	if selected_attacker:
		selected_attacker.scale = Vector2.ONE
		selected_attacker.z_index = 1
	selected_attacker = null

func _sort_highest_z(a, b) -> bool:
	return a.collider.get_parent().z_index > b.collider.get_parent().z_index
