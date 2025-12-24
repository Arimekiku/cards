class_name MinionStateMachine
extends StateMachine

func _init(from: Minion, new_states: Array, initial_state: Variant) -> void:
	for state in new_states:
		state.target = from
	
	super(new_states, initial_state)

func on_input(event: InputEvent) -> void:
	var card_state: MinionBaseState = current_state as MinionBaseState
	if card_state: card_state.on_input(event)

func on_gui_input(event: InputEvent) -> void:
	var card_state: MinionBaseState = current_state as MinionBaseState
	if card_state: card_state.on_gui_input(event)

func on_mouse_enter() -> void:
	var card_state: MinionBaseState = current_state as MinionBaseState
	if card_state: card_state.on_mouse_enter()

func on_mouse_exit() -> void:
	var card_state: MinionBaseState = current_state as MinionBaseState
	if card_state: card_state.on_mouse_exit()
