extends CardEffect
class_name ApplyStatusEffect

@export var status: String
@export var duration: int = 1
@export var params := {}

@export var aoe_vfx_id := "aoe_freeze"
@export var target_vfx_id := "fireball"

func resolve(context):
	if context == null:
		return

	var targets = TargetResolver.resolve(target, context)
	if targets.is_empty():
		return

	var caster = _get_caster(context)
	if caster == null:
		return
	
	if target == Enums.SpellTargetType.SELF:
		_apply_status(targets[0])
		return
		

	# === AOE ===
	if not requires_target():
		_play_effect_vfx(aoe_vfx_id, caster, null, context)

		for t in targets:
			_apply_status(t)
		return

	# === TARGET ===
	for t in targets:
		_play_effect_vfx(target_vfx_id, caster, t, context)
		_apply_status(t)
		
func _apply_status(t) -> void:
	if t and t.has_method("add_status"):
		t.add_status(status, duration, params)
