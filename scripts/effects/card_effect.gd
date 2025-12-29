@abstract
extends Resource
class_name CardEffect

@abstract func resolve(context) -> void

func requires_target() -> bool:
	return false
