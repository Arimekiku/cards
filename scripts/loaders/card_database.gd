extends Node
class_name CardDatabase

@export var json_path := "res://data/cards.json"

var cards: Dictionary = {} # id -> CardData

func _ready() -> void:
	load_cards()

func load_cards() -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Cannot open cards.json")
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid cards.json format")
		return

	for id in parsed.keys():
		cards[id] = _create_card_data(parsed[id])
		
func _create_card_data(raw: Dictionary) -> CardData:
	var card := CardData.new()
	card.name = raw.get("name", "UNKNOWN")
	card.cost = raw.get("cost", 0)
	card.image = load(raw.get("image", ""))

	card.card_context = _create_context(raw)
	card.effects = _create_effects(raw.get("effects", []))

	return card

func _create_context(raw: Dictionary) -> CardContext:
	match raw.get("card_type", ""):
		"creature":
			var ctx := MinionContext.new()
			ctx.health = raw.stats.health
			ctx.damage = raw.stats.damage
			return ctx

		"spell":
			var ctx := SpellContext.new()
			ctx.description = raw.get("description", "")
			return ctx

		_:
			push_error("Unknown card type")
			return CardContext.new()
			
func _create_effects(list: Array) -> Array[CardEffect]:
	var result: Array[CardEffect] = []

	for id in list:
		match id:
			"print_freeze":
				var e := PrintEffect.new()
				e.value = "FREEZE!"
				result.append(e)

			"print_damage":
				var e := PrintEffect.new()
				e.value = "DAMAGE!"
				result.append(e)

			_:
				push_warning("Unknown effect: %s" % id)

	return result
