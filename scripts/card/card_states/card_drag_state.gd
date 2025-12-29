class_name CardDragState
extends CardBaseState

func enter() -> void:
	var ui_control := target.get_tree().get_first_node_in_group("battle_ui_layer")
	if not ui_control: return
	
	target.rotation = 0
	target.reparent(ui_control)
	
	# Configure collision detector for targeting
	target.collision_detector.set_collision_mask_value(3, true)  # Enemy layer

func on_input(event: InputEvent) -> void:
	if target.potential_targets.size() > 0:
		if _check_for_mana() == false: return
	
	var motion := event is InputEventMouseMotion
	if motion:
		var relative_mouse = target.get_global_mouse_position()
		target.global_position = relative_mouse - target.pivot_offset
	
	match target.get_script():
		SpellCard: _handle_spell(event)
		MinionCard: _handle_creature(event)

func _check_for_mana() -> bool:
	var game := target.get_tree().get_first_node_in_group("game") as Game
	var character := game.get_character(target.card_owner)
	
	if character.mana.current_mana < target.data.cost:
		if target.tween and target.tween.is_running(): return false
		
		target.modulate = Color.RED
		target.tween = target.create_tween()
		target.tween.tween_property(target, "global_position:x", 10.0, 0.05).as_relative()
		target.tween.tween_property(target, "global_position:x", -10.0, 0.05).as_relative()
		target.tween.set_loops(3)
		target.tween.finished.connect(
			func(): 
				target.modulate = Color.WHITE
				transition.emit(self, CardIdleState)
		)
		return false
	
	return true

func _handle_spell(event: InputEvent) -> void:
	if not target.requires_target():
		if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
			transition.emit(self, CardReleasedState)
		return

	if event is InputEventMouseMotion and not target.potential_targets.is_empty():
		transition.emit(self, CardAimState)

func _handle_creature(event: InputEvent) -> void:
	var cancel = event.is_action_pressed("right_mouse")
	if cancel:
		transition.emit(self, CardIdleState)
		return
	
	var confirm = event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse")
	if confirm:
		target.get_viewport().set_input_as_handled()
		transition.emit(self, CardReleasedState)
