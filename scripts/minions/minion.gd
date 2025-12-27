class_name Minion
extends Control

@onready var potential_targets: Array[Node] = []

@onready var health_text := %health
@onready var damage_text := %damage
@onready var collision_detector: Area2D = %collider_detector

var _pending_owner_apply := false

@onready var character_icon := %character_icon

signal died_event(minion: Minion)
signal attack_finished(minion: Minion)

var health: int
var damage: int
var data: CardData
var has_attacked: bool
var state_machine: MinionStateMachine
var minion_owner := Enums.CharacterType.PLAYER
var is_ai_intent: bool = false
var current_target: Node = null

func _ready():
	if _pending_owner_apply:
		_apply_owner_settings()
		
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
	
	for effect in context.passive_effects:
		effect.apply(self)

func _input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_input(event)

func take_damage(value: int) -> void:
	health -= value
	
	if health <= 0:
		died_event.emit(self)
		_resolve_effects(data.card_context.on_die_effects, null)
		for effect in data.card_context.passive_effects:
			effect.remove(self)
		return
	
	_ui_update_health(health)

func attack(target: Node) -> void:
	if not is_instance_valid(target):
		return

	target.take_damage(damage)

	if target is Minion and is_instance_valid(self):
		take_damage(target.damage)

	_resolve_effects(
		data.card_context.on_attack_effects,
		target
	)


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

func _set_owned(owned):
	minion_owner = owned
	if is_node_ready():
		_apply_owner_settings()
	else:
		_pending_owner_apply = true

func _apply_owner_settings():
	if minion_owner == Enums.CharacterType.ENEMY:
		add_to_group("enemy_minions")
		remove_from_group("player_minions")
		collision_detector.set_collision_layer_value(3, true)  # ENEMY
		collision_detector.set_collision_layer_value(4, false)
	else:
		add_to_group("player_minions")
		remove_from_group("enemy_minions")
		collision_detector.set_collision_layer_value(4, true)  # PLAYER
		collision_detector.set_collision_layer_value(3, false)

func request_attack(target_node: Node) -> void:
	if has_attacked:
		return

	is_ai_intent = true
	current_target = target_node
	state_machine.request_state(MinionAttackState)
