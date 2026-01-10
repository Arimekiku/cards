class_name ArchiveSurvivalAIProfile
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
		
		# --- МІНЬЙОНИ ---
		if card is MinionCard and not character.board._is_full():
			if not character.mana.spend(card.data.cost):
				continue
			
			var minion = card.get_minion_instance()
			minion._set_owned(Enums.CharacterType.ENEMY)
			character.board.add_minion(minion)
			card.played_event.emit(card)
			hand.remove_card(card)
		
		# --- СПЕЛИ ---
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
			await controller.get_tree().create_timer(0.5).timeout
	
	character.board.layout()

func score_face_attack(attacker: Minion) -> float:
	var heroes = attacker.get_tree().get_nodes_in_group("heroes")
	var attacked_hero: HeroFace = null
	
	for hero in heroes:
		if hero.owned != Enums.CharacterType.ENEMY:
			attacked_hero = hero
			break
	
	if attacked_hero == null:
		return 0
	
	# lethal — завжди дозволено
	if attacked_hero.health_component.health <= attacker.damage:
		return 999999
	
	var score := 0.0
	
	# фейс — погано для цієї деки
	score += attacker.damage * 3
	score -= attacker.health_component.health * 2
	
	return score

func score_attack_target(attacker: Minion, target: Minion) -> float:
	var score := 0.0
	
	var target_health := target.health_component.health
	var attacker_health := attacker.health_component.health
	
	# ідеальний трейд
	if attacker.damage >= target_health and target.damage < attacker_health:
		score += 150
	
	# обмін 1-в-1 допустимий
	if attacker.damage >= target_health and target.damage >= attacker_health:
		score += 60
	
	# поганий трейд
	if target.damage >= attacker_health and attacker.damage < target_health:
		score -= 120
	
	# таунти — критично важливо знімати
	if target.is_in_group("taunt_minions"):
		score += 80
	
	# загроза від цілі
	score += target.damage * 4
	score += target_health * 2
	
	return score

func score_spell_target(spell: SpellCard, target: Minion) -> float:
	var score := 0.0
	
	# універсальний базовий контроль
	score += target.damage * 5
	score += target.health_component.health * 3
	
	# якщо спел добиває — дуже добре
	if spell.data.cost >= target.health_component.health:
		score += 120
	
	# таунти — пріоритет
	if target.is_in_group("taunt_minions"):
		score += 60
	
	return score
