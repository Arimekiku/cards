extends Node
class_name EnemyAIController

@export var character: CharacterRuntime
@export var hand: Hand

func play_turn() -> void:
	print("[AI] Turn start")
	print(hand.cards)
	_play_cards_from_hand() 
	_attack_with_minions()  


func _attack_with_minions() -> void:
	for minion in character.board.minions:
		if minion.has_attacked:
			continue

		var target = _select_target(minion)
		if target == null:
			continue

		minion.attack(target)
		minion.has_attacked = true

func _select_target(minion: Minion) -> Node:
	var board = minion.get_tree().get_nodes_in_group("card_zones")[0]
	if board == null:
		return null

	if board.minions.size() > 0:
		return board.minions[randi() % board.minions.size()]

	var hero = minion.get_tree().get_nodes_in_group("heroes")[0]
	return hero
	
func _select_spell_target(spell_card) -> Node:
	var player_board = spell_card.get_tree().get_nodes_in_group("card_zones")[0]
	#var enemy_board: CardBoard = null
	#for b in boards:
		#if b.board_owner != spell_card.card_owner:
			#enemy_board = b
			#break
	if player_board == null:
		return null

	# спершу ціль — міньйони ворога
	if player_board.minions.size() > 0:
		return player_board.minions[randi() % player_board.minions.size()]

	# якщо міньйонів немає — ціль герої
	var heroes = spell_card.get_tree().get_nodes_in_group("heroes")
	for hero in heroes:
		if hero.owned != spell_card.card_owner:
			return hero

	return null


func _play_cards_from_hand() -> void:
	var mana = character.mana

	for card in hand.cards.duplicate():
		card.card_owner = Enums.CharacterType.ENEMY
		if card.data.cost > mana.current_mana:
			continue
		
		if card is MinionCard:
			#if not character.board.can_accept(card.get_minion_instance()):
				#continue
			_play_minion_card(card)
		elif card is SpellCard:
			var valid_target = _select_spell_target(card)
			if valid_target == null:
				continue
			_play_spell_card(card, valid_target)

func _play_minion_card(card: MinionCard) -> void:
	if character.mana.spend(card.data.cost):
		var minion = card.get_minion_instance()
		character.board.add_minion(minion)
		card.played_event.emit(card)
		hand.remove_card(card)

func _play_spell_card(card: SpellCard, target: Node) -> void:
	if character.mana.spend(card.data.cost):
		card.potential_targets.clear()
		card.potential_targets.append(target)
		card.play()
		character.hand.remove_card(card)
