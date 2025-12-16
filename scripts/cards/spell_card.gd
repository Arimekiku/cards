extends Card

@export var _description_text: RichTextLabel
@export var _image_picker: Sprite2D

func parse_card_data(data: CardData) -> void:
	var card_context = data.card_context as SpellContext
	if card_context == null:
		print(error_string(ERR_CANT_CREATE))
		return
	
	_image_picker.texture = data.image
	_description_text.text = str(card_context.description)
	_effects = data.effects
