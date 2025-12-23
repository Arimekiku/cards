class_name CardIdleState
extends CardBaseState

func enter() -> void:
	if not target.is_node_ready(): await target.ready
	target.reparent_event.emit(target)

func on_gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("left_mouse"): return
	target.pivot_offset = target.get_global_mouse_position() - target.global_position
	transition.emit(self, CardClickedState)
