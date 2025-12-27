extends CardEffect
class_name TauntEffect

func apply(owner: Minion):
	print("taunt")
	owner.add_to_group("taunt")

func remove(owner: Minion):
	print("untaunt")
	owner.remove_from_group("taunt")

func resolve(_context): pass
