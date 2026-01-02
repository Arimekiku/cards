class_name CardIdleState
extends CardBaseState

var cached_rotation: float

func enter() -> void:
	if not target.is_node_ready(): await target.ready
	
	_normalize()
	if target.tween: target.tween.kill()
	target.reparent_event.emit(target)
	target.collision_detector.monitoring = false
	target.potential_targets.clear()

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		_normalize()
		target.pivot_offset = target.get_global_mouse_position() - target.global_position
		transition.emit(self, CardClickedState)
		return

func on_mouse_enter() -> void:
	target.scale = Vector2.ONE * 2.
	target.z_index = 100
	
	cached_rotation = target.rotation
	target.rotation = 0

func on_mouse_exit() -> void:
	_normalize()
	target.rotation = cached_rotation

func _normalize() -> void:
	target.scale = Vector2.ONE
	target.z_index = 1
