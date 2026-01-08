extends RefCounted
class_name SpellFuryStatus

var target_node = null
var duration: int = -1

var _events: EventBus
var _callback: Callable

func _init(_duration: int = -1) -> void:
	duration = _duration

func apply(target) -> void:
	target_node = target
	_events = ServiceLocator.get_service(EventBus)

	_callback = func(card):
		_on_spell_played(card)

	_events.spell_played.connect(_callback)

	# підчищаємо при смерті міньйона
	if target_node.has_signal("died_event"):
		target_node.died_event.connect(_on_target_died)

func _on_spell_played(card) -> void:
	if not is_instance_valid(target_node):
		return

	# тільки спели
	if card is not SpellCard:
		return

	var vfx: VFXService = ServiceLocator.get_service(VFXService)
	if vfx:
		vfx.play("impact", target_node)
		
	# баф атаки
	target_node.damage += 1
	target_node._ui_update_damage(target_node.damage)

func _on_target_died(_m) -> void:
	remove()

func remove() -> void:
	if _events and _callback:
		if _events.spell_played.is_connected(_callback):
			_events.spell_played.disconnect(_callback)

	if target_node:
		if target_node.has_signal("died_event"):
			target_node.died_event.disconnect(_on_target_died)

		if target_node.has_method("remove_status"):
			target_node.remove_status(self)

	target_node = null
