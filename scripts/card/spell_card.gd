extends Card
class_name SpellCard

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != CardContext.CardType.SPELL:
		push_error("Wrong type expected SPELL, got: %s" % type)
		return
	
	data = card_data
	
	$graphics.texture = data.image
	#$NameLabel.text = data.name
	#$CostLabel.text = str(data.cost)
	$interface/text_box/panel/text.text = data.card_context.description

func input_phase(_event: InputEventMouseButton) -> void:
	var potential = _ray_card()
	if potential == null || potential.placed == false:
		return
	
	cast_spell(potential)

func cast_spell(card: Card) -> void:
	for effect in data.effects:
		effect.resolve(card)
	
	queue_free()

func _ray_card() -> Card:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = 1
	
	var r = space.intersect_point(q)
	if r.is_empty():
		return null
	
	var result = r.find_custom(not_self)
	return r[result].collider.get_parent()

func not_self(value) -> bool:
	return value.collider.get_parent() != self
