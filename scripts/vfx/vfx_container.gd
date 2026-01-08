extends Node2D
class_name VFXContainer

func play_and_wait() -> void:
	var waits := []

	for child in get_children():
		if child is GPUParticles2D:
			child.restart()
			waits.append(child.finished)

		elif child is AnimationPlayer:
			child.play("default")
			waits.append(child.animation_finished)

		elif child.has_method("play"):
			child.play()
			if child.has_signal("finished"):
				waits.append(child.finished)

	for w in waits:
		await w
