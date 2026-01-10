class_name TargetResolver

static func resolve(
	target_types: Array[Enums.TargetType],
	target_groups: Array[Enums.TargetGroup],
	context
) -> Array:
	if context == null: return []
	
	var potential_targets: Array = []
	for target_type in target_types:
		match target_type:
			Enums.TargetType.NO_TARGET:
				push_warning("Trying to get heroes from NO_GROUP")
			Enums.TargetType.TARGET:
				potential_targets.append(context)
			Enums.TargetType.SELF:
				potential_targets.append(context)
			Enums.TargetType.MINIONS:
				potential_targets.append_array(_get_minions_from_groups(target_groups, context))
			Enums.TargetType.FACE:
				potential_targets.append_array(_get_heroes_from_groups(target_groups, context))
			Enums.TargetType.RANDOM:
				potential_targets.append_array(_get_random_from_groups(target_groups, context))
	
	return potential_targets

static func _get_heroes_from_groups(groups: Array[Enums.TargetGroup], ctx) -> Array[HeroFace]:
	var result: Array[HeroFace]
	var heroes: Array = ServiceLocator.get_tree().get_nodes_in_group("heroes")
	var owner := _figure_out_the_owner(ctx)
	
	if groups.has(Enums.TargetGroup.ALLY):
		var index = heroes.find_custom(
			func(h: HeroFace):
				return h.owned == owner
		)
		var hero: HeroFace = heroes[index]
		result.append(hero)
	
	if groups.has(Enums.TargetGroup.ENEMY):
		var index = heroes.find_custom(
			func(h: HeroFace):
				return h.owned != owner
		)
		var hero: HeroFace = heroes[index]
		result.append(hero)
	
	if groups.has(Enums.TargetGroup.FILTER):
		print("Should filter hero but not implemented")
	
	return result

static func _get_minions_from_groups(groups: Array[Enums.TargetGroup], ctx) -> Array[Minion]:
	var result: Array[Minion] = []
	var boards: Array = Engine.get_main_loop().get_nodes_in_group("card_zones")
	var owner := _figure_out_the_owner(ctx)
	
	if groups.has(Enums.TargetGroup.ALLY):
		var board_index = boards.find_custom(
			func(b: CardBoard):
				return b.board_owner == owner
		)
		var ally_board: CardBoard = boards[board_index]
		result.append_array(ally_board.minions)
	
	if groups.has(Enums.TargetGroup.ENEMY):
		var board_index = boards.find_custom(
			func(b: CardBoard):
				return b.board_owner != owner
		)
		var ally_board: CardBoard = boards[board_index]
		result.append_array(ally_board.minions)
	
	if groups.has(Enums.TargetGroup.FILTER):
		print("Should filter minion but not implemented")
	
	return result

static func _get_random_from_groups(groups: Array[Enums.TargetGroup], ctx) -> Array:
	var result: Array = []
	result.append_array(_get_heroes_from_groups(groups, ctx))
	result.append_array(_get_minions_from_groups(groups, ctx))
	
	return [result.pick_random()]

static func _figure_out_the_owner(ctx) -> Enums.CharacterType:
	var owner: Enums.CharacterType = Enums.CharacterType.PLAYER
	if ctx is Minion:
		owner = ctx.minion_owner
	elif ctx is Card:
		owner = ctx.card_owner
	
	return owner

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
