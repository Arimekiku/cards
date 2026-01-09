extends CardEffect
class_name SpellPlayedBuffEffect

var _callback: Callable
var _events: EventBus
var _minion: Minion

func resolve(context) -> void:
	if context is not Minion:
		return

	_minion = context
	_events = ServiceLocator.get_service(EventBus)

	_callback = func(card):
		if not is_instance_valid(_minion):
			return

		if card.card_owner != _minion.minion_owner:
			return

		_minion.damage += 1
		_minion.ui_update()

	_events.spell_played.connect(_callback)

	_minion.died_event.connect(_on_minion_died)

func _on_minion_died(_m):
	if _events and _callback:
		if _events.spell_played.is_connected(_callback):
			_events.spell_played.disconnect(_callback)
