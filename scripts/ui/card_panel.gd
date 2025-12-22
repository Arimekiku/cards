extends PanelContainer
class_name CardPanelMinimized

@onready var card_name := %card_name
@onready var card_quatity := %card_quatity

func setup(c_name: String, quantity: int) -> void:
	card_name.text = c_name
	card_quatity.text = str(quantity)
