class_name TimerStatus
extends Resource

var connected_effects: Array[CardEffect]
var target_node = null
var duration: int = -1

var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

func _init(effects: Dictionary, _duration: int = -1) -> void:
	connected_effects = card_database._create_effects(effects)
	duration = _duration

func apply(target) -> void:
	target_node = target

func on_turn_start() -> void:
	duration -= 1
	if duration <= 0: remove()

func remove() -> void:
	target_node.remove_status(self)
	
	for effect in connected_effects:
		effect.resolve(target_node)
