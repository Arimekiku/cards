class_name CardAimState
extends CardBaseState

const MOUSE_MINIMAL_Y_THRESHOLD := 600
const BASIC_CARD_Y_UPPRISING := 100

func enter() -> void:
	var offset := Vector2(target.parent.size.x / 2, -target.size.y / 2)
	offset.x -= target.size.x / 2
	offset.y -= BASIC_CARD_Y_UPPRISING
	target.animate_to_position(target.parent.global_position + offset, 0.2)
	target.collision_detector.monitoring = false
	
	Events.target_selector_called_event.emit(target)

func exit() -> void:
	Events.target_selector_discard_event.emit(target)

func on_input(event: InputEvent) -> void:
	var mouse_at_bottom := target.get_global_mouse_position().y > MOUSE_MINIMAL_Y_THRESHOLD
	if mouse_at_bottom or event.is_action_pressed("right_mouse"):
		transition.emit(self, CardIdleState)
		return
	
	if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
		target.get_viewport().set_input_as_handled()
		transition.emit(self, CardReleasedState)
