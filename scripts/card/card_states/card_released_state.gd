class_name CardReleasedState
extends CardBaseState

func enter() -> void:
	var game := target.get_tree().get_first_node_in_group("game") as Game
	var character := game.get_character(target.card_owner)
	
	if target.requires_target():
		if target.potential_targets.is_empty():
			transition.emit(self, CardIdleState)
			return
		
		var ctx := target.potential_targets[0].get_parent()
		if ctx is Minion and ctx.health_component.should_die():
			transition.emit(self, CardIdleState)
			return
	
	if not character.mana.spend(target.data.cost):
		transition.emit(self, CardIdleState)
		return
	
	target.play()
