extends CardEffect
class_name FreezeAndDrawEffect

@export var duration: int = 1

func resolve(context) -> void:
	if context == null:
		return

	var targets := TargetResolver.resolve(target, context)
	if targets.is_empty():
		return

	var frozen_count := 0

	for t in targets:
		if not t:
			continue
		if not t.has_method("add_status"):
			continue

		var freeze := FreezeStatus.new(duration)
		freeze.apply(t)
		frozen_count += 1

	if frozen_count <= 0:
		return

	_draw_cards(context, frozen_count)
	
func _draw_cards(context, amount: int) -> void:
	var game := context.get_tree().get_first_node_in_group("game") as Game
	if not game:
		return

	var owner: Enums.CharacterType
	if context is Card:
		owner = context.card_owner
	elif context is Minion:
		owner = context.minion_owner
	else:
		return

	var character := game.get_character(owner)
	if not character:
		return

	for i in range(amount):
		character.draw_card(character.deck)
