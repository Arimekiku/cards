extends Card
class_name MinionCard

var health: int
var damage: int

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != CardContext.CardType.MINION:
		push_error("Wrong type expected MINION, got: %s" % type)
		return
	
	data = card_data
	health = data.card_context.health
	damage = data.card_context.damage
	
	$graphics.texture = data.image
	#$NameLabel.text = data.name
	#$CostLabel.text = str(data.cost)
	_ui_update_health(health)
	_ui_update_damage(damage)

func input_phase(event: InputEventMouseButton) -> void:
	pass

func take_damage(value: int) -> void:
	if (health - value < 0):
		queue_free()
	
	health -= value
	_ui_update_health(health)

func _ui_update_health(value: int) -> void:
	$interface/text_box/health_panel/health.text = str(value)

func _ui_update_damage(value: int) -> void:
	$interface/text_box/damage_panel/damage.text = str(value)
