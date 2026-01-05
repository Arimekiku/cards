class_name CardReleasedState
extends CardBaseState

var played: bool

func enter() -> void:
	var game := target.get_tree().get_first_node_in_group("game") as Game
	var character := game.get_character(target.card_owner)
	
	played = not target.requires_target() or not target.potential_targets.is_empty()
	
	if not played:
		transition.emit(self, CardIdleState)
		return
	
	if not character.mana.spend(target.data.cost):
		transition.emit(self, CardIdleState)
		return
	
	target.play()

func on_input(_event: InputEvent) -> void:
	if played: return
	
	transition.emit(self, CardIdleState)
