@abstract
extends Resource
class_name CardEffect

@export var target: Enums.SpellTargetType = Enums.SpellTargetType.NO_TARGET

var _vfx_service: VFXService = ServiceLocator.get_service(VFXService)

func requires_target() -> bool:
	return target in [
		Enums.SpellTargetType.TARGET,
		Enums.SpellTargetType.NON_HERO_TARGET,
		Enums.SpellTargetType.ENEMY_TARGET,
		Enums.SpellTargetType.ALLY_TARGET,
		Enums.SpellTargetType.HERO
	]

func _get_caster(context) -> Node:
	if not context:
		return null

	var group := "player_casters"
	if context is Card and context.card_owner == Enums.CharacterType.ENEMY:
		group = "enemy_casters"

	var casters = context.get_tree().get_nodes_in_group(group)
	if casters.is_empty():
		return null
	else:
		return casters[0]

func _play_effect_vfx(
	vfx_id: String,
	caster: Node,
	target: Node,
	context
) -> Node2D:
	if not vfx_id:
		return null

	return _vfx_service.play_free(
		vfx_id,
		caster,
		target,
		context.get_tree().current_scene
	)

@abstract func resolve(context) -> void
