class_name MinionIdleState
extends MinionBaseState

var event_bus: EventBus = ServiceLocator.get_service(EventBus)

func enter() -> void:
	if not target.is_node_ready(): await target.ready

func on_gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("left_mouse"): return
	if target.minion_owner == Enums.CharacterType.ENEMY: return
	if target.has_attacked: return
	
	event_bus.minion_info_destroy_request.emit(target)
	transition.emit(self, MinionAimState)

func on_mouse_enter() -> void:
	event_bus.minion_info_show_request.emit(target)

func on_mouse_exit() -> void:
	event_bus.minion_info_destroy_request.emit(target)
