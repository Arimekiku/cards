class_name CardDatabase
extends Service

var CARD_FACTORY_TYPES = {
	"creature": MinionContext,
	"spell": SpellContext
}

var EFFECT_FACTORY_TYPES = {
	"print_effect": PrintEffect,
	"target_damage_effect": TargetDamageEffect,
	"erase_target_effect": EraseTargetEffect,
	"apply_status": ApplyStatusEffect,
	"draw_cards": DrawCardsEffect,
	"on_spell_played_buff": SpellPlayedBuffEffect
}


@export var json_path := "res://data/cards.json"

var _cards_registry: Dictionary[String, CardData]

func init() -> void:
	_load_cards()

func get_from_registry(value: String) -> CardData:
	return _cards_registry.get(value, null)

func _load_cards() -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Cannot open cards.json")
		return
	
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid cards.json format")
		return
	
	for id in parsed.keys():
		_cards_registry[id] = _create_card_data(parsed[id])

func _create_card_data(raw: Dictionary) -> CardData:
	var card := CardData.new()
	card.name = raw.get("name", "UNKNOWN")
	card.cost = raw.get("cost", 0)
	card.image = load(raw.get("image", ""))
	
	card.card_context = _create_context(raw)
	
	var effects = raw.get("effects", {})
	card.card_context.on_draw_effects = _create_effects(effects.get("on_draw", {}))
	
	match card.card_context.get_card_type():
		Enums.CardType.SPELL:
			card.card_context.on_play_effects = _create_effects(effects.get("on_play", {}))
			card.card_context.on_draw_effects = _create_effects(effects.get("on_draw", {}))

		Enums.CardType.MINION:
			card.card_context.on_spawn_effects = _create_effects(effects.get("on_play", {}))
			card.card_context.on_attack_effects = _create_effects(effects.get("on_attack", {}))
			card.card_context.on_die_effects = _create_effects(effects.get("on_death", {}))
			card.card_context.passive_effects = _create_effects(effects.get("passive", {}))
	
	return card

func _create_context(raw: Dictionary) -> CardContext:
	var type = raw.get("card_type", "")
	if CARD_FACTORY_TYPES.has(type) == false:
		push_error("Unknown context type: %s" % type)
		return null
	
	var ctx = CARD_FACTORY_TYPES[type].new()
	_populate(ctx, raw)
	
	if ctx is MinionContext:
		var d = raw.get("portrait_offset", {})
		ctx.portrait_offset = Vector2(d.get("x", 0.0), d.get("y", 0.0))
		ctx.portrait_zoom = raw.get("portrait_zoom", 1)
	
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
	
	return result

func _populate(obj, d: Dictionary) -> void:
	var props = obj.get_property_list()
	
	for p in props:
		if d.has(p.name) == false:
			continue
		
		obj.set(p.name, d[p.name])
