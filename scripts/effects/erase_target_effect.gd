extends CardEffect
class_name EraseTargetEffect

@export var value: int

var running = true

func resolve(caster: Minion) -> void:
	_highlight_enemies(Color.GREEN, caster)
	Events.target_selector_called_event.emit(caster)
	
	Events.target_selector_resolved_event.connect(_stop)

func _stop(context: Minion) -> void:
	Events.target_selector_resolved_event.disconnect(_stop)
	
	_highlight_enemies(Color.WHITE, context)
	Events.target_selector_discard_event.emit(context)
	
	running = false
	context.take_damage(context.health)

func _highlight_enemies(color: Color, context: Control) -> void:
	for in_zone: CardBoard in context.get_tree().get_nodes_in_group("card_zones"):
		if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
		
		for minion in in_zone.minions:
			minion.modulate = color
