extends RefCounted
class_name FreezeStatus

var target_node = null
var turns_left: int = 1

func _init(_duration: int = 1) -> void:
	turns_left = _duration + 1

func apply(target) -> void:
	print("freeze ", target)
	target_node = target
	# Базова дія: забороняємо атакувати
	if target_node.has_method("set_can_attack"):
		target_node.set_can_attack(false)
	else:
		# пряма установка якщо поле public
		if target_node.has_variable("can_attack"):
			target_node.can_attack = false

func on_turn_start() -> void:
	turns_left -= 1
	if turns_left <= 0:
		print("unfreeze")
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
