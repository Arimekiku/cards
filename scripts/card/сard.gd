@abstract
class_name Card
extends Control

@warning_ignore("unused_signal")
signal reparent_event(card: Card)
@warning_ignore("unused_signal")
signal played_event(card: Card)

var parent: Control
var tween: Tween
var state_machine: CardStateMachine
var data: CardData
var card_owner := Enums.CharacterType.PLAYER

@onready var potential_targets: Array[Node] = []

@abstract func setup(card_data: CardData) -> void
@abstract func play() -> void

func _input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_input(event)

func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween()\
	.set_trans(Tween.TRANS_CIRC)\
	.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", new_position, duration)

func set_detection(value: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if value == false\
	else Control.MOUSE_FILTER_STOP

func _on_gui_input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	if not state_machine: return
	state_machine.on_mouse_enter()

func _on_mouse_exited() -> void:
	if not state_machine: return
	state_machine.on_mouse_exit()

func _on_collision_detector_area_entered(area: Area2D) -> void:
	if potential_targets.has(area): return
	potential_targets.push_back(area)

func _on_collision_detector_area_exited(area: Area2D) -> void:
	potential_targets.erase(area)

func requires_target() -> bool:
	return data.card_context.requires_target()

func resolve_on_draw():
	if data.card_context.on_draw_effects.is_empty():
		return

	for effect in data.card_context.on_draw_effects:
		effect.resolve(self)
