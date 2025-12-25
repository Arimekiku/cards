extends CardEffect
class_name TargetDamageEffect

@export var value: int

var running = true
var events: EventBus = ServiceLocator.get_service(EventBus)

func resolve(context) -> void:
	_highlight_enemies(Color.GREEN, context)
	events.target_selector_called_event.emit(context)
	
	events.target_selector_resolved_event.connect(_stop)

func _stop(context) -> void:
	events.target_selector_resolved_event.disconnect(_stop)
	
	_highlight_enemies(Color.WHITE, context)
	events.target_selector_discard_event.emit(context)
	
	running = false
	context.take_damage(context.health / 2)

func _highlight_enemies(color: Color, context) -> void:
	for in_zone: CardBoard in context.get_tree().get_nodes_in_group("card_zones"):
		if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
		
		for minion in in_zone.minions:
			minion.modulate = color
