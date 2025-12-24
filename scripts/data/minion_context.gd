extends CardContext
class_name MinionContext

@export_group("Stats")
@export var health: int
@export var damage: int

@export_group("Effects")
@export var on_spawn_effects: Array[CardEffect]
@export var on_attack_effects: Array[CardEffect]
@export var on_die_effects: Array[CardEffect]

@export_group("Visual")
@export var portrait_zoom: float
@export var portrait_offset: Vector2

func get_card_type() -> Enums.CardType:
	return Enums.CardType.MINION
