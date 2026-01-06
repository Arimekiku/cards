extends CardEffect
class_name IncreaseFutureCopiesEffect

@export var attack: int = 0
@export var health: int = 0

var encounter: EncounterContext = ServiceLocator.get_service(EncounterContext)

func resolve(caster: Minion) -> void:
	if not caster or not caster.data:
		return
	
	var card_name = caster.data.name
	
	encounter.add_future_card_bonus(card_name, {
		"attack": attack,
		"health": health
	})
