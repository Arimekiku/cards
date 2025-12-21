extends Card
class_name MinionCard

var health: int
var damage: int
var attacking := false

signal died(card)

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != CardContext.CardType.MINION:
		push_error("Wrong type expected MINION, got: %s" % type)
		return
	
	data = card_data
	health = data.card_context.health
	damage = data.card_context.damage
	
	$graphics.texture = data.image
	#$NameLabel.text = data.name
	#$CostLabel.text = str(data.cost)
	_ui_update_health(health)
	_ui_update_damage(damage)

func input_phase(event: InputEventMouseButton) -> void:
	pass

func _ray_minion() -> MinionCard:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = 1
	
	var r = space.intersect_point(q)
	if r.is_empty():
		return null
	
	var card = r[0].collider.get_parent()
	if card is MinionCard:
		return card
	
	return null

func attack(target: MinionCard) -> void:
	target.take_damage(damage)

func take_damage(value: int) -> void:
	health -= value
	if health <= 0:
		emit_signal("died", self)
		queue_free()
		return
	_ui_update_health(health)

func _ui_update_health(value: int) -> void:
	$interface/text_box/health_panel/health.text = str(value)

func _ui_update_damage(value: int) -> void:
	$interface/text_box/damage_panel/damage.text = str(value)
