extends Node

@export var deck_presenter: DeckPresenter
@export var character_box: CharacterBox

var remove_count: int

func _ready() -> void:
	deck_presenter.on_card_clicked.connect(_on_card_clicked)

func enable_with_count(value: int) -> void:
	remove_count = value
	
	deck_presenter.show_deck_names(character_box.character_metadata.deck.cards)

func _on_card_clicked(card: InfoCard) -> void:
	if remove_count - 1 == 0: deck_presenter.hide()
	
	var data = card.info_data
	character_box.try_remove_card(data.card_id)
	deck_presenter.remove_card(card)
	
	remove_count -= 1
