extends Control

@export var pack_selects: Array[PackSelect]
@export var character_box: CharacterBox

func _ready() -> void:
	for pack in pack_selects:
		pack.on_pack_selected.connect(_on_pack_select)

func _on_pack_select(pack_meta: DeckMetadata) -> void:
	character_box.add_deck(pack_meta)
	
	for pack in pack_selects:
		var button: Button = pack.pick_button
		button.disabled = true
