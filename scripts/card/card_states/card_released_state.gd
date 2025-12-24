class_name CardReleasedState
extends CardBaseState

var played: bool

func enter() -> void:
	played = not target.potential_targets.is_empty()
	if not played: return
	
	if ManaHandler.current_mana < target.data.cost:
		print("Not enough mana to play")
		transition.emit(self, CardIdleState)
		return
	
	ManaHandler.current_mana -= target.data.cost
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
