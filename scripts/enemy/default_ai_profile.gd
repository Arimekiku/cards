class_name DefaultAIProfile
extends AIScoringProfile

func play_turn(controller: Node, character: CharacterRuntime) -> void:
	await _play_cards_from_hand(controller, character)
	await _attack_with_minions(controller, character)

func _play_cards_from_hand(controller: Node, character: CharacterRuntime) -> void:
	var hand = character.hand
	var mana = character.mana
	
	for card in hand.cards.duplicate():
		card.card_owner = Enums.CharacterType.ENEMY
		if card.data.cost > mana.current_mana:
			continue
		
		if card is MinionCard and not character.board._is_full():
			if not character.mana.spend(card.data.cost):
				continue
		
			var minion = card.get_minion_instance()
			minion._set_owned(Enums.CharacterType.ENEMY)
			character.board.add_minion(minion)
			card.played_event.emit(card)
			hand.remove_card(card)
		
		elif card is SpellCard:
			var target = controller._select_spell_target(card)
			if target:
				if not character.mana.spend(card.data.cost):
					continue
				card.potential_targets.clear()
				card.potential_targets.append(target)
				card.play()
				hand.remove_card(card)
		
		await controller.get_tree().create_timer(0.5).timeout

func _attack_with_minions(controller: Node, character: CharacterRuntime) -> void:
	for minion in character.board.minions:
		if minion.has_attacked:
			continue
		
		var target = controller._select_target(minion)
		if target == null:
			continue
		
		if minion.request_attack(target):
			# Затримка, щоб встиг виконатися анімації/VFX
			await controller.get_tree().create_timer(0.5).timeout
	
	character.board.layout()

func score_face_attack(attacker: Minion) -> float:
	var score := 0.0
	
	var heroes = attacker.get_tree().get_nodes_in_group("heroes")
	var attacked_hero: HeroFace = null
	for hero in heroes:
		if hero.owned != Enums.CharacterType.ENEMY:
			attacked_hero = hero
			break
	
	if attacked_hero == null:
		return 0
	
	if attacked_hero.health_component.health <= attacker.damage:
		return INF
	
	score += attacker.damage * 10
	score += max(0, 5 - attacker.health_component.health)
	return score

func score_attack_target(attacker: Minion, target: Minion) -> float:
	var score := 0.0
	
	var target_health := target.health_component.health
	var attacker_health := attacker.health_component.health
	
	if attacker.damage >= target_health and target.damage < attacker_health:
		score += 100
	
	if attacker.damage >= target_health and target.damage >= attacker_health:
		score += 30
	
	if target.damage >= attacker_health and attacker.damage < target_health:
		score -= 50
	
	if target.is_in_group("taunt_minions"):
		score += 20
	
	score += target.damage * 2
	score += target_health
	
	return score * 5

func score_spell_target(_spell: SpellCard, target: Minion) -> float:
	var damage := 6
	var score := 0.0

	if damage >= target.health_component.health:
		score += 100

	score += target.damage * 3
	score += target.health_component.health

	if target.is_in_group("taunt_minions"):
		score += 20

	return score
