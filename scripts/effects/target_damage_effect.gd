extends CardEffect
class_name TargetDamageEffect

@export var value: int = 1
@export var vfx_id := "fireball"

func resolve(context):
	if context == null:
		return
	
	var targets = TargetResolver.resolve(target, context)
	if targets.is_empty():
		return
	
	var caster = _get_caster(context)
	if caster == null:
		return
	
	for t in targets:
		if not t.has_method("take_damage"):
			continue
		
		var fireball: Node2D = _vfx_service.play_free(
			vfx_id,
			caster,
			t,
			context.get_tree().current_scene
		)
		
		var target_ref = t
		
		if fireball and fireball.has_signal("finished"):
			fireball.finished.connect(func(_target):
				if is_instance_valid(_target):
					_target.take_damage(value)
					if _target.has_method("ui_update"):
						_target.ui_update()
			)
		else:
			t.take_damage(value)
