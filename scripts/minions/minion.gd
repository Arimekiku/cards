class_name Minion
extends Control

@onready var potential_targets: Array[Node] = []

@onready var health_text := %health
@onready var damage_text := %damage
@onready var collision_detector: Area2D = %collider_detector

signal died_event(minion: Minion)

var health: int
var damage: int
var data: CardData
var has_attacked: bool
var state_machine: MinionStateMachine
var minion_owner := Enums.CharacterType.PLAYER

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != Enums.CardType.MINION:
		push_error("Wrong type expected MINION, got: %s" % type)
		return
	
	var states := [
		MinionIdleState.new(),
		MinionAimState.new(),
		MinionAttackState.new(),
	]
	state_machine = MinionStateMachine.new(self, states, MinionIdleState)
	
	data = card_data
	health = card_data.card_context.health
	damage = card_data.card_context.damage
	
	%character_icon.texture = card_data.image
	_ui_update_health(health)
	_ui_update_damage(damage)

func _input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_input(event)

func take_damage(value: int) -> void:
	health -= value
	
	if health <= 0:
		died_event.emit(self)
		return
	
	_ui_update_health(health)

func attack(target: Minion) -> void:
	target.take_damage(damage)
	take_damage(target.damage)

func _on_gui_input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	if not state_machine: return
	state_machine.on_mouse_enter()

func _on_mouse_exited() -> void:
	if not state_machine: return
	state_machine.on_mouse_exit()

func _ui_update_health(value: int) -> void:
	%health.text = str(value)

func _ui_update_damage(value: int) -> void:
	%damage.text = str(value)
