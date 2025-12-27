class_name MinionAttackState
extends MinionBaseState

func enter() -> void:
	# 1. Очищаємо список від видалених об'єктів перед перевіркою
	target.potential_targets = target.potential_targets.filter(
		func(t): return is_instance_valid(t) and not t.is_queued_for_deletion()
	)

	if target.potential_targets.is_empty():
		transition.emit(self, MinionIdleState)
		return
		
	# 2. Тепер ми впевнені, що перший елемент валідний
	var target_area = target.potential_targets[0]
	var potential_enemy = target_area.get_parent()
	
	# 3. Перевіряємо, чи ворог живий (якщо є властивість health)
	if potential_enemy.has_method("take_damage"):
		if potential_enemy.get("health") <= 0:
			# Якщо ворог уже "мертвий" (в анімації), видаляємо його і виходимо
			target.potential_targets.erase(target_area)
			transition.emit(self, MinionIdleState)
			return
			
		_animate_attack(potential_enemy)
	else:
		transition.emit(self, MinionIdleState)

func _animate_attack(enemy) -> void:
	target.has_attacked = true
	var start_pos = target.global_position
	var target_pos = enemy.global_position
	
	var original_z = target.z_index
	target.z_index = 300
	
	var direction = (target_pos - start_pos).normalized()
	var wind_up_pos = start_pos - (direction * 50)
	
	var tween = target.create_tween()
	tween.tween_property(target, "global_position", wind_up_pos, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "global_position", target_pos, 0.15)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): _on_impact(enemy))
	tween.tween_property(target, "global_position", start_pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func(): target.z_index = original_z)

func _on_impact(enemy):
	target.attack(enemy)
	
	for area in target.potential_targets:
		if area.get_parent() == enemy:
			target.potential_targets.erase(area)
			break
	
	transition.emit(self, MinionIdleState)
	
	var shake = enemy.create_tween()
	shake.tween_property(enemy, "position:x", 10.0, 0.05).as_relative()
	shake.tween_property(enemy, "position:x", -10.0, 0.05).as_relative()
	shake.set_loops(3)
