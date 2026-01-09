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
signal spell_played(card)
@warning_ignore("unused_signal")
signal minion_spawned(minion)

# minion events
@warning_ignore("unused_signal")
signal minion_info_show_request(minion)
@warning_ignore("unused_signal")
signal minion_info_destroy_request(minion)

# card selection (discover) events
@warning_ignore("unused_signal")
signal discover_requested(context, cards: Array[CardData])
@warning_ignore("unused_signal")
signal discover_finished(context, selected: CardData)
