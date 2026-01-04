extends CanvasLayer

@onready var card_container: GridContainer = %card_container

var info_card_prefab := preload("res://scenes/cards/info_cards/info_card_prefab.tscn")

func _ready() -> void:
	for child in card_container.get_children():
		child.queue_free()

func show_deck(deck: Array[CardData]) -> void:
	for child in card_container.get_children():
		child.queue_free()
	
	for data in deck:
		var instance: InfoCard = info_card_prefab.instantiate()
		card_container.add_child(instance)
		
		instance.setup(data)
	show()
