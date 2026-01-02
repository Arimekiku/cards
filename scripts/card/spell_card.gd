class_name SpellCard
extends Card

@onready var collision_detector := %collision_detector

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != Enums.CardType.SPELL:
		push_error("Wrong type expected SPELL, got: %s" % type)
		return
	
	var states := [
		CardIdleState.new(),
		CardClickedState.new(),
		CardDragState.new(),
		CardReleasedState.new(),
		CardAimState.new()
	]
	state_machine = CardStateMachine.new(self, states, CardIdleState)
	
	data = card_data
	%portrait_image.texture = data.image
	$graphics/text_box/name_panel/name_text.text = data.name
	%cost_text.text = str(data.cost)
	%description_text.text = data.card_context.description

func play() -> void:
	var context = null
	
	if requires_target():
		if potential_targets.is_empty():
			push_error("Spell requires target but none provided")
			return
	
		if card_owner == Enums.CharacterType.PLAYER:
			context = potential_targets[0].get_parent()
		else:
			context = potential_targets[0]
	else:
		context = self
	
	for effect in data.card_context.on_play_effects:
		effect.resolve(context)
	
	var events: EventBus = ServiceLocator.get_service(EventBus)
	events.spell_played.emit(self)
	events.card_played.emit(self)
	
	played_event.emit(self)

func set_side(card_side: Enums.CardSide) -> void:
	match card_side:
		Enums.CardSide.FRONT:
			$graphics/outline.texture = frontside_image
			$graphics/text_box/name_panel/name_text.visible = true
			%cost_text.visible = true
			%description_text.visible = true
		Enums.CardSide.BACK:
			$graphics/outline.texture = backside_image
			$graphics/text_box/name_panel/name_text.visible = false
			%cost_text.visible = false
			%description_text.visible = false

func _on_collision_detector_area_entered(area: Area2D) -> void:
	super(area)

func _on_collision_detector_area_exited(area: Area2D) -> void:
	super(area)

func _on_gui_input(event: InputEvent) -> void:
	super(event)

func _on_mouse_entered() -> void:
	super()

func _on_mouse_exited() -> void:
	super()
