extends CardEffect
class_name PassiveBuffEffect

@export var damage_bonus := 1

func apply(owner: Minion):
	for minion in owner.get_tree().get_nodes_in_group("player_minions"):
		minion.damage += damage_bonus
		minion._ui_update_damage(minion.damage)

func remove(owner: Minion):
	for minion in owner.get_tree().get_nodes_in_group("player_minions"):
		minion.damage -= damage_bonus
		minion._ui_update_damage(minion.damage)

func resolve(context) -> void: pass
