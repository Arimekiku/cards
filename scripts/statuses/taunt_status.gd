class_name TauntStatus
extends Resource

var target_node = null

func apply(minion: Minion):
	minion.add_to_group("taunt_minions")
	target_node = minion

func remove():
	target_node.remove_from_group("taunt_minions")
