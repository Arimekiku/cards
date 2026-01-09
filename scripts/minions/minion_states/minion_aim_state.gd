class_name MinionAimState
extends MinionBaseState

var events: EventBus = ServiceLocator.get_service(EventBus)

func enter() -> void:
	if target.minion_owner == Enums.CharacterType.ENEMY:
		target.current_target = target.potential_targets[0]
		await target.get_tree().process_frame
		transition.emit(self, MinionAttackState)
		return
	
	target.scale = Vector2(1.15, 1.15)
	_highlight_enemies(Color.GREEN)
	events.minion_info_blocking_request.emit(true)
	events.target_selector_called_event.emit(target)

func exit() -> void:
	target.scale = Vector2.ONE
	
	_highlight_enemies(Color.WHITE)
	events.minion_info_blocking_request.emit(false)
	events.target_selector_discard_event.emit(target)

func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse"):
		transition.emit(self, MinionIdleState)
		return
	
	if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
		if target.potential_targets.is_empty():
			return
		
		var allowed := TargetResolver.resolve_attack_targets(target)
		var has_taunt := allowed.any(func(m): return m.is_in_group("taunt_minions"))
		
		var areas := target.potential_targets.filter(func(a):
			var m = a.get_parent()
			if not is_instance_valid(m):
				return false
			return m.is_in_group("taunt_minions") if has_taunt else true
		)
		
		if areas.is_empty():
			return
		
		var real_target = areas[0].get_parent()
		if not is_instance_valid(real_target):
			return
		
		var health_component: HealthComponent = real_target.health_component
		if health_component != null:
			if health_component.should_die():
				return
		
		target.current_target = real_target
		target.get_viewport().set_input_as_handled()
		transition.emit(self, MinionAttackState)

func _highlight_enemies(color: Color) -> void:
	var allowed := TargetResolver.resolve_attack_targets(target)
	var has_taunt := allowed.any(func(m): return m.is_in_group("taunt_minions"))
	
	for zone: CardBoard in target.get_tree().get_nodes_in_group("card_zones"):
		if zone.board_owner == Enums.CharacterType.PLAYER:
			continue
		
		for minion in zone.minions:
			if has_taunt:
				minion.modulate = color if minion.is_in_group("taunt_minions") else Color.DIM_GRAY
			else:
				minion.modulate = color
