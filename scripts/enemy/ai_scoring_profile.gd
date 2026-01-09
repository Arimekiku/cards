@abstract
extends Resource
class_name AIScoringProfile

@export var min_attack_score := 20

@abstract
func play_turn(controller: Node, character: CharacterRuntime) -> void

@abstract
func score_attack_target(attacker: Minion, target: Minion) -> float

@abstract
func score_face_attack(attacker: Minion) -> float

@abstract
func score_spell_target(spell: SpellCard, target: Minion) -> float
