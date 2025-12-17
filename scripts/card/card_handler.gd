extends Node2D
class_name CardHandler
const MASK_CARD := 1

var dragging: Card

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = _ray_card()
		else:
			dragging = null

func _process(_delta):
	if dragging:
		dragging.global_position = get_global_mouse_position()

func connect_card(card: Card):
	card.hovered.connect(_on_hover)
	card.exited.connect(_on_exit)

func _on_hover(card: Card):
	card.scale = Vector2(1.05, 1.05)
	card.z_index = 2

func _on_exit(card: Card):
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
