class_name CardReleasedState
extends CardBaseState

var played: bool

func enter() -> void:
	var game := target.get_tree().get_first_node_in_group("game") as Game
	var character := game.get_character(target.card_owner)
	
	played = not target.potential_targets.is_empty()
	if not played: return
	
	if not character.mana.spend(target.data.cost):
		return
	
	if target is MinionCard:
		var context = null
		target.play(context)
	
	if target is SpellCard:
		var potential_enemy = target.potential_targets[0].get_parent()
		target.play(potential_enemy)

func on_input(_event: InputEvent) -> void:
	if played: return
	
	_normalize()
	transition.emit(self, CardIdleState)

func _normalize() -> void:
	target.scale = Vector2.ONE
	target.z_index = 1
