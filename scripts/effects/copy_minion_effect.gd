extends CardEffect
class_name CopyMinionEffect

@export var on_copy_created: Array[CardEffect]
@export var amount: int = 1

func resolve(context: Minion) -> void:
	if context == null: return
	var game := context.get_tree().get_first_node_in_group("game") as Game
	
	var owner_type = context.minion_owner
	var character := game.get_character(owner_type)
	var board := character.board
	
	for i in range(amount):
		if board._is_full(): return
		
		_copy_minion(character, context)

func _copy_minion(character: CharacterRuntime, minion: Minion) -> void:
	var copy_minion := Game.create_minion()
	minion.get_tree().current_scene.add_child(copy_minion)
	copy_minion.global_position = minion.global_position
	
	copy_minion.setup(minion.data, true)
	copy_minion.minion_owner = character.side
	copy_minion.damage = minion.damage
	copy_minion.health_component.health = minion.health_component.health
	copy_minion.ui_update()
	
	for status in minion.statuses:
		copy_minion.copy_status(status)
	for effect in on_copy_created:
		effect.resolve(copy_minion)
	
	character.board.add_minion(copy_minion)
