extends Node2D
class_name Game

@export var player: CharacterRuntime
@export var enemy: CharacterRuntime

@export var start_hand_size := 5

var player_deck_metadata: DeckMetadata
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

signal spell_played(owner_type)

func emit_spell_played(owner_type):
	spell_played.emit(owner_type)

func initialize_game(deck_metadata: DeckMetadata) -> void:
	player_deck_metadata = deck_metadata

func create_card(value: String) -> Card:
	var data := card_database.get_from_registry(value)
	if data == null:
		push_error("Unable to retrieve data from key: %s" % value)
		return null
	
	return create_card_from_data(data)

static func create_card_from_data(value: CardData) -> Card:
	var card: Card
	
	match value.card_context.get_card_type():
		Enums.CardType.MINION:
			var minion_card_scene = preload("res://scenes/cards/minion_card_prefab.tscn")
			card = minion_card_scene.instantiate() as Card
		Enums.CardType.SPELL:
			var spell_card_scene = preload("res://scenes/cards/spell_card_prefab.tscn")
			card = spell_card_scene.instantiate() as Card
		_:
			push_warning("Unknown card type")
			return null
	
	card.setup(value)
	return card

func create_minion_from_name(value: String) -> Minion:
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
