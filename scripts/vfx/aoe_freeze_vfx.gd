extends Node2D
class_name AOEFreezeVFX

@export var duration := 1.0

func play_aoe(caster: Node) -> void:
	if caster.is_in_group("enemy_casters"):
		rotation = PI

	await get_tree().create_timer(duration).timeout
	queue_free()
