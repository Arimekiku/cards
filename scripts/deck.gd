extends Node2D

const COLLISION_MASK_I = 1

var _screen_size: Vector2
var _is_hovering: bool = false
var _card_drag: Node2D = null

func _ready() -> void:
	_screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if _card_drag == null:
		return
	
	var mouse_pos = get_global_mouse_position()
	_card_drag.position = Vector2(
		clamp(mouse_pos.x, 0, _screen_size.x),
		clamp(mouse_pos.y, 0, _screen_size.y)
	)

func _input(event) -> void:
	var mouse_event = event as InputEventMouseButton
	
	if mouse_event and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_card_drag = ray_card()
		else:
			_card_drag = null

func ray_card() -> Node2D:
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = COLLISION_MASK_I
	
	var result = space.intersect_point(params)
	result.sort_custom(sort_highest_z)
	return result[0].collider.get_parent() if result else null

func connect_card_signals(card: Node2D) -> void:
	card.connect("_on_hover", on_hovered_signal)
	card.connect("_on_exit", on_exit_signal)

func on_hovered_signal(card: Node2D) -> void:
	if not _is_hovering:
		_is_hovering = true
		highlight_card(card, true)

func on_exit_signal(card: Node2D) -> void:
	highlight_card(card, false)
	
	var new_card_hovering = ray_card()
	if new_card_hovering:
		highlight_card(new_card_hovering, true)
	else:
		_is_hovering = false

func highlight_card(card: Node2D, is_hovered: bool) -> void:
	card.scale = Vector2(1.05, 1.05) if is_hovered else Vector2.ONE
	card.z_index = 2 if is_hovered else 1

func sort_highest_z(a, b) -> bool:
	return a.collider.get_parent().z_index > b.collider.get_parent().z_index
