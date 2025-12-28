class_name TargetResolver

static func resolve(target_type: String, context) -> Array:
	match target_type:
		"attack_target":
			return [context] if context != null else []
		"self":
			# context може бути міньйоном/картою/кастером
			return [context] if context != null else []
		"enemy_creature":
			# якщо context — міньйон, повернемо ворога (можна розширити)
			return [context] if context != null else []
		_:
			return []

static func resolve_attack_targets(attacker: Minion) -> Array[Minion]:
	var enemy_board := attacker.get_tree().get_nodes_in_group("card_zones")[0]

	var taunts: Array[Minion] = enemy_board.minions.filter(
		func(m): return m.is_in_group("taunt_minions")
	)

	if not taunts.is_empty():
		return taunts

	return enemy_board.minions
