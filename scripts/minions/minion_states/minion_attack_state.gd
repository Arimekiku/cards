class_name MinionAttackState
extends MinionBaseState

func enter() -> void:
	if target.potential_targets.is_empty():
		transition.emit(self, MinionIdleState)
		return
	
	var potential_enemy: Minion = target.potential_targets[0].get_parent()
	if potential_enemy is not Minion:
		transition.emit(self, MinionIdleState)
		return
	
	_animate_attack(potential_enemy)

func _animate_attack(enemy: Minion) -> void:
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

func _on_impact(enemy: Minion):
	target.has_attacked = true
	target.attack(enemy)
	
	var shake = enemy.create_tween()
	shake.tween_property(enemy, "position:x", 10.0, 0.05).as_relative()
	shake.tween_property(enemy, "position:x", -10.0, 0.05).as_relative()
	shake.set_loops(3)
