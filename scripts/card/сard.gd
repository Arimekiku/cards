extends Node2D
class_name Card

signal hovered(card)
signal exited(card)

var data: CardData
var placed := false

func setup(card_data: CardData) -> void:
	data = card_data

	#$CardImage.texture = data.image
	#$NameLabel.text = data.name
	#$CostLabel.text = str(data.cost)

	match data.card_context.get_card_type():
		CardContext.CardType.MINION:
			$interface/text_box/health_panel.visible = true
			$interface/text_box/damage_panel.visible = true
			$interface/text_box/health_panel/health.text = str(data.card_context.health)
			$interface/text_box/damage_panel/damage.text = str(data.card_context.damage)
		CardContext.CardType.SPELL:
			$interface/text_box/health_panel.visible = false
			$interface/text_box/damage_panel.visible = false


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("exited", self)
