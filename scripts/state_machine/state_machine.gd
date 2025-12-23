class_name StateMachine

var current_state: BaseState
var state_registry: Dictionary[Variant, BaseState]

func _init(new_states: Array, initial_state: Variant) -> void:
	for state in new_states:
		var variant: Variant = state.get_script()
		if state_registry.has(variant): 
			push_warning("State collision. Found duplicate state of type: %s" % variant.get_global_name())
			continue
		
		state_registry[variant] = state
		state.transition.connect(_on_transition)
	
	current_state = state_registry.values()[0]
	if state_registry.has(initial_state) == false:
		push_error("Wrong initial state: %s" % initial_state.get_global_name())
		return
	current_state = state_registry[initial_state]
	current_state.enter()

func _on_transition(from: BaseState, to: Variant) -> void:
	if from != current_state:
		var current_name: String = current_state.get_script().get_global_name()
		var from_name: String = from.get_script().get_global_name()
		push_warning("Inconsistent state flow. Expected %s, found %s" % current_name % from_name)
		return
	
	var new_state = state_registry.get(to, null)
	if not new_state:
		var new_state_name: String = to.get_global_name()
		push_error("Wrong state request. Request type: %s" % new_state_name)
		return
	
	if current_state: current_state.exit()
	current_state = new_state
	current_state.enter()
