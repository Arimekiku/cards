extends CardEffect
class_name DiscardScaledBuffEffect

@export var cards_per_stack: int = 1
@export var duration: int = -1

func resolve(context) -> void:
	if context == null:
		return
	if not context is Minion:
		return

	var stacks := DiscardUtils.get_discard_count(context)
	if stacks <= 0:
		return

	var status := BuffStatus.new(
		stacks,
		stacks,
		duration
	)
	status.apply(context)
