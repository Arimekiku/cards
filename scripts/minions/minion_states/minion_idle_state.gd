class_name MinionIdleState
extends MinionBaseState

func enter() -> void:
	if not target.is_node_ready(): await target.ready

func on_gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("left_mouse"): return
	if target.minion_owner == Enums.CharacterType.ENEMY: return
	if target.has_attacked: return
	
	transition.emit(self, MinionAimState)
