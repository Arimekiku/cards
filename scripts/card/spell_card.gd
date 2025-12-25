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
	var context = potential_targets[0].get_parent()
	if context is not Minion: 
		var context_name: String = context.get_script().get_global_name()
		push_error("Can't resolve spell. Invalid context. %s" % context_name) 
		return
	
	for effect in data.effects: effect.resolve(context)
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
