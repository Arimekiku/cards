class_name EventBus
extends Service

func init() -> void: pass

# card events
@warning_ignore("unused_signal")
signal target_selector_called_event(context)
@warning_ignore("unused_signal")
signal target_selector_discard_event(context)
@warning_ignore("unused_signal")
signal target_selector_resolved_event(context)

# game-state events
@warning_ignore("unused_signal")
signal card_played(card)
@warning_ignore("unused_signal")
signal spell_played(card)
@warning_ignore("unused_signal")
signal minion_spawned(minion)
