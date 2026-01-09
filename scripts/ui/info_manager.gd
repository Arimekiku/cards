extends CanvasLayer

@onready var info_card: InfoCard = $info_card
@onready var request_timer: Timer = $info_request_timer

var event_bus: EventBus = ServiceLocator.get_service(EventBus)
var blocked: bool = false
var cached_ctx: Node

func _ready() -> void:
	event_bus.minion_info_show_request.connect(_on_info_show_request)
	event_bus.minion_info_destroy_request.connect(_on_info_destroy_request)
	event_bus.minion_info_blocking_request.connect(_on_info_blocking_request)
	
	info_card.hide()

func _on_info_blocking_request(context: bool) -> void:
	blocked = context

func _on_info_show_request(data) -> void:
	if blocked: return
	
	request_timer.start()
	cached_ctx = data

func _on_info_destroy_request(_data) -> void:
	request_timer.stop()
	info_card.set_disappear(true)

func _on_info_request_timer_timeout() -> void:
	info_card.setup(cached_ctx)
	info_card.global_position = cached_ctx.global_position + cached_ctx.get_global_rect().size.x * Vector2.RIGHT
	info_card.set_disappear(false)
