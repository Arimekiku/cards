extends Card

@export var _health_text: RichTextLabel
@export var _damage_text: RichTextLabel
@export var _image_picker: Sprite2D

func parse_card_data(data: CardData) -> void:
	var card_context = data.card_context as MinionContext
	if card_context == null:
		print(error_string(ERR_CANT_CREATE))
		return
	
	_image_picker.texture = data.image
	_health_text.text = str(card_context.health)
	_damage_text.text = str(card_context.damage)
	_effects = data.effects
