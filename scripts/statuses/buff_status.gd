class_name BuffStatus
extends Resource

var target_node = null
var duration: int = -1

var attack_bonus: int = 0
var health_bonus: int = 0

var _events: EventBus

func _init(_attack: int, _health: int, _duration: int = -1) -> void:
	attack_bonus = _attack
	health_bonus = _health
	duration = _duration

func apply(target) -> void:
	target_node = target
	_events = ServiceLocator.get_service(EventBus)
	
	_apply_buff()
	
	if target_node.has_signal("died_event"):
		target_node.died_event.connect(_on_target_died)

func _apply_buff() -> void:
	if not is_instance_valid(target_node):
		return
	
	target_node.damage += attack_bonus
	target_node.health_component.health += health_bonus
	target_node.ui_update()

func on_turn_start() -> void:
	if duration < 0:
		return

	duration -= 1
	if duration <= 0:
		remove()

func _on_target_died(_m) -> void:
	remove()

func remove() -> void:
	if not target_node:
		return
	
	target_node.damage -= attack_bonus
	target_node.health_component.health -= health_bonus
	target_node.ui_update()
	
	if target_node.has_signal("died_event"):
		target_node.died_event.disconnect(_on_target_died)
	
	if target_node.has_method("remove_status"):
		target_node.remove_status(self)
	
	target_node = null
