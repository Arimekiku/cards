extends Resource
class_name AIScoringProfile

@export var min_attack_score := 20

func play_turn(controller: Node, character: CharacterRuntime) -> void:
	pass

func score_attack_target(attacker: Minion, target: Minion) -> float:
	return 0.0

func score_face_attack(attacker: Minion) -> float:
	return 0.0

func score_spell_target(spell: SpellCard, target: Minion) -> float:
	return 0.0
