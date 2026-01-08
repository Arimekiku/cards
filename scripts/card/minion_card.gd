class_name MinionCard
extends Card

@onready var collision_detector := %collision_detector
@onready var canvas: CanvasGroup = $graphics

func _ready() -> void:
	var mat = canvas.material
	canvas.material = mat.duplicate()

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != Enums.CardType.MINION:
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
	$graphics/text_box/name_panel/name_text.text = data.name
	%cost_text.text = str(card_data.cost)
	%health.text = str(card_data.card_context.health)
	%damage.text = str(card_data.card_context.damage)

func play() -> void:
	state_machine.active = false
	
	var output_zone: CardBoard
	var minion := Game.create_minion()
	get_tree().current_scene.add_child(minion)
	minion.setup(data)
	minion.global_position = global_position
	minion.scale = Vector2.ONE * 1.4
	
	minion.minion_owner = card_owner
	for in_zone: CardBoard in get_tree().get_nodes_in_group("card_zones"):
		if not in_zone.can_accept(minion):
			continue
		
		output_zone = in_zone
		break
	
	if output_zone == null:
		push_error("No valid CardBoard found to play minion")
		minion.queue_free()
		return
	
	var mouse_position = get_global_mouse_position()
	var index = output_zone.get_insertion_index(mouse_position.x)
	
	await _animate_dissolve().finished
	
	output_zone.add_minion(minion, index)
	played_event.emit(self)

func get_minion_instance() -> Minion:
	var minion := Game.create_minion()
	minion.setup(data)
	return minion

func set_side(card_side: Enums.CardSide) -> void:
	match card_side:
		Enums.CardSide.FRONT:
			$graphics/outline.texture = frontside_image
			$graphics/text_box/name_panel/name_text.visible = true
			%cost_text.visible = true
			%health.visible = true
			%damage.visible = true
		Enums.CardSide.BACK:
			$graphics/outline.texture = backside_image
			$graphics/text_box/name_panel/name_text.visible = false
			%cost_text.visible = false
			%health.visible = false
			%damage.visible = false

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

func _animate_dissolve() -> Tween:
	var mat = canvas.material
	
	var animation = self.create_tween()
	animation.tween_property(mat, "shader_parameter/dissolve_progress", 1.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	return animation
