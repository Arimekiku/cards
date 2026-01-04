extends CanvasLayer

signal selection_finished(card: Card)

@onready var card_container := $card_presenter

@export var card_metas: Array[String]

var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
var currently_hovered_card: Card
var cards: Array[Card]

func setup(cards_meta: Array[String]) -> void:
	if not cards_meta: return
	card_metas = cards_meta

func _ready() -> void:
	for meta in card_metas:
		var data = card_database.get_from_registry(meta)
		var instance = Game.create_card_from_data(data)
		instance.state_machine.active = false
		
		card_container.add_child(instance)
		cards.append(instance)
	
	selection_finished.connect(_confirm_selection)

func _physics_process(_delta: float):
	var mouse_pos = card_container.get_global_mouse_position()
	var found_card = null
	
	for i in range(cards.size() - 1, -1, -1):
		var card = cards[i]
		
		if card.get_global_rect().has_point(mouse_pos):
			found_card = card
			break
	
	if found_card != currently_hovered_card:
		if currently_hovered_card:
			_animate_card_scale(currently_hovered_card, Vector2(1.0, 1.0))
		
		if found_card:
			_animate_card_scale(found_card, Vector2(1.2, 1.2))
		
		currently_hovered_card = found_card

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if currently_hovered_card:
			selection_finished.emit(currently_hovered_card)

func _animate_card_scale(card: Card, target_scale: Vector2):
	if card.tween: card.tween.kill()
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", target_scale, 0.15)
	
	card.tween = tween

func _confirm_selection(selected_card):
	set_process(false)
	set_process_input(false)
	
	visible = false
	print("Manager selected card: ", selected_card.data.name)
