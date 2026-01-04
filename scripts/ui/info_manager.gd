extends CanvasLayer

@onready var info_card: InfoCard = $info_card

var event_bus: EventBus = ServiceLocator.get_service(EventBus)

func _ready() -> void:
	event_bus.minion_info_show_request.connect(_on_info_show_request)
	event_bus.minion_info_destroy_request.connect(_on_info_destroy_request)
	
	info_card.hide()

func _on_info_show_request(data) -> void:
	info_card.setup(data)
	info_card.global_position = data.global_position + data.get_global_rect().size.x * Vector2.RIGHT
	info_card.set_disappear(false)

func _on_info_destroy_request(_data) -> void:
	info_card.set_disappear(true)
