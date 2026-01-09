extends CardEffect
class_name TargetDamageEffect

@export var value: int = 1
@export var vfx_id := "fireball"

var _vfx_service: VFXService = ServiceLocator.get_service(VFXService)

func resolve(context):
	if context == null:
		return
	
	var targets = TargetResolver.resolve(target, context)
	
	var caster_group := "player_casters"
	if context is Card and context.card_owner == Enums.CharacterType.ENEMY:
		caster_group = "enemy_casters"

	var casters = context.get_tree().get_nodes_in_group(caster_group)
	if casters.is_empty():
		return
	
	var caster = casters[0]
	
	for t in targets:
		if not t.has_method("take_damage"):
			continue
		
		var fireball = _vfx_service.play_free(
			vfx_id,
			caster,
			t,
			context.get_tree().current_scene
		)
		
		t.take_damage(value)
		if fireball and fireball.has_signal("finished"):
			fireball.finished.connect(
				func(ctx):
					if not is_instance_valid(ctx):
						return
					if not ctx.has_method("ui_update"):
						return
					
					ctx.ui_update()
			)
