extends Node2D

const MAX_POINTS := 12
const MINIONS_COLLISION_LAYER := 3
const ALLIES_COLLISION_LAYER := 4

@onready var area_detector := $detector
@onready var arrow_arc := %arrow_arc

var selection_context: Control
var targeting: bool
var events: EventBus

func _ready() -> void:
	events = ServiceLocator.get_service(EventBus)
	
	events.target_selector_called_event.connect(_on_target_selector_called)
	events.target_selector_discard_event.connect(_on_target_selector_discarded)

func _input(event: InputEvent) -> void:
	if not targeting: return
	
	if event.is_action_pressed("left_mouse"):
		if selection_context.potential_targets.is_empty():
			return
		var parent = selection_context.potential_targets[0].get_parent()
		var target = parent
		selection_context.potential_targets.clear()
		events.target_selector_resolved_event.emit(target)
		return


func _process(_delta: float) -> void:
	if not targeting: return
	
	area_detector.position = get_local_mouse_position()
	arrow_arc.points = _calculate_points()

func _on_detector_area_entered(area: Area2D) -> void:
	if not selection_context or not targeting: return
	
	if not selection_context.potential_targets.has(area):
		selection_context.potential_targets.append(area)

func _on_detector_area_exited(area: Area2D) -> void:
	if not selection_context or not targeting: return
	
	selection_context.potential_targets.erase(area)

func _on_target_selector_called(target) -> void:
	if not (target is Minion or target is SpellCard): return
	
	var is_spell = target is SpellCard
	area_detector.set_collision_mask_value(ALLIES_COLLISION_LAYER, is_spell)
	
	targeting = true
	area_detector.monitoring = true
	area_detector.monitorable = true
	selection_context = target

func _on_target_selector_discarded(_target) -> void:
	targeting = false
	area_detector.monitoring = false
	area_detector.monitorable = false
	area_detector.position = Vector2.ZERO
	selection_context = null
	arrow_arc.clear_points()

func _calculate_points() -> Array[Vector2]:
	var result: Array[Vector2]
	
	var start := selection_context.global_position
	start.x += selection_context.size.x / 2
	var target := get_local_mouse_position()
	var distance := target - start
	
	for i in range(MAX_POINTS):
		var t := 1. / MAX_POINTS * i
		var current_x := start.x + distance.x / MAX_POINTS * i
		var current_y := start.y + _ease_out_cubic(t) * distance.y
		result.append(Vector2(current_x, current_y))
	
	result.append(target)
	return result

func _ease_out_cubic(t: float) -> float:
	return 1. - pow(1. - t, 3.)
