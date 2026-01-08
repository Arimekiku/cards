extends Node2D
class_name VFXHost

@export var effects := {
	"impact": NodePath("impact"),
	"erase": NodePath("erase"),
	"death": NodePath("death")
}

func play_and_wait(effect_id: String) -> void:
	if not effects.has(effect_id):
		return

	var container := get_node_or_null(effects[effect_id])
	if container is VFXContainer:
		await container.play_and_wait()
