class_name MinionAttackState
extends MinionBaseState

func enter() -> void:
	if not is_instance_valid(target.current_target):
		target.has_attacked = true
		transition.emit(self, MinionIdleState)
		return
	
	target.attack(target.current_target)
	_animate_attack(target.current_target)

func _animate_attack(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		target.has_attacked = true
		target.attack_finished.emit(target)
		transition.emit(self, MinionIdleState)
		return
	
	var ui_layer := target.get_tree().get_first_node_in_group("battle_ui_layer")
	if not ui_layer:
		push_warning("battle_ui_layer not found")
		target.has_attacked = true
		target.attack_finished.emit(target)
		transition.emit(self, MinionIdleState)
		return
	
	var original_parent := target.get_parent()
	var original_index := target.get_index()
	var start_pos := target.global_position
	var original_z := target.z_index
	
	target.reparent(ui_layer)
	target.global_position = start_pos
	target.z_index = 300
	
	var target_pos = enemy.global_position
	var direction = (target_pos - start_pos).normalized()
	var wind_up_pos = start_pos - direction * 50
	
	var tween := target.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(target, "global_position", wind_up_pos, 0.2)
	tween.tween_property(target, "global_position", target_pos, 0.15)
	tween.tween_callback(func(): _on_impact(enemy))
	tween.tween_property(target, "global_position", start_pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		if is_instance_valid(target):
			target.reparent(original_parent)
			original_parent.move_child(target, original_index)
			target.z_index = original_z
		
		target.has_attacked = true
		target.attack_finished.emit(target)
		transition.emit(self, MinionIdleState)
	)

func _on_impact(enemy):
	if not is_instance_valid(enemy):
		return
	
	target.ui_update()
	enemy.ui_update()
	
	for area in target.potential_targets:
		if area.get_parent() == enemy:
			target.potential_targets.erase(area)
			break
	
	var shake = enemy.create_tween()
	shake.tween_property(enemy, "position:x", 10.0, 0.05).as_relative()
	shake.tween_property(enemy, "position:x", -10.0, 0.05).as_relative()
	shake.set_loops(3)
