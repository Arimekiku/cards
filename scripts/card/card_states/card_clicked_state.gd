class_name CardClickedState
extends CardBaseState

func enter() -> void:
	target.collision_detector.monitoring = true
	target.collision_detector.set_collision_mask_value(3, true)

func on_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	
	transition.emit(self, CardDragState)
