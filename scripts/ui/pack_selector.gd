extends Control

@export var pack_selects: Array[PackSelect]
@export var character_box: CharacterBox
@export var card_remover: Node

func _ready() -> void:
	for pack in pack_selects:
		pack.on_pack_selected.connect(_on_pack_select)

func _on_pack_select(context: PackSelect) -> void:
	character_box.add_deck(context.pack_metadata)
	
	for pack in pack_selects:
		var button: Button = pack.pick_button
		button.disabled = true
	
	if context.remove_count == 0: return
	card_remover.enable_with_count(context.remove_count)
