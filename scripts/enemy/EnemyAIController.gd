extends Node
class_name EnemyAIController

@export var character: CharacterRuntime
@export var hand: Hand
@export var ai_profile: AIScoringProfile

func play_turn() -> void:
	if not ai_profile: return
	
	@warning_ignore("redundant_await")
	await ai_profile.play_turn(self, character)

func _attack_with_minions() -> void:
	for minion in character.board.minions:
		if minion.has_attacked:
			continue
		
		var target = _select_target(minion)
		if target == null:
			continue
		
		if minion.request_attack(target):
			await get_tree().create_timer(0.75).timeout
		
	character.board.layout()

func _select_target(minion: Minion) -> Node:
	var best_target: Node = null
	var best_score := -INF
	
	var player_board: CardBoard = minion.get_tree().get_nodes_in_group("card_zones")[0]
	if player_board == null:
		return null
	
	var taunts := player_board.minions.filter(
		func(m): return m.is_in_group("taunt_minions")
	)
	
	var possible_targets := taunts if taunts.size() > 0 else player_board.minions
	
	for target in possible_targets:
		var score := ai_profile.score_attack_target(minion, target)
		if score > best_score:
			best_score = score
			best_target = target
	
	if taunts.is_empty():
		var face_score := ai_profile.score_face_attack(minion)
		var hero := minion.get_tree().get_nodes_in_group("heroes")[0]
	
		if face_score > best_score and face_score >= ai_profile.min_attack_score:
			return hero
	
	if best_score < ai_profile.min_attack_score:
		return null
	
	return best_target

func _select_spell_target(spell_card: SpellCard) -> Node:
	var best_target: Node = null
	var best_score := -INF
	
	var player_board: CardBoard = spell_card.get_tree().get_nodes_in_group("card_zones")[0]
	
	for minion in player_board.minions:
		var score := ai_profile.score_spell_target(spell_card, minion)
		if score > best_score:
			best_score = score
			best_target = minion
	
	if best_target == null:
		var heroes = spell_card.get_tree().get_nodes_in_group("heroes")
		for hero in heroes:
			if hero.owned != spell_card.card_owner:
				return hero
	
	return best_target
