class_name MinionCard
extends Card

@onready var collision_detector := %collision_detector

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != CardContext.CardType.MINION:
		push_error("Wrong type expected MINION, got: %s" % type)
		return
	
	var states := [
		CardIdleState.new(),
		CardClickedState.new(),
		CardDragState.new(),
		CardReleasedState.new()
	]
	state_machine = CardStateMachine.new(self, states, CardIdleState)
	
	data = card_data
	%portrait_image.texture = card_data.image
	#$NameLabel.text = data.name
	%cost_text.text = str(card_data.cost)
	%health.text = str(card_data.card_context.health)
	%damage.text = str(card_data.card_context.damage)

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
