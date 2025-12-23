class_name CardReleasedState
extends CardBaseState

var played: bool

func enter() -> void:
	played = not target.potential_targets.is_empty()

func on_input(_event: InputEvent) -> void:
	if played: return
	transition.emit(self, CardIdleState)
