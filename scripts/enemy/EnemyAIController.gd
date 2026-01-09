extends Node
class_name EnemyAIController

@export var character: CharacterRuntime
@export var hand: Hand

const MIN_ATTACK_SCORE := 20

func play_turn() -> void:
	print("[AI] Turn start")
	await _play_cards_from_hand()
	await _attack_with_minions()

func _attack_with_minions() -> void:
	for minion in character.board.minions:
		if minion.has_attacked:
			continue
		var target = _select_target(minion)
		if target == null:
			continue
			
		var started = minion.request_attack(target)
		
		if not started:
			continue
		
		await get_tree().create_timer(0.75).timeout
	character.board.layout()

func _select_target(minion: Minion) -> Node:
	var best_target: Node = null
	var best_score := -INF

	var player_board: CardBoard = minion.get_tree().get_nodes_in_group("card_zones")[0]
	if player_board == null:
		return null

	# 1. Міньйони
	var taunts := player_board.minions.filter(
		func(m): return m.is_in_group("taunt_minions")
	)

	var possible_targets := taunts if taunts.size() > 0 else player_board.minions

	for target in possible_targets:
		var score := _score_attack_target(minion, target)
		if score > best_score:
			best_score = score
			best_target = target
	# 2. Face
	var face_score := _score_face_attack(minion)
	var hero = minion.get_tree().get_nodes_in_group("heroes")[0]
	
	# 3. Вибір
	if taunts.size() > 0:
		pass
	else:
		if face_score > best_score and face_score >= MIN_ATTACK_SCORE:
			return hero
	
	if best_score < MIN_ATTACK_SCORE:
		return null  # НЕ АТАКУЄМО
	
	return best_target

func _score_face_attack(attacker: Minion) -> float:
	var score := 0.0
	var attacked_hero : HeroFace= null
	var heroes = attacker.get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero.owned != Enums.CharacterType.ENEMY:
			attacked_hero = hero
	
	if attacked_hero.health_component.health <= attacker.damage:
		return 999999999
	# Бити в лице завжди корисно, якщо немає розмінів
	score += attacker.damage * 10
	# Якщо міньйон слабкий — не шкода
	score += max(0, 5 - attacker.health_component.health)
	return score


func _score_attack_target(attacker: Minion, target: Minion) -> float:
	var score := 0.0
	var target_health = target.health_component.health
	var attracker_health = target.health_component.health

	# Вбиваємо і виживаємо
	if attacker.damage >= target_health and target.damage < attracker_health:
		score += 100

	# Обидва помруть — менш бажано
	if attacker.damage >= target_health and target.damage >= attracker_health:
		score += 30

	# Ми помремо — погано
	if target.damage >= attracker_health and attacker.damage < target_health:
		score -= 50
		
	if target.is_in_group("taunt_minions"):
		score += 20
	# Цінність цілі
	score += target.damage * 2
	score += target_health
	#print(score)
	return score*5

func _select_spell_target(spell_card: SpellCard) -> Node:
	var best_target: Node = null
	var best_score := -INF

	var player_board: CardBoard = spell_card.get_tree().get_nodes_in_group("card_zones")[0]
	
	for minion in player_board.minions:
		var score := _score_spell_target(spell_card, minion)
		if score > best_score:
			best_score = score
			best_target = minion

	# Якщо міньйонів нема — б'ємо героя
	if best_target == null:
		var heroes = spell_card.get_tree().get_nodes_in_group("heroes")
		for hero in heroes:
			if hero.owned != spell_card.card_owner:
				return hero

	return best_target

func _score_spell_target(_spell_card: SpellCard, target: Minion) -> float:
	#var damage := spell_card.data.card_context.on_play_effects.value
	var damage := 6
	var score := 0.0

	# Добиваємо міньйона
	if damage >= target.health_component.health:
		score += 100

	# Чим сильніший міньйон — тим краще
	score += target.damage * 3
	score += target.health_component.health
	
	if target.is_in_group("taunt_minions"):
		score += 20
		
	return score

func _play_cards_from_hand() -> void:
	var mana = character.mana
	
	for card in hand.cards.duplicate():
		card.card_owner = Enums.CharacterType.ENEMY
		if card.data.cost > mana.current_mana:
			continue
		
		if card is MinionCard and not character.board._is_full():
			_play_minion_card(card)
		
		if card is SpellCard:
			var valid_target = _select_spell_target(card)
			if valid_target == null:
				continue
			_play_spell_card(card, valid_target)
		
		await get_tree().create_timer(0.75).timeout

func _play_minion_card(card: MinionCard) -> void:
	if not character.mana.spend(card.data.cost): return
	
	var minion = card.get_minion_instance()
	minion._set_owned(Enums.CharacterType.ENEMY)
	character.board.add_minion(minion)
	card.played_event.emit(card)
	hand.remove_card(card)

func _play_spell_card(card: SpellCard, target: Node) -> void:
	if not character.mana.spend(card.data.cost): return
	
	card.potential_targets.clear()
	card.potential_targets.append(target)
	card.play()
	character.hand.remove_card(card)
