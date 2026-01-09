class_name TargetResolver

static func resolve(target_type: Enums.SpellTargetType, context) -> Array:
	if context == null: return []
	
	match target_type:
		Enums.SpellTargetType.TARGET:
			return [context]
		Enums.SpellTargetType.ENEMY_MINIONS:
			return _get_side_minions(context, false)
		Enums.SpellTargetType.ALLY_MINIONS:
			return _get_side_minions(context, true)
		Enums.SpellTargetType.HERO:
			return [_get_enemy_hero(context)]
		Enums.SpellTargetType.NON_HERO_TARGET:
			return _get_all_minions()
		Enums.SpellTargetType.ALL_MINIONS:
			return _get_all_minions()
		Enums.SpellTargetType.ALL:
			return _get_all_entities()
		Enums.SpellTargetType.SELF:
			return [context]
		_:
			push_warning("Unknown target_type: %s" % target_type)
			return []

static func _is_enemy(a, b) -> bool:
	return a.minion_owner != b.minion_owner
	
static func _get_side_minions(context, side: bool) -> Array:
	var boards = context.get_tree().get_nodes_in_group("card_zones")
	for board in boards:
		var owned = null
		
		if context is Minion:
			owned = context.minion_owner
		elif context is SpellCard:
			owned = context.card_owner
			
		if side:
			if board.board_owner == owned:
				return board.minions
		else:
			if board.board_owner != owned:
				return board.minions
	return []

static func _get_all_minions() -> Array:
	var result := []
	var boards = Engine.get_main_loop().get_nodes_in_group("card_zones")
	for board in boards:
		result.append_array(board.minions)
	return result

static func _get_enemy_hero(context):
	var heroes = context.get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero.character_type != context.minion_owner:
			return hero
	return null

static func _get_all_entities() -> Array:
	var result := []
	result.append_array(_get_all_minions())
	
	var heroes = Engine.get_main_loop().get_nodes_in_group("heroes")
	result.append_array(heroes)
	
	return result

static func resolve_attack_targets(attacker: Minion) -> Array[Minion]:
	var boards := attacker.get_tree().get_nodes_in_group("card_zones")
	var enemy_board = boards.filter(
		func(b): return b.board_owner != attacker.minion_owner
	)[0]

	var taunts: Array[Minion] = enemy_board.minions.filter(
		func(m): return m.is_in_group("taunt_minions")
	)

	if not taunts.is_empty():
		return taunts

	return enemy_board.minions
