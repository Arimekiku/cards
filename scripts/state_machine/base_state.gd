@abstract
class_name BaseState

@warning_ignore("unused_signal")
signal transition(from: BaseState, to: Variant)

func enter() -> void:
	pass

func exit() -> void:
	pass
