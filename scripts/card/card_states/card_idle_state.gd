class_name CardIdleState
extends CardBaseState

func enter() -> void:
	if not target.is_node_ready(): await target.ready
	if target.tween: target.tween.kill()
	target.reparent_event.emit(target)

func on_gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("left_mouse"): return
	
	target.pivot_offset = target.get_global_mouse_position() - target.global_position
	transition.emit(self, CardClickedState)

func on_mouse_enter() -> void:
	target.scale = Vector2.ONE * 1.05
	target.z_index = 100

func on_mouse_exit() -> void:
	_normalize()

func _normalize() -> void:
	target.scale = Vector2.ONE
	target.z_index = 1
