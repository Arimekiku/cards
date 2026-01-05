class_name Minion
extends Control

@onready var potential_targets: Array[Node] = []

@onready var health_text := %health
@onready var damage_text := %damage
@onready var collision_detector: Area2D = %collider_detector

var _pending_owner_apply := false

@onready var character_icon := %character_icon

signal died_event(minion: Minion, cause: Enums.DeathCause)
signal attack_finished(minion: Minion)

var health: int
var damage: int
var data: CardData
var has_attacked: bool
var state_machine: MinionStateMachine
var minion_owner := Enums.CharacterType.PLAYER
var is_ai_intent: bool = false
var current_target: Node = null

var statuses: Array = []
var can_attack: bool = true

var event_bus: EventBus = ServiceLocator.get_service(EventBus)

func _ready():
	if _pending_owner_apply:
		_apply_owner_settings()
		
func setup(card_data: CardData, is_summoned := false) -> void:
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
	
	if not is_summoned:
		_resolve_effects(context.on_spawn_effects, self)
	
	for effect in context.passive_effects:
		effect.resolve(self)
		
	var events: EventBus = ServiceLocator.get_service(EventBus)
	events.minion_spawned.emit(self)
	
	#for effect in context.passive_effects:
		#if effect.has("status_name"):
			#var status_name = effect.status_name
			#var duration = -1
			#if effect.has("duration"):
				#duration = effect.duration
			#add_status(status_name, duration)

func _input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_input(event)

func take_damage(value: int) -> void:
	health -= value
	
	if health <= 0:
		die(Enums.DeathCause.NORMAL)
		return
	
	_ui_update_health(health)

func die(cause: Enums.DeathCause = Enums.DeathCause.NORMAL) -> void:
	if cause == Enums.DeathCause.NORMAL:
		_resolve_effects(data.card_context.on_die_effects, self)
		
	died_event.emit(self, cause)

	for s in statuses.duplicate():
		if s.has_method("remove"):
			s.remove()

	statuses.clear()

func attack(target: Node) -> void:
	if not can_attack:
		return
	
	if not is_instance_valid(target):
		return
	
	target.take_damage(damage)
	
	if target is Minion and is_instance_valid(self):
		take_damage(target.damage)
	
	_resolve_effects(data.card_context.on_attack_effects, target)

func _on_gui_input(event: InputEvent) -> void:
	if not state_machine: return
	state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	event_bus.minion_info_show_request.emit(self)
	
	if not state_machine: return
	state_machine.on_mouse_enter()

func _on_mouse_exited() -> void:
	event_bus.minion_info_destroy_request.emit(self)
	
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

func request_attack(target_node: Node) -> bool:
	if has_attacked:
		return false
	if not can_attack:
		return false
	
	is_ai_intent = true
	current_target = target_node
	state_machine.request_state(MinionAttackState)
	return true

func add_status(status_name: String, duration: int, params := {}) -> void:
	# створюємо інстанс статусу за іменем
	match status_name:
		"freeze":
			var s = FreezeStatus.new(duration)
			s.apply(self)
			statuses.append(s)
		"taunt":
			var s = TauntStatus.new()
			s.apply(self)
			statuses.append(s)
		"spell_fury":
			var s = SpellFuryStatus.new()
			s.duration = duration
			s.apply(self)
			statuses.append(s)
			
		"buff":
			print("buff")
			var s = BuffStatus.new(
				params.get("attack", 0),
				params.get("health", 0),
				duration
			)
			s.duration = duration
			s.apply(self)
			statuses.append(s)
		_:
			# тут можна додати інші статуси/реєстр
			push_warning("Unknown status: %s" % status_name)

func remove_status(status_instance) -> void:
	statuses.erase(status_instance)

func set_can_attack(value: bool) -> void:
	can_attack = value

func on_turn_start() -> void:
	# обробка статусів
	for s in statuses.duplicate():
		if s.has_method("on_turn_start"):
			s.on_turn_start()
			
	_resolve_effects(data.card_context.on_turn_start_effects, self)
