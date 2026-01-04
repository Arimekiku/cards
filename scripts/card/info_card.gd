class_name InfoCard
extends Control

@export var minion_front: Texture2D
@export var spell_front: Texture2D

var close_timer: Timer

func _ready() -> void:
	close_timer.one_shot = true
	close_timer.timeout.connect(_on_timer_timeout)

func setup(minion: Minion) -> void:
	var type = minion.data.card_context.get_card_type()
	match type:
		Enums.CardType.MINION: _configure_for_minion(minion.data)
		Enums.CardType.SPELL: _configure_for_spell(minion.data)
	
	%cost_text.text = str(minion.data.cost)
	%name_text.text = minion.data.name
	%portrait_image.texture = minion.data.image

func _configure_for_minion(card_data: CardData) -> void:
	$graphics/outline.texture = minion_front
	%description_text.visible = false
	
	%health.visible = true
	%health.text = str(card_data.card_context.health)
	
	%damage.visible = true
	%damage.text = str(card_data.card_context.damage)

func _configure_for_spell(card_data: CardData) -> void:
	$graphics/outline.texture = spell_front
	%health.visible = false
	%damage.visible = false
	
	%description_text.visible = true
	%description_text.text = card_data.card_context.description

func _on_mouse_entered() -> void:
	close_timer.stop()

func _on_mouse_exited() -> void:
	close_timer.start()

func _on_timer_timeout() -> void:
	scale = Vector2.ZERO
