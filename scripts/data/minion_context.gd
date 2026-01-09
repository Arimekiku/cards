extends CardContext
class_name MinionContext

@export_group("Stats")
@export var health: int
@export var damage: int

@export_group("Effects")
@export var on_play_effects: Array[CardEffect]
@export var on_attack_effects: Array[CardEffect]
@export var on_die_effects: Array[CardEffect]
@export var passive_effects: Array[CardEffect]
@export var on_turn_start_effects: Array[CardEffect]
@export var on_turn_end_effects: Array[CardEffect]

@export_group("Visual")
@export var portrait_zoom: float
@export var portrait_offset: Vector2

func get_card_type() -> Enums.CardType:
	return Enums.CardType.MINION

func requires_target() -> bool:
	for group in [
		on_play_effects,
		on_die_effects
	]:
		for effect in group:
			if effect.requires_target():
				return true
	return false
