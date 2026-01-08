class_name DeckPresenter
extends CanvasLayer

signal on_card_clicked(card: InfoCard)

@export var can_close_voluntarily: bool = true

@onready var card_container: GridContainer = %card_container
@onready var close_button: Button = %close_window_button

var card_instances: Array[InfoCard]
var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
var info_card_prefab := preload("res://scenes/cards/info_cards/info_card_prefab.tscn")

func _ready() -> void:
	for child in card_container.get_children():
		child.queue_free()
	
	close_button.visible = can_close_voluntarily

func show_deck_names(deck: Array[String]) -> void:
	for child in card_container.get_children():
		child.queue_free()
	
	for card_name in deck:
		var data: CardData = card_database.get_from_registry(card_name)
		var instance: InfoCard = info_card_prefab.instantiate()
		instance.should_disappear = false
		
		card_container.add_child(instance)
		card_instances.append(instance)
		
		instance.setup(data)
		instance.on_card_clicked.connect(_on_card_pressed)
	show()

func show_deck(deck: Array[CardData]) -> void:
	for child in card_container.get_children():
		child.queue_free()
	
	for data in deck:
		var instance: InfoCard = info_card_prefab.instantiate()
		instance.should_disappear = false
		card_container.add_child(instance)
		
		instance.setup(data)
		instance.on_card_clicked.connect(_on_card_pressed)
	show()

func remove_card(card: InfoCard) -> void:
	card_instances.erase(card)
	card.queue_free()

func _on_card_pressed(card: InfoCard) -> void:
	on_card_clicked.emit(card)
