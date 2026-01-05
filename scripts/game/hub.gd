extends Control

@export var character_box: CharacterBox

var character_metadata: CharacterMetadata

func load_with_cards(character: CharacterMetadata) -> void:
	character_metadata = character

func _ready() -> void:
	character_box.setup(character_metadata)
