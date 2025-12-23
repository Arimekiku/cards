class_name CardDragState
extends CardBaseState

func enter() -> void:
	var ui_control := target.get_tree().get_first_node_in_group("battle_ui_layer")
	if not ui_control: return
	
	target.rotation = 0
	target.reparent(ui_control)

func on_input(event: InputEvent) -> void:
	var motion := event is InputEventMouseMotion
	var is_spell := target is SpellCard
	if is_spell and motion and target.potential_targets.size() > 0:
		transition.emit(self, CardAimState)
		return
	
	if motion:
		var relative_mouse = target.get_global_mouse_position()
		target.global_position = relative_mouse - target.pivot_offset
	
	var cancel = event.is_action_pressed("right_mouse")
	if cancel:
		transition.emit(self, CardIdleState)
		return
	
	var confirm = event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse")
	if confirm:
		target.get_viewport().set_input_as_handled()
		transition.emit(self, CardReleasedState)
