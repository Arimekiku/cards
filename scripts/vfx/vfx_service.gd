extends Service
class_name VFXService

signal effect_finished(target)

func init() -> void:
	pass

func play(effect_id: String, target: Node) -> void:
	if not target:
		emit_signal("effect_finished", target)
		return

	if target.has_node("vfx"):
		var host := target.get_node("vfx")
		if host is VFXHost:
			_play_async(effect_id, host, target)
			return

	emit_signal("effect_finished", target)

func _play_async(effect_id: String, host: VFXHost, target: Node) -> void:
	await host.play_and_wait(effect_id)
	emit_signal("effect_finished", target)
	print("finish play")
