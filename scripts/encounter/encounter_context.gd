extends Service
class_name EncounterContext

var future_card_bonuses := {}

func init() -> void:
	future_card_bonuses.clear()

func add_future_card_bonus(card_id: String, stats: Dictionary) -> void:
	if not future_card_bonuses.has(card_id):
		future_card_bonuses[card_id] = {}

	for key in stats.keys():
		future_card_bonuses[card_id][key] = \
			future_card_bonuses[card_id].get(key, 0) + stats[key]

func get_bonus_for(card_id: String) -> Dictionary:
	return future_card_bonuses.get(card_id, {})
