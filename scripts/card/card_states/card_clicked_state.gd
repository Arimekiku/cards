class_name CardClickedState
extends CardBaseState

func enter() -> void:
	target.collision_detector.monitoring = true

func on_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	
	transition.emit(self, CardDragState)
