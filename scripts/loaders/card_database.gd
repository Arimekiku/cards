class_name CardDatabase
extends Service

var KEYWORDS = {
	"damage": "first test: [url]another[/url] tooltip",
	"another": "second tooltip: [url]more[/url] tips",
	"more": "recursive into [url]another[/url] tooltip"
}

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
	"on_spell_played_buff": SpellPlayedBuffEffect,
	"summon_minion": SummonMinionEffect,
	"copy_minion": CopyMinionEffect,
	"discover_and_summon": DiscoverAndSummonEffect,
	"freeze_and_draw": FreezeAndDrawEffect,
	"discard_scaled_aoe": DiscardScaledAOEEffect,
	"discard_scaled_buff": DiscardScaledBuffEffect,
	"increase_future_copies": IncreaseFutureCopiesEffect
}

const TARGET_MAP := {
	"target": Enums.SpellTargetType.TARGET,
	"non_hero_target": Enums.SpellTargetType.NON_HERO_TARGET,
	"enemy_target": Enums.SpellTargetType.ENEMY_TARGET,
	"ally_target": Enums.SpellTargetType.ALLY_TARGET,
	"hero": Enums.SpellTargetType.HERO,
	"enemy_minions": Enums.SpellTargetType.ENEMY_MINIONS,
	"ally_minions": Enums.SpellTargetType.ALLY_MINIONS,
	"all_minions": Enums.SpellTargetType.ALL_MINIONS,
	"all": Enums.SpellTargetType.ALL,
	"self": Enums.SpellTargetType.SELF
}

@export var cards_dir := "res://data/cards/"

var _cards_registry: Dictionary[String, CardData]

func init() -> void:
	_load_cards_from_dir()

func _load_cards_from_dir() -> void:
	_cards_registry.clear()
	
	var dir := DirAccess.open(cards_dir)
	if dir == null:
		push_error("Cannot open cards dir: %s" % cards_dir)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			file_name = dir.get_next()
			continue
	
		if file_name.ends_with(".json"):
			_load_cards_file(cards_dir + file_name)
	
		file_name = dir.get_next()
	
	dir.list_dir_end()

func get_from_registry(value: String) -> CardData:
	return _cards_registry.get(value, null)

func _load_cards_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open cards file: %s" % path)
		return
	
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid cards.json format in %s" % path)
		return
	
	for id in parsed.keys():
		if _cards_registry.has(id):
			push_error("Duplicate card id: %s in %s" % [id, path])
			continue
	
		_cards_registry[id] = _create_card_data(parsed[id], id)

func _create_card_data(raw: Dictionary, id: String) -> CardData:
	var card := CardData.new()
	card.card_id = id
	card.name = raw.get("name", "UNKNOWN")
	card.cost = raw.get("cost", 0)
	card.tribes = raw.get("tribes", PackedStringArray())
	card.keywords = raw.get("keywords", PackedStringArray())
	card.image = load(raw.get("image", ""))
	
	card.card_context = _create_context(raw)
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
	for key in d.keys():
		var value = d[key]
		
		if key == "effects":
			for effect_group_name in value.keys():
				var effect_value = value[effect_group_name]
				var effects = _create_effects(effect_value)
				obj.set(effect_group_name, effects)
		
		if key == "on_copy_created":
			pass
		
		if value is Dictionary:
			var temp = obj.get(key)
			if temp is Array[CardEffect]:
				var effects = _create_effects(value)
				obj.set(key, effects)
		
		if key == "target":
			if TARGET_MAP.has(value):
				obj.set(key, TARGET_MAP[value])
			else:
				push_error("Unknown target type: %s" % value)
		else:
			obj.set(key, value)

func find_cards(predicate: Callable) -> Array[CardData]:
	var result: Array[CardData] = []
	
	for card in _cards_registry.values():
		if predicate.call(card):
			result.append(card)
	
	return result

#Приклад юзу
#var db: CardDatabase = ServiceLocator.get_service(CardDatabase)
#
#var beasts = db.find_cards(func(c):
	#return c.card_context.tribes.has("beast")
#)
