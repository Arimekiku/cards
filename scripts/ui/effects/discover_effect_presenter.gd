extends CanvasLayer
class_name DiscoverEffectPresenter

@onready var card_container := $card_presenter

var events: EventBus
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

var cards: Array[Card] = []
var currently_hovered_card: Card
var context

func _ready() -> void:
	visible = false
	events = ServiceLocator.get_service(EventBus)
	events.discover_requested.connect(_on_discover_requested)

func _on_discover_requested(ctx, card_datas: Array[CardData]) -> void:
	if card_datas.is_empty():
		return

	context = ctx
	visible = true
	set_process(true)
	set_process_input(true)

	_clear()
	_spawn_cards(card_datas)

func _spawn_cards(card_datas: Array[CardData]) -> void:
	for data in card_datas:
		var instance := Game.create_card_from_data(data)
		instance.state_machine.active = false
		card_container.add_child(instance)
		cards.append(instance)

func _input(event):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and currently_hovered_card:
		_confirm_selection(currently_hovered_card.data)

func _physics_process(_delta):
	var mouse_pos = card_container.get_global_mouse_position()
	var found: Card = null

	for i in range(cards.size() - 1, -1, -1):
		var card = cards[i]
		if card.get_global_rect().has_point(mouse_pos):
			found = card
			break

	if found != currently_hovered_card:
		if currently_hovered_card:
			_animate_card_scale(currently_hovered_card, Vector2.ONE)
		if found:
			_animate_card_scale(found, Vector2(1.2, 1.2))
		currently_hovered_card = found

func _confirm_selection(data: CardData) -> void:
	set_process(false)
	set_process_input(false)
	visible = false

	events.discover_finished.emit(context, data)
	_clear()

func _clear():
	for c in cards:
		c.queue_free()
	cards.clear()
	currently_hovered_card = null

func _animate_card_scale(card: Card, target: Vector2):
	if card.tween:
		card.tween.kill()
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", target, 0.15)
	card.tween = tween
