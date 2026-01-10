extends CardEffect
class_name DiscardScaledAOEEffect

@export var damage_per_cards: int = 1

func resolve(context) -> void:
	if context == null:
		return

	var discard_count := DiscardUtils.get_discard_count(context)
	if discard_count <= 0:
		return
	
	var damage := discard_count * damage_per_cards
	if damage <= 0:
		return
	
	var targets := TargetResolver.resolve(target_type, target_group, context)
	for t in targets:
		if t and t.has_method("take_damage"):
			t.take_damage(damage)
