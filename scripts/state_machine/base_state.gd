@abstract
class_name BaseState

@warning_ignore("unused_signal")
signal transition(from: BaseState, to: Variant)

func enter() -> void:
	pass

func exit() -> void:
	pass

func get_state_script() -> Script:
	return get_script()

func can_transition_to(_state: Script) -> bool:
	return true
