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
	#$NameLabel.text = data.name
	%cost_text.text = str(data.cost)
	%description_text.text = data.card_context.description

func play() -> void:
	if potential_targets.is_empty(): return
	var context = null
	if card_owner == Enums.CharacterType.PLAYER:
		context = potential_targets[0].get_parent()
	else:
		context = potential_targets[0]
		
	if not context.has_method("take_damage"):
		push_error("Invalid spell target")
		return

	for effect in data.card_context.on_play_effects:
		effect.resolve(context)

	played_event.emit(self)


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
