@abstract
extends Resource
class_name CardEffect

@export var target_type: Array[Enums.TargetType]
@export var target_group: Array[Enums.TargetGroup]

func requires_target() -> bool:
	return target_type.has(Enums.TargetType.TARGET)

@abstract func resolve(context) -> void
