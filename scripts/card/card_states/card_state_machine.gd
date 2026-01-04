class_name CardStateMachine
extends StateMachine

var active: bool = true

func _init(from: Card, new_states: Array, initial_state: Variant) -> void:
	for state in new_states:
		state.target = from
	
	super(new_states, initial_state)

func on_input(event: InputEvent) -> void:
	if not active: return
	
	var card_state: CardBaseState = current_state as CardBaseState
	if card_state: card_state.on_input(event)

func on_gui_input(event: InputEvent) -> void:
	if not active: return
	
	var card_state: CardBaseState = current_state as CardBaseState
	if card_state: card_state.on_gui_input(event)

func on_mouse_enter() -> void:
	if not active: return
	
	var card_state: CardBaseState = current_state as CardBaseState
	if card_state: card_state.on_mouse_enter()

func on_mouse_exit() -> void:
	if not active: return
	
	var card_state: CardBaseState = current_state as CardBaseState
	if card_state: card_state.on_mouse_exit()
