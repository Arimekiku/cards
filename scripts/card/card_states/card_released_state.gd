class_name CardReleasedState
extends CardBaseState

var played: bool

func enter() -> void:
	played = not target.potential_targets.is_empty()
	if not played: return
	
	if target is MinionCard:
		target.place_minion()
	
	if target is SpellCard:
		var potential_enemy = target.potential_targets[0].get_parent()
		target.cast_spell(potential_enemy)

func on_input(_event: InputEvent) -> void:
	if played: return
	transition.emit(self, CardIdleState)
