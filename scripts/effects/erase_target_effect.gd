extends CardEffect
class_name EraseTargetEffect

@export var value: int

var running = true
var events: EventBus = ServiceLocator.get_service(EventBus)

func resolve(_caster: Minion) -> void:
	#_highlight_enemies(Color.GREEN, caster)
	#events.target_selector_called_event.emit(caster)
	#
	#events.target_selector_resolved_event.connect(_stop)
	pass

func _stop(_context: Minion) -> void:
	#events.target_selector_resolved_event.disconnect(_stop)
	#
	#_highlight_enemies(Color.WHITE, context)
	#events.target_selector_discard_event.emit(context)
	#
	#running = false
	#context.take_damage(context.health)
	pass

#func _highlight_enemies(color: Color, context: Control) -> void:
	#for in_zone: CardBoard in context.get_tree().get_nodes_in_group("card_zones"):
		#if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
		#
		#for minion in in_zone.minions:
			#minion.modulate = color
