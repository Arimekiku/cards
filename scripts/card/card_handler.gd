extends Node2D
class_name CardHandler

const COLLISION_MASK_I := 1

var _screen_size: Vector2
var zones: Array[Node]
var dragging: Card
var grab_offset: Vector2
var selected_attacker: MinionCard = null

@export var hand: Hand
@export var turn_manager: TurnManager
@export var deck: Deck

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	zones = get_tree().get_nodes_in_group("card_zones")

func _input(event) -> void:
	if event is not InputEventMouseButton: return
	if  event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.pressed:
		var card = _ray_card()
		if card == null: return
			
		if card is MinionCard and card.placed:
			if card.has_attacked: return
			_handle_attack_click(card)
			return
			
		if card.placed == false and card.card_owner == CardBoard.Owner.PLAYER and turn_manager.current_turn == turn_manager.Turn.PLAYER:
			dragging = _ray_card()
		if dragging != null:
			grab_offset = dragging.global_position - get_global_mouse_position()
		
		dragging.rotation = 0
	else:
		if (dragging):
			try_place(dragging)
			dragging.input_phase(event)
			dragging.drag_finished.emit(dragging)
		
		dragging = null
	
	for zone in zones:
		zone.update_highlight(dragging)

func _process(_delta) -> void:
	if dragging == null or dragging.get_parent() is not Hand: return
	
	var target_pos = get_global_mouse_position() + grab_offset
	dragging.global_position = target_pos

func connect_card(card: Card) -> void:
	card.hovered.connect(_on_hover)
	card.exited.connect(_on_exit)

func _on_hover(card: Card) -> void:
	if dragging: return
	
	card.scale = Vector2(1.05, 1.05)
	card.z_index = 100

func _on_exit(card: Card) -> void:
	if dragging: return
	
	card.scale = Vector2.ONE
	card.z_index = 1

func _ray_card() -> Card:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = COLLISION_MASK_I
	
	var r = space.intersect_point(q)
	if r.is_empty(): return null
	
	r.sort_custom(_sort_highest_z)
	return r[0].collider.get_parent()

func try_place(card) -> void:
	for in_zone: CardBoard in get_tree().get_nodes_in_group("card_zones"):
		if in_zone.can_accept(card) and in_zone.is_mouse_inside():
			hand.remove_card(card)
			in_zone.add_card(card)
			
			card.hovered.disconnect(_on_hover)
			card.exited.disconnect(_on_exit)
			
			card.placed = true
			card.scale = Vector2.ONE
			card.z_index = 1
			return
	
	# fallback: return to original zone
	#zone.layout()

func _handle_attack_click(card: MinionCard) -> void:
	if selected_attacker == null:
		if card.card_owner != CardBoard.Owner.PLAYER: return
		
		selected_attacker = card
		_highlight_attacker(card)
		_highlight_enemies(Color.GREEN)
		return
	
	if card.card_owner == CardBoard.Owner.ENEMY:
		selected_attacker.attack(card)
		_clear_attack_selection()
		_highlight_enemies(Color.WHITE)

func _highlight_enemies(color: Color) -> void:
	for in_zone: CardBoard in get_tree().get_nodes_in_group("card_zones"):
		if in_zone.board_owner == CardBoard.Owner.PLAYER: continue
		
		for card in in_zone.cards:
			card.modulate = color

func _highlight_attacker(card: MinionCard) -> void:
	card.scale = Vector2(1.15, 1.15)
	card.z_index = 200

func _clear_attack_selection() -> void:
	if selected_attacker:
		selected_attacker.scale = Vector2.ONE
		selected_attacker.z_index = 1
	selected_attacker = null

func _sort_highest_z(a, b) -> bool:
	return a.collider.get_parent().z_index > b.collider.get_parent().z_index
