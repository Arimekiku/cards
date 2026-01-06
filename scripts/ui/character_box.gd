class_name CharacterBox
extends Control

@export var character_label: Label
@export var card_container: Control

var container_prefab = preload("res://scenes/card_panel.tscn")
var card_map: Dictionary[String, int]
var minimal_ui_map: Dictionary[String, CardPanelMinimized]

var character_metadata: CharacterMetadata
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)

func setup(character: CharacterMetadata) -> void:
	character_metadata = character
	character_label.text = character.character_name
	
	var previews = card_container.get_children()
	for preview in previews:
		preview.queue_free()
	
	for card_id in character_metadata.deck.cards:
		var data = card_database.get_from_registry(card_id)
		if data == null:
			push_error("Can't get requested card of type %s!" % card_id)
			continue
		
		if card_map.has(card_id) == false: card_map[card_id] = 0
		card_map[card_id] += 1
	
	for card_id in card_map:
		var quantity = card_map[card_id]
		
		var instance: CardPanelMinimized = container_prefab.instantiate()
		card_container.add_child(instance)
		
		instance.name = card_id
		instance.setup(card_id, quantity)
		minimal_ui_map[card_id] = instance

func add_deck(deck: DeckMetadata) -> void:
	for card_id in deck.cards:
		var data = card_database.get_from_registry(card_id)
		if data == null:
			push_error("Can't get requested card of type %s!" % card_id)
			continue
		
		if card_map.has(card_id) == false: card_map[card_id] = 0
		card_map[card_id] += 1
		character_metadata.deck.cards.append(card_id)
	
	for card_id in card_map:
		var quantity = card_map[card_id]
		
		var instance: CardPanelMinimized = minimal_ui_map.get(card_id, null)
		if instance == null:
			instance = container_prefab.instantiate()
			card_container.add_child(instance)
			
			instance.name = card_id
			minimal_ui_map[card_id] = instance
		
		instance.setup(card_id, quantity)
