extends RefCounted
class_name FreezeStatus

var freeze_material := preload("res://resources/materials/freeze_material.tres")

var target_node = null
var turns_left: int = 1

func _init(_duration: int = 1) -> void:
	turns_left = _duration + 1

func apply(target) -> void:
	target_node = target
	# Базова дія: забороняємо атакувати
	if target_node.has_method("set_can_attack"):
		target_node.set_can_attack(false)
	else:
		# пряма установка якщо поле public
		if target_node.has_variable("can_attack"):
			target_node.can_attack = false
	
	var material_instance := freeze_material.duplicate()
	var canvas: CanvasGroup = target_node.canvas
	canvas.material = material_instance
	
	var tween = target_node.create_tween()
	tween.tween_property(material_instance, "shader_parameter/freeze_progress", 1.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func on_turn_start() -> void:
	turns_left -= 1
	if turns_left <= 0:
		remove()

func remove() -> void:
	if target_node:
		if target_node.has_method("set_can_attack"):
			target_node.set_can_attack(true)
		else:
			if target_node.has_variable("can_attack"):
				target_node.can_attack = true
		# Очистити статус з власника
		if target_node.has_method("remove_status"):
			target_node.remove_status(self)
	
	var material = target_node.canvas.material as ShaderMaterial
	if not material: return
	
	var tween = target_node.create_tween()
	tween.tween_property(material, "shader_parameter/freeze_progress", 0.0, 0.5)
