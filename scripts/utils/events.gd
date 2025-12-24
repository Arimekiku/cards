extends Node

# card events
@warning_ignore("unused_signal")
signal target_selector_called_event(context)
@warning_ignore("unused_signal")
signal target_selector_discard_event(context)
@warning_ignore("unused_signal")
signal target_selector_resolved_event(context)

# game-state events
@warning_ignore("unused_signal")
signal turn_changed_event(turn_context: Enums.Turn)

#

#

#
