class_name CharacterBox
extends Button

@onready var character_label := %character_name
@onready var card_container := %cards_container

var character_name: String
var initial_deck: DeckMetadata

func setup(character: CharacterMetadata) -> void:
	character_name = character.character_name
	initial_deck = character.deck
	character_label.text = character_name
	
	var previews = card_container.get_children()
	for preview in previews:
		preview.queue_free()
	
	var card_map: Dictionary[String, int]
	for card_id in initial_deck.cards:
		var data = CardDatabase.get_from_registry(card_id)
		if data == null:
			push_error("Can't get requested card of type %s!" % card_id)
			continue
		
		if card_map.has(card_id) == false: card_map[card_id] = 0
		card_map[card_id] += 1
	
	var container_prefab = preload("res://scenes/card_panel.tscn")
	for card_id in card_map:
		var quantity = card_map[card_id]
		
		var instance: CardPanelMinimized = container_prefab.instantiate()
		card_container.add_child(instance)
		
		instance.name = card_id
		instance.setup(card_id, quantity)

func _pressed() -> void:
	var scenetype = Scenes.SceneType.BATTLE_SCENE
	var result = Scenes.switch_scene(scenetype, initial_deck)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(Scenes.SceneType.keys()[scenetype]))
