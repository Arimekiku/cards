extends Node2D
class_name Game

@export var player: CharacterRuntime
@export var enemy: CharacterRuntime
@onready var hand := %hand

func initialize_game(deck_metadata: DeckMetadata) -> void:
	player.init(deck_metadata)

static func create_card(value: String) -> Card:
	var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
	var data := card_database.get_from_registry(value)
	if data == null:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	return create_card_from_data(data)

static func create_card_from_data(value: CardData) -> Card:
	var minion_card_scene = load("res://scenes/cards/minion_card_prefab.tscn")
	var spell_card_scene = load("res://scenes/cards/spell_card_prefab.tscn")
	var card: Card
	
	match value.card_context.get_card_type():
		Enums.CardType.MINION:
			card = minion_card_scene.instantiate() as Card
		Enums.CardType.SPELL:
			card = spell_card_scene.instantiate() as Card
		_:
			push_warning("Unknown card type")
			return null
	
	card.setup(value)
	return card

static func create_minion_from_name(value: String) -> Minion:
	var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
	var data := card_database.get_from_registry(value)
	if data == null or data.card_context.get_card_type() != Enums.CardType.MINION:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	var minion = create_minion()
	minion.setup(data)
	return minion

static func create_minion() -> Minion:
	var temp_minion_scene := load("res://scenes/minion.tscn")
	
	var minion: Minion = temp_minion_scene.instantiate()
	return minion

func get_character(character_type: Enums.CharacterType) -> CharacterRuntime:
	return player if character_type == Enums.CharacterType.PLAYER else enemy
