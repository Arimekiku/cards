extends Node2D
class_name CardHandler

const MASK_CARD := 1

var zone: CardZone
var dragging: Card
var grab_offset: Vector2

func _input(event) -> void:
	if event is not InputEventMouseButton:
		return
	
	if  event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		var potential_dragging = _ray_card()
		
		if potential_dragging.placed == false:
			dragging = _ray_card()
		
		if dragging != null:
			grab_offset = dragging.global_position - get_global_mouse_position()
	else:
		if (dragging):
			try_place(dragging)
		dragging.input_phase(event)
		dragging = null

func _process(_delta) -> void:
	if dragging == null:
		return
	
	dragging.global_position = get_global_mouse_position() + grab_offset

func connect_card(card: Card) -> void:
	card.hovered.connect(_on_hover)
	card.exited.connect(_on_exit)

func _on_hover(card: Card) -> void:
	card.scale = Vector2(1.05, 1.05)
	card.z_index = 100

func _on_exit(card: Card) -> void:
	card.scale = Vector2.ONE
	card.z_index = 1

func _ray_card() -> Card:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = MASK_CARD
	
	var r = space.intersect_point(q)
	if r.is_empty():
		return null
	
	return r[0].collider.get_parent()

func try_place(card) -> void:
	for in_zone in get_tree().get_nodes_in_group("card_zones"):
		if in_zone.can_accept(card) and in_zone.is_mouse_inside():
			in_zone.add_card(card)
			return
	
	# fallback: return to original zone
	#zone.layout()
