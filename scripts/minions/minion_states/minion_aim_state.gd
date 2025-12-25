class_name MinionAimState
extends MinionBaseState

var events: EventBus = ServiceLocator.get_service(EventBus)

func enter() -> void:
	target.scale = Vector2(1.15, 1.15)

	_highlight_enemies(Color.GREEN)
	events.target_selector_called_event.emit(target)

func exit() -> void:
	target.scale = Vector2.ONE
	
	_highlight_enemies(Color.WHITE)
	events.target_selector_discard_event.emit(target)

func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse"):
		transition.emit(self, MinionIdleState)
		return
	
	if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
		target.get_viewport().set_input_as_handled()
		transition.emit(self, MinionAttackState)

func _highlight_enemies(color: Color) -> void:
	for in_zone: CardBoard in target.get_tree().get_nodes_in_group("card_zones"):
		if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
		
		for minion in in_zone.minions:
			minion.modulate = color
