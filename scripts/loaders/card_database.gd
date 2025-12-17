extends Node
class_name CardDatabase

static var CARD_FACTORY_TYPES = {
	"creature": MinionContext,
	"spell": SpellContext
}

static var EFFECT_FACTORY_TYPES = {
	"print_effect": PrintEffect,
	"damage_effect": DamageEffect
}

@export var json_path := "res://data/cards.json"

var cards_registry: Dictionary = {} # id -> CardData

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
		cards_registry[id] = _create_card_data(parsed[id])

func _create_card_data(raw: Dictionary) -> CardData:
	var card := CardData.new()
	card.name = raw.get("name", "UNKNOWN")
	card.cost = raw.get("cost", 0)
	card.image = load(raw.get("image", ""))
	
	card.card_context = _create_context(raw)
	card.effects = _create_effects(raw.get("effects", []))
	
	return card

func _create_context(raw: Dictionary) -> CardContext:
	var type = raw.get("card_type", "")
	if CARD_FACTORY_TYPES.has(type) == false:
		push_error("Unknown context type: %s" % type)
		return null
	
	var ctx = CARD_FACTORY_TYPES[type].new()
	_populate(ctx, raw)
	
	return ctx

func _create_effects(list: Dictionary) -> Array[CardEffect]:
	var result: Array[CardEffect] = []
	
	for id in list.keys():
		if EFFECT_FACTORY_TYPES.has(id) == false:
			push_error("Unknown effect type: %s" % id)
			continue
		
		var e = EFFECT_FACTORY_TYPES[id].new()
		_populate(e, list[id])
		result.append(e)
		
		if e is PrintEffect:
			print(e.value)
	
	return result

func _populate(obj, d: Dictionary) -> void:
	var props = obj.get_property_list()
	
	for p in props:
		if d.has(p.name) == false:
			continue
		
		obj.set(p.name, d[p.name])
