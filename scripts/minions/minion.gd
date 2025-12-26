class_name Minion
extends Control

@onready var potential_targets: Array[Node] = []

@onready var health_text := %health
@onready var damage_text := %damage
@onready var collision_detector: Area2D = %collider_detector
@onready var character_icon := %character_icon

signal died_event(minion: Minion)

var health: int
var damage: int
var data: CardData
var has_attacked: bool
var state_machine: MinionStateMachine
var minion_owner := Enums.CharacterType.PLAYER

func setup(card_data: CardData) -> void:
	if not self.is_node_ready(): await self.ready
	 
	var context := card_data.card_context as MinionContext
	if context == null:
		push_error("Wrong type expected MINION")
		return
	
	var states := [
		MinionIdleState.new(),
		MinionAimState.new(),
		MinionAttackState.new(),
	]
	state_machine = MinionStateMachine.new(self, states, MinionIdleState)
	
	data = card_data
	health = context.health
	damage = context.damage
	
	character_icon.texture = card_data.image
	var mat: Material = character_icon.material.duplicate()
	mat.set_shader_parameter("offset", context.portrait_offset)
	mat.set_shader_parameter("zoom", context.portrait_zoom)
	character_icon.material = mat
	
	_ui_update_health(health)
	_ui_update_damage(damage)
	_resolve_effects(context.on_spawn_effects, self)

func _input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_input(event)

func take_damage(value: int) -> void:
	health -= value
	
	if health <= 0:
		died_event.emit(self)
		_resolve_effects(data.card_context.on_die_effects, null)
		return
	
	_ui_update_health(health)

func attack(target) -> void:
	target.take_damage(damage)
	if target is Minion:
		take_damage(target.damage)
	
	_resolve_effects(data.card_context.on_attack_effects, null)

func _on_gui_input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	if not state_machine: return
	state_machine.on_mouse_enter()

func _on_mouse_exited() -> void:
	if not state_machine: return
	state_machine.on_mouse_exit()

func _resolve_effects(effects: Array[CardEffect], context) -> void:
	for effect in effects:
		effect.resolve(context)

func _ui_update_health(value: int) -> void:
	%health.text = str(value)

func _ui_update_damage(value: int) -> void:
	%damage.text = str(value)
