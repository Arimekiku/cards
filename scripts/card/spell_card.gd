extends Card
class_name SpellCard

@onready var collision_detector := %collision_detector

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != CardContext.CardType.SPELL:
		push_error("Wrong type expected SPELL, got: %s" % type)
		return
	
	var states := [
		CardIdleState.new(),
		CardClickedState.new(),
		CardDragState.new(),
		CardReleasedState.new()
	]
	state_machine = CardStateMachine.new(self, states, CardIdleState)
	
	data = card_data
	
	%portrait_image.texture = data.image
	#$NameLabel.text = data.name
	%cost_text.text = str(data.cost)
	%description_text.text = data.card_context.description

func _on_collision_detector_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_collision_detector_area_exited(area: Area2D) -> void:
	pass # Replace with function body.

func _on_gui_input(event: InputEvent) -> void:
	super(event)

func _on_mouse_entered() -> void:
	super()

func _on_mouse_exited() -> void:
	super()

func cast_spell(card: Card) -> void:
	for effect in data.effects:
		effect.resolve(card)
	
	died_event.emit(self)
	queue_free()

func _ray_card() -> Card:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = 1
	
	var r = space.intersect_point(q)
	if r.is_empty(): return null
	
	var result = r.find_custom(_not_self)
	return r[result].collider.get_parent()

func _not_self(value) -> bool:
	return value.collider.get_parent() != self
