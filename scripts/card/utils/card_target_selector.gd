extends Node2D

const MAX_POINTS := 12

@onready var area_detector := $detector
@onready var arrow_arc := %arrow_arc

var current_card: Card
var targeting: bool

func _ready() -> void:
	Events.target_selector_called_event.connect(_on_target_selector_called)
	Events.target_selector_discard_event.connect(_on_target_selector_discarded)

func _process(_delta: float) -> void:
	if not targeting: return
	
	area_detector.position = get_local_mouse_position()
	arrow_arc.points = _calculate_points()

func _on_detector_area_entered(area: Area2D) -> void:
	if not current_card or not targeting: return
	
	if not current_card.potential_targets.has(area):
		current_card.potential_targets.append(area)

func _on_detector_area_exited(area: Area2D) -> void:
	if not current_card or not targeting: return
	
	current_card.potential_targets.erase(area)

func _on_target_selector_called(card: Card) -> void:
	if card is not SpellCard: return
	
	targeting = true
	area_detector.monitoring = true
	area_detector.monitorable = true
	current_card = card

func _on_target_selector_discarded(_card: Card) -> void:
	targeting = false
	area_detector.monitoring = false
	area_detector.monitorable = false
	area_detector.position = Vector2.ZERO
	current_card = null
	arrow_arc.clear_points()

func _calculate_points() -> Array[Vector2]:
	var result: Array[Vector2]
	
	var start := current_card.global_position
	start.x += current_card.size.x / 2
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
