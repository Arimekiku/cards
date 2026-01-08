extends Service
class_name VFXService

signal effect_finished(target)

@export var free_vfx := {
	"fireball": preload("res://scenes/vfx/spells/fireball.tscn")
}

func init():
	pass

func play(effect_id: String, target: Node) -> void:
	if not target:
		emit_signal("effect_finished", target)
		return

	if target.has_node("vfx"):
		var host := target.get_node("vfx")
		if host is VFXHost:
			await host.play_and_wait(effect_id)
			emit_signal("effect_finished", target)
			return

	emit_signal("effect_finished", target)

func play_free(effect_id: String, caster: Node, target: Node, parent: Node) -> Node2D:
	if not free_vfx.has(effect_id):
		return null

	var vfx_instance = free_vfx[effect_id].instantiate() as Node2D
	parent.add_child(vfx_instance)

	if caster.has_node("vfx"):
		vfx_instance.global_position = caster.get_node("vfx").global_position
	else:
		vfx_instance.global_position = caster.global_position

	if vfx_instance.has_method("play"):
		vfx_instance.play(target)

	return vfx_instance
