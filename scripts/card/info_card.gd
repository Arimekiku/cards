class_name InfoCard
extends Control

@export var minion_front: Texture2D
@export var spell_front: Texture2D

@onready var status_container := $graphics/status_container
@onready var close_timer := $disappear_timer

var status_prefab := preload("res://scenes/cards/info_cards/card_status.tscn")

func _ready() -> void:
	close_timer.one_shot = true
	close_timer.timeout.connect(_on_timer_timeout)

func setup(context) -> void:
	for child in status_container.get_children():
		child.queue_free()
	
	var data = context if context is not Minion else context.data
	var type = data.card_context.get_card_type()
	match type:
		Enums.CardType.MINION: _configure_for_minion(context)
		Enums.CardType.SPELL: _configure_for_spell(context)
	
	%cost_text.text = str(data.cost)
	%name_text.text = data.name
	%portrait_image.texture = data.image

func _configure_for_minion(context) -> void:
	var data = context
	
	if context is Minion:
		for status in context.statuses:
			var instance: CardStatus = status_prefab.instantiate()
			status_container.add_child(instance)
			
			instance.text_title.text = status.get_script().get_global_name()
			instance.text_description.text = "Description"
		data = context.data
	
	$graphics/outline.texture = minion_front
	%description_text.visible = false
	
	%health.visible = true
	%health.text = str(data.card_context.health)
	
	%damage.visible = true
	%damage.text = str(data.card_context.damage)

func _configure_for_spell(card_data: CardData) -> void:
	$graphics/outline.texture = spell_front
	%health.visible = false
	%damage.visible = false
	
	%description_text.visible = true
	%description_text.text = card_data.card_context.description

func _on_mouse_entered() -> void:
	if not is_node_ready(): await ready
	
	set_disappear(false)

func _on_mouse_exited() -> void:
	if not is_node_ready(): await ready
	
	set_disappear(true)

func _on_timer_timeout() -> void:
	hide()

func set_disappear(value: bool) -> void:
	if value == false:
		show()
		close_timer.stop()
		return
	
	close_timer.start()
