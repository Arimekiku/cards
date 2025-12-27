#=== FILE: g:\godot\cards\scripts\card_board.gd ===
#class_name CardBoard
#extends Node2D
#
#var game: Game
#@export var graphics : Sprite2D
#var board_owner := Enums.CharacterType.PLAYER
#@export var max_minions := 7
#@export var spacing := 160.0
#@export var drop_radius := 200.0
#@export var deck: Deck
#
#var minions: Array[Minion] = []
#
#func init() -> void:
#if board_owner == Enums.CharacterType.PLAYER: return;
#
#var minion := game.create_minion_from_name("frost_frog")
#minion.minion_owner = Enums.CharacterType.ENEMY
#add_minion(minion)
#var minion2 := game.create_minion_from_name("frost_frog")
#minion2.minion_owner = Enums.CharacterType.ENEMY
#add_minion(minion2)
#var minion3 := game.create_minion_from_name("frost_frog")
#minion3.minion_owner = Enums.CharacterType.ENEMY
#add_minion(minion3)
#
#func add_minion(minion: Minion) -> bool:
#if minions.size() >= max_minions: return false
#
#minions.append(minion)
#if minion.get_parent(): minion.reparent(self)
#else: add_child(minion)
#minion.position = Vector2.ZERO
#minion.died_event.connect(_on_minion_died)
#
#var is_enemy = minion.minion_owner == Enums.CharacterType.ENEMY
#minion.collision_detector.set_collision_layer_value(3, is_enemy)
#minion.collision_detector.set_collision_layer_value(4, not is_enemy)
#minion.collision_detector.set_collision_mask_value(3, not is_enemy)
#minion.collision_detector.set_collision_mask_value(4, is_enemy)
#
#layout()
#return true
#
#func remove_minion(minion: Minion) -> void:
#minions.erase(minion)
#layout()
#
#func layout() -> void:
#var count := minions.size()
#if count == 0:
#return
#
#var total_width = spacing * (count - 1)
#var start_x = -total_width / 2.0
#
#for i in count:
#var offset := minions[i].size / 2
#var target := Vector2(global_position.x + start_x + i * spacing, global_position.y)
#_normalize_minion(minions[i], target - offset)
#
#func can_accept(minion: Minion) -> bool:
#if minion.minion_owner != board_owner: return false
#return minions.size() < max_minions
#
#func _on_turn_started(turn):
#if turn != board_owner: return
#
#for minion in minions:
#minion.has_attacked = false
#
#func _normalize_minion(minion: Minion, target: Vector2) -> void:
#var tween = create_tween()
#tween.tween_property(minion, "global_position", target, 0.25)\
#.set_trans(Tween.TRANS_QUAD)\
#.set_ease(Tween.EASE_OUT)
#
#func _on_minion_died(minion: Minion) -> void:
#remove_minion(minion)
#deck.add_to_discard_pile(minion)
#minion.queue_free()
#
#
#=== FILE: g:\godot\cards\scripts\text_wobble.gd ===
#extends Node2D
#class_name RainbowWobbleText
#
#@export var text: String = "HELLO GODOT!"
#@export var char_spacing: float = 24.0
#@export var wobble_amplitude: float = 5.0
#@export var wobble_frequency: float = 5.0
#@export var rainbow_speed: float = 0.5
#@export var font: Font
#
#var chars: Array = []
#var elapsed: float = 0.0
#
#func _ready():
#_create_chars()
#
#func _process(delta: float) -> void:
#elapsed += delta
#_update_chars()
#
#func _create_chars() -> void:
#var x_offset := -text.length() * char_spacing / 2.
#for c in text:
#var label := Label.new()
#label.text = c
#label.position = Vector2(x_offset, 0)
#
#if font != null:
#label.set("custom_fonts/font", font)
#
#add_child(label)
#chars.append(label)
#x_offset += char_spacing
#
#func _update_chars() -> void:
#for i in chars.size():
#var char_s = chars[i]
#
#char_s.position.y = sin(elapsed * wobble_frequency + i * 0.5) * wobble_amplitude
#char_s.rotation = sin(elapsed * wobble_frequency + i * 0.5) * 0.1
#char_s.scale = Vector2.ONE * (1.0 + 0.1 * sin(elapsed * wobble_frequency + i * 0.5))
#
#var hue = fmod(i * 0.1 + elapsed * rainbow_speed, 1.0)
#char_s.modulate = Color.from_hsv(hue, 1.0, 1.0)
#
#
#=== FILE: g:\godot\cards\scripts\card\minion_card.gd ===
#class_name MinionCard
#extends Card
#
#@onready var collision_detector := %collision_detector
#
#func setup(card_data: CardData) -> void:
#var type = card_data.card_context.get_card_type()
#if type != Enums.CardType.MINION:
#push_error("Wrong type expected MINION, got: %s" % type)
#return
#
#var states := [
#CardIdleState.new(),
#CardClickedState.new(),
#CardDragState.new(),
#CardReleasedState.new()
#]
#state_machine = CardStateMachine.new(self, states, CardIdleState)
#
#data = card_data
#%portrait_image.texture = card_data.image
#$NameLabel.text = data.name
#%cost_text.text = str(card_data.cost)
#%health.text = str(card_data.card_context.health)
#%damage.text = str(card_data.card_context.damage)
#
#func play() -> void:
#var output_zone: CardBoard
#var minion := Game.create_minion()
#get_tree().current_scene.add_child(minion)
#minion.setup(data)
#
#for in_zone: CardBoard in get_tree().get_nodes_in_group("card_zones"):
#if not in_zone.can_accept(minion): continue
#
#output_zone = in_zone
#break
#
#output_zone.add_minion(minion)
#played_event.emit(self)
#
#func _on_collision_detector_area_entered(area: Area2D) -> void:
#super(area)
#
#func _on_collision_detector_area_exited(area: Area2D) -> void:
#super(area)
#
#func _on_gui_input(event: InputEvent) -> void:
#super(event)
#
#func _on_mouse_entered() -> void:
#super()
#
#func _on_mouse_exited() -> void:
#super()
#
#
#=== FILE: g:\godot\cards\scripts\card\spell_card.gd ===
#class_name SpellCard
#extends Card
#
#@onready var collision_detector := %collision_detector
#
#func setup(card_data: CardData) -> void:
#var type = card_data.card_context.get_card_type()
#if type != Enums.CardType.SPELL:
#push_error("Wrong type expected SPELL, got: %s" % type)
#return
#
#var states := [
#CardIdleState.new(),
#CardClickedState.new(),
#CardDragState.new(),
#CardReleasedState.new(),
#CardAimState.new()
#]
#state_machine = CardStateMachine.new(self, states, CardIdleState)
#
#data = card_data
#%portrait_image.texture = data.image
#$NameLabel.text = data.name
#%cost_text.text = str(data.cost)
#%description_text.text = data.card_context.description
#
#func play() -> void:
#if potential_targets.is_empty(): return
#var context = potential_targets[0].get_parent()
#
#if not context.has_method("take_damage"):
#push_error("Invalid spell target")
#return
#
#for effect in data.card_context.on_play_effects:
#effect.resolve(context)
#
#played_event.emit(self)
#
#
#func _on_collision_detector_area_entered(area: Area2D) -> void:
#super(area)
#
#func _on_collision_detector_area_exited(area: Area2D) -> void:
#super(area)
#
#func _on_gui_input(event: InputEvent) -> void:
#super(event)
#
#func _on_mouse_entered() -> void:
#super()
#
#func _on_mouse_exited() -> void:
#super()
#
#
#=== FILE: g:\godot\cards\scripts\card\сard.gd ===
#@abstract
#class_name Card
#extends Control
#
#@warning_ignore("unused_signal")
#signal reparent_event(card: Card)
#@warning_ignore("unused_signal")
#signal played_event(card: Card)
#
#var parent: Control
#var tween: Tween
#var state_machine: CardStateMachine
#var data: CardData
#var card_owner := Enums.CharacterType.PLAYER
#
#@onready var potential_targets: Array[Node] = []
#
#@abstract func setup(card_data: CardData) -> void
#@abstract func play() -> void
#
#func _input(event: InputEvent) -> void:
#if not state_machine: return
#state_machine.on_input(event)
#
#func animate_to_position(new_position: Vector2, duration: float) -> void:
#tween = create_tween()\
#.set_trans(Tween.TRANS_CIRC)\
#.set_ease(Tween.EASE_OUT)
#
#tween.tween_property(self, "global_position", new_position, duration)
#
#func _on_gui_input(event: InputEvent) -> void:
#if not state_machine: return
#state_machine.on_gui_input(event)
#
#func _on_mouse_entered() -> void:
#if not state_machine: return
#state_machine.on_mouse_enter()
#
#func _on_mouse_exited() -> void:
#if not state_machine: return
#state_machine.on_mouse_exit()
#
#func _on_collision_detector_area_entered(area: Area2D) -> void:
#if potential_targets.has(area): return
#potential_targets.push_back(area)
#
#func _on_collision_detector_area_exited(area: Area2D) -> void:
#potential_targets.erase(area)
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_aim_state.gd ===
#class_name CardAimState
#extends CardBaseState
#
#const MOUSE_MINIMAL_Y_THRESHOLD := 600
#const BASIC_CARD_Y_UPPRISING := 100
#
#var events: EventBus = ServiceLocator.get_service(EventBus)
#
#func enter() -> void:
#var offset := Vector2(target.parent.size.x / 2, -target.size.y / 2)
#offset.x -= target.size.x / 2
#offset.y -= BASIC_CARD_Y_UPPRISING
#target.animate_to_position(target.parent.global_position + offset, 0.2)
#target.collision_detector.monitoring = false
#
#_highlight_targets(Color.GREEN)
#events.target_selector_called_event.emit(target)
#
#func exit() -> void:
#_highlight_targets(Color.WHITE)
#events.target_selector_discard_event.emit(target)
#
#func on_input(event: InputEvent) -> void:
#var mouse_at_bottom := target.get_global_mouse_position().y > MOUSE_MINIMAL_Y_THRESHOLD
#if mouse_at_bottom or event.is_action_pressed("right_mouse"):
#transition.emit(self, CardIdleState)
#return
#
#if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
#target.get_viewport().set_input_as_handled()
#transition.emit(self, CardReleasedState)
#
#func _highlight_targets(color: Color) -> void:
#for in_zone: CardBoard in target.get_tree().get_nodes_in_group("card_zones"):
#for minion in in_zone.minions:
#minion.modulate = color
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_base_state.gd ===
#@abstract
#class_name CardBaseState
#extends BaseState
#
#var target: Card
#
#func on_input(_event: InputEvent) -> void:
#pass
#
#func on_gui_input(_event: InputEvent) -> void:
#pass
#
#func on_mouse_enter() -> void:
#pass
#
#func on_mouse_exit() -> void:
#pass
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_clicked_state.gd ===
#class_name CardClickedState
#extends CardBaseState
#
#func enter() -> void:
#target.collision_detector.monitoring = true
#
#func on_input(event: InputEvent) -> void:
#if event is not InputEventMouseMotion:
#return
#
#transition.emit(self, CardDragState)
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_drag_state.gd ===
#class_name CardDragState
#extends CardBaseState
#
#func enter() -> void:
#var ui_control := target.get_tree().get_first_node_in_group("battle_ui_layer")
#if not ui_control: return
#
#target.rotation = 0
#target.reparent(ui_control)
#
#func on_input(event: InputEvent) -> void:
#if target.potential_targets.size() > 0:
#if _check_for_mana() == false: return
#
#var motion := event is InputEventMouseMotion
#if motion:
#var relative_mouse = target.get_global_mouse_position()
#target.global_position = relative_mouse - target.pivot_offset
#
#match target.get_script():
#SpellCard: _handle_spell(event)
#MinionCard: _handle_creature(event)
#
#func _check_for_mana() -> bool:
#var game := target.get_tree().get_first_node_in_group("game") as Game
#var character := game.get_character(target.card_owner)
#
#if character.mana.current_mana < target.data.cost:
#if target.tween and target.tween.is_running(): return false
#
#target.modulate = Color.RED
#target.tween = target.create_tween()
#target.tween.tween_property(target, "global_position:x", 10.0, 0.05).as_relative()
#target.tween.tween_property(target, "global_position:x", -10.0, 0.05).as_relative()
#target.tween.set_loops(3)
#target.tween.finished.connect(
#func(): 
#target.modulate = Color.WHITE
#transition.emit(self, CardIdleState)
#)
#return false
#
#return true
#
#func _handle_spell(event: InputEvent) -> void:
#var motion := event is InputEventMouseMotion
#if not motion or target.potential_targets.is_empty():
#return
#
#transition.emit(self, CardAimState)
#
#func _handle_creature(event: InputEvent) -> void:
#var cancel = event.is_action_pressed("right_mouse")
#if cancel:
#transition.emit(self, CardIdleState)
#return
#
#var confirm = event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse")
#if confirm:
#target.get_viewport().set_input_as_handled()
#transition.emit(self, CardReleasedState)
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_idle_state.gd ===
#class_name CardIdleState
#extends CardBaseState
#
#func enter() -> void:
#if not target.is_node_ready(): await target.ready
#
#if target.tween: target.tween.kill()
#target.reparent_event.emit(target)
#_normalize()
#
#func on_gui_input(event: InputEvent) -> void:
#if not event.is_action_pressed("left_mouse"): return
#
#target.pivot_offset = target.get_global_mouse_position() - target.global_position
#transition.emit(self, CardClickedState)
#
#func on_mouse_enter() -> void:
#target.scale = Vector2.ONE * 1.05
#target.z_index = 100
#
#func on_mouse_exit() -> void:
#_normalize()
#
#func _normalize() -> void:
#target.scale = Vector2.ONE
#target.z_index = 1
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_released_state.gd ===
#class_name CardReleasedState
#extends CardBaseState
#
#var played: bool
#
#func enter() -> void:
#var game := target.get_tree().get_first_node_in_group("game") as Game
#var character := game.get_character(target.card_owner)
#
#played = not target.potential_targets.is_empty()
#if not played: return
#
#if not character.mana.spend(target.data.cost):
#transition.emit(self, CardIdleState)
#return
#
#target.play()
#
#func on_input(_event: InputEvent) -> void:
#if played: return
#
#transition.emit(self, CardIdleState)
#
#
#=== FILE: g:\godot\cards\scripts\card\card_states\card_state_machine.gd ===
#class_name CardStateMachine
#extends StateMachine
#
#func _init(from: Card, new_states: Array, initial_state: Variant) -> void:
#for state in new_states:
#state.target = from
#
#super(new_states, initial_state)
#
#func on_input(event: InputEvent) -> void:
#var card_state: CardBaseState = current_state as CardBaseState
#if card_state: card_state.on_input(event)
#
#func on_gui_input(event: InputEvent) -> void:
#var card_state: CardBaseState = current_state as CardBaseState
#if card_state: card_state.on_gui_input(event)
#
#func on_mouse_enter() -> void:
#var card_state: CardBaseState = current_state as CardBaseState
#if card_state: card_state.on_mouse_enter()
#
#func on_mouse_exit() -> void:
#var card_state: CardBaseState = current_state as CardBaseState
#if card_state: card_state.on_mouse_exit()
#
#
#=== FILE: g:\godot\cards\scripts\card\utils\card_target_selector.gd ===
#extends Node2D
#
#const MAX_POINTS := 12
#const MINIONS_COLLISION_LAYER := 3
#const ALLIES_COLLISION_LAYER := 4
#
#@onready var area_detector := $detector
#@onready var arrow_arc := %arrow_arc
#
#var selection_context: Control
#var targeting: bool
#var events: EventBus
#
#func _ready() -> void:
#events = ServiceLocator.get_service(EventBus)
#
#events.target_selector_called_event.connect(_on_target_selector_called)
#events.target_selector_discard_event.connect(_on_target_selector_discarded)
#
#func _input(event: InputEvent) -> void:
#if not targeting: return
#
#if event.is_action_pressed("left_mouse"):
#if selection_context.potential_targets.is_empty():
#return
#var parent = selection_context.potential_targets[0].get_parent()
#var target = parent
#selection_context.potential_targets.clear()
#events.target_selector_resolved_event.emit(target)
#return
#
#
#func _process(_delta: float) -> void:
#if not targeting: return
#
#area_detector.position = get_local_mouse_position()
#arrow_arc.points = _calculate_points()
#
#func _on_detector_area_entered(area: Area2D) -> void:
#if not selection_context or not targeting: return
#
#if not selection_context.potential_targets.has(area):
#selection_context.potential_targets.append(area)
#
#func _on_detector_area_exited(area: Area2D) -> void:
#if not selection_context or not targeting: return
#
#selection_context.potential_targets.erase(area)
#
#func _on_target_selector_called(target) -> void:
#if not (target is Minion or target is SpellCard): return
#
#var is_spell = target is SpellCard
#area_detector.set_collision_mask_value(ALLIES_COLLISION_LAYER, is_spell)
#
#targeting = true
#area_detector.monitoring = true
#area_detector.monitorable = true
#selection_context = target
#
#func _on_target_selector_discarded(_target) -> void:
#targeting = false
#area_detector.monitoring = false
#area_detector.monitorable = false
#area_detector.position = Vector2.ZERO
#selection_context = null
#arrow_arc.clear_points()
#
#func _calculate_points() -> Array[Vector2]:
#var result: Array[Vector2]
#
#var start := selection_context.global_position
#start.x += selection_context.size.x / 2
#var target := get_local_mouse_position()
#var distance := target - start
#
#for i in range(MAX_POINTS):
#var t := 1. / MAX_POINTS * i
#var current_x := start.x + distance.x / MAX_POINTS * i
#var current_y := start.y + _ease_out_cubic(t) * distance.y
#result.append(Vector2(current_x, current_y))
#
#result.append(target)
#return result
#
#func _ease_out_cubic(t: float) -> float:
#return 1. - pow(1. - t, 3.)
#
#
#=== FILE: g:\godot\cards\scripts\data\card_context.gd ===
#@abstract
#extends Resource
#class_name CardContext
#
#@abstract func get_card_type() -> Enums.CardType
#
#
#=== FILE: g:\godot\cards\scripts\data\card_data.gd ===
#extends Resource
#class_name CardData
#
#@export var name: String
#@export var cost: int
#@export var image: Texture2D
#@export var card_context: CardContext
#
#
#=== FILE: g:\godot\cards\scripts\data\minion_context.gd ===
#extends CardContext
#class_name MinionContext
#
#@export_group("Stats")
#@export var health: int
#@export var damage: int
#
#@export_group("Effects")
#@export var on_spawn_effects: Array[CardEffect]
#@export var on_attack_effects: Array[CardEffect]
#@export var on_die_effects: Array[CardEffect]
#
#@export_group("Visual")
#@export var portrait_zoom: float
#@export var portrait_offset: Vector2
#
#func get_card_type() -> Enums.CardType:
#return Enums.CardType.MINION
#
#
#=== FILE: g:\godot\cards\scripts\data\spell_context.gd ===
#extends CardContext
#class_name SpellContext
#
#@export var description: String
#@export var on_play_effects: Array[CardEffect]
#
#func get_card_type() -> Enums.CardType:
#return Enums.CardType.SPELL
#
#
#=== FILE: g:\godot\cards\scripts\effects\card_effect.gd ===
#@abstract
#extends Resource
#class_name CardEffect
#
#@abstract func resolve(context) -> void
#
#
#=== FILE: g:\godot\cards\scripts\effects\damage_effect.gd ===
#extends CardEffect
#class_name DamageEffect
#
#@export var value: int
#
#func resolve(context) -> void:
#if context == null:
#return
#
#if context.has_method("take_damage"):
#context.take_damage(value)
#
#
#=== FILE: g:\godot\cards\scripts\effects\erase_target_effect.gd ===
#extends CardEffect
#class_name EraseTargetEffect
#
#@export var value: int
#
#var running = true
#var events: EventBus = ServiceLocator.get_service(EventBus)
#
#func resolve(caster: Minion) -> void:
#_highlight_enemies(Color.GREEN, caster)
#events.target_selector_called_event.emit(caster)
#
#events.target_selector_resolved_event.connect(_stop)
#
#func _stop(context: Minion) -> void:
#events.target_selector_resolved_event.disconnect(_stop)
#
#_highlight_enemies(Color.WHITE, context)
#events.target_selector_discard_event.emit(context)
#
#running = false
#context.take_damage(context.health)
#
#func _highlight_enemies(color: Color, context: Control) -> void:
#for in_zone: CardBoard in context.get_tree().get_nodes_in_group("card_zones"):
#if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
#
#for minion in in_zone.minions:
#minion.modulate = color
#
#
#=== FILE: g:\godot\cards\scripts\effects\print_effect.gd ===
#extends CardEffect
#class_name PrintEffect
#
#@export var value: String
#
#func resolve(_context) -> void:
#print(value)
#
#
#=== FILE: g:\godot\cards\scripts\effects\target_damage_effect.gd ===
#extends CardEffect
#class_name TargetDamageEffect
#
#@export var value: int
#
#var running = true
#var events: EventBus = ServiceLocator.get_service(EventBus)
#
#func resolve(context) -> void:
#_highlight_enemies(Color.GREEN, context)
#events.target_selector_called_event.emit(context)
#
#events.target_selector_resolved_event.connect(_stop)
#
#func _stop(context) -> void:
#events.target_selector_resolved_event.disconnect(_stop)
#
#_highlight_enemies(Color.WHITE, context)
#events.target_selector_discard_event.emit(context)
#
#running = false
#context.take_damage(context.health / 2)
#
#func _highlight_enemies(color: Color, context) -> void:
#for in_zone: CardBoard in context.get_tree().get_nodes_in_group("card_zones"):
#if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
#
#for minion in in_zone.minions:
#minion.modulate = color
#
#
#=== FILE: g:\godot\cards\scripts\game\character.gd ===
#class_name CharacterMetadata
#extends Resource
#
#@export var character_name: String = "Template"
#@export var deck: DeckMetadata
#
#
#=== FILE: g:\godot\cards\scripts\game\character_runtime.gd ===
#class_name CharacterRuntime
#extends Node
#
#@export var side: Enums.CharacterType
#@export var game: Game
#
#@onready var deck: Deck = $deck
#@onready var board: CardBoard = $board_player
#@onready var mana: ManaController = $mana_controller
#@onready var hand: Hand = $ui/hand
#@onready var face: HeroFace = $hero_face
#
#@export var turn_manager: TurnManager
#
#func _ready():
#deck.owned = side
#board.board_owner = side
#board.game = game
#mana.owned = side
#hand.deck = deck
#face.owned = side
#
#face.init()
#board.init()
#mana.update_label()
#
#turn_manager.turn_changed.connect(_on_turn_started)
#print(deck,123)
#
#func _on_turn_started(current_turn):
#board._on_turn_started(current_turn)
#mana._on_turn_started(current_turn)
#pass
#
#
#=== FILE: g:\godot\cards\scripts\game\deck.gd ===
#class_name Deck
#extends Control
#
#@export var number_label: Label
#@export var discard_label: Label
#@export var start_cards: DeckMetadata
#
#var owned: Enums.CharacterType
#var cards: Array[CardData] = []
#var discard_pile: Array[CardData] = []
#var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
#
#func initialize_deck(initial_cards: DeckMetadata) -> void:
#if initial_cards == null: initial_cards = start_cards
#
#for id in initial_cards.cards:
#var data = card_database.get_from_registry(id)
#if data == null:
#push_error("Can't get requested card of type %s!" % id)
#continue
#
#cards.append(data)
#
#_update_label()
#
#func draw_card() -> CardData:
#if cards.is_empty(): return null
#
#var card: CardData = cards.pop_back()
#_update_label()
#return card
#
#func _update_label() -> void:
#if number_label: number_label.text = str(cards.size())
#if discard_label: discard_label.text = str(discard_pile.size())
#
#func add_to_discard_pile(context):
#discard_pile.append(context.data)
#_update_label()
#
#func reshuffle():
#if not cards.is_empty(): return
#
#discard_pile.shuffle()
#cards = discard_pile
#discard_pile = []
#
#
#=== FILE: g:\godot\cards\scripts\game\deck_metadata.gd ===
#class_name DeckMetadata
#extends Resource
#
#@export var cards: Array[String]
#
#
#=== FILE: g:\godot\cards\scripts\game\game.gd ===
#extends Node2D
#class_name Game
#
#@export var player: CharacterRuntime
#@export var enemy: CharacterRuntime
#@onready var hand := player.hand
#
#@export var minion_card_scene: PackedScene
#@export var spell_card_scene: PackedScene
#@export var start_hand_size := 5
#@export var turn_manager: TurnManager
#
#var player_meta_cards: DeckMetadata
#var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
#
#func initialize_game(deck_metadata: DeckMetadata) -> void:
#player_meta_cards = deck_metadata
#
#func _ready() -> void:
#player.deck.initialize_deck(player_meta_cards)
#turn_manager.turn_changed.connect(on_turn_started)
#
#_init_start_hand()
#
#func _init_start_hand() -> void:
#draw_start_hand()
#
#func draw_start_hand() -> void:
#for i in range(start_hand_size):
#draw_card(player.deck)
#
#func draw_card(_deck: Deck) -> void:
#var data: CardData = _deck.draw_card()
#if data == null and not _deck.discard_pile.is_empty():
#_deck.reshuffle()
#data = _deck.draw_card()
#elif data == null:
#return
#
#var card: Card = create_card_from_data(data)
#hand.add_card(card)
#
#func create_card(value: String) -> Card:
#var data := card_database.get_from_registry(value)
#if data == null:
#push_error("Unable to retrieve data from key: %s" % value)
#return null
#
#return create_card_from_data(data)
#
#func create_card_from_data(value: CardData) -> Card:
#var card: Card
#
#match value.card_context.get_card_type():
#Enums.CardType.MINION:
#card = minion_card_scene.instantiate() as Card
#Enums.CardType.SPELL:
#card = spell_card_scene.instantiate() as Card
#_:
#push_warning("Unknown card type")
#return null
#
#card.setup(value)
#return card
#
#func create_minion_from_name(value: String) -> Minion:
#var data := card_database.get_from_registry(value)
#if data == null or data.card_context.get_card_type() != Enums.CardType.MINION:
#push_error("Unable to retrieve data from key: %s" % value)
#return null
#
#var minion = create_minion()
#minion.setup(data)
#return minion
#
#static func create_minion() -> Minion:
#var temp_minion_scene := load("res://scenes/minion.tscn")
#
#var minion: Minion = temp_minion_scene.instantiate()
#return minion
#
#func on_turn_started(current_turn: Enums.CharacterType) -> void:
#var character := get_character(current_turn)
#print(character)
#if current_turn == Enums.CharacterType.PLAYER:
#for i in range(2):
#draw_card(player.deck)
#
#func get_character(character_type: Enums.CharacterType) -> CharacterRuntime:
#return player if character_type == Enums.CharacterType.PLAYER else enemy
#
#
#=== FILE: g:\godot\cards\scripts\game\hand.gd ===
#class_name Hand
#extends Control
#
#@export_group("Logic")
#@export var max_count := 8
#@export var card_width := 140
#@export var hand_y := 480
#
#@export_group("Animation")
#@export var hand_radius: float = 1000.0
#@export var card_angle_spread: float = 5.0
#@export var max_total_spread: float = 60.0
#@export var animation_speed: float = 0.2
#
#@export var deck: Deck
#
#var hand_center: Vector2 
#var cards: Array[Card] = []
#
#func _ready():
#var screen_size = get_viewport_rect().size
#hand_center = Vector2(screen_size.x / 2, screen_size.y + hand_radius - 100)
#
#func add_card(card: Card) -> void:
#if cards.size() >= max_count: return
#
#cards.append(card)
#add_child(card)
#card.parent = self
#update_hand_visuals()
#_connect_card_signals(card)
#
#func remove_card(card: Card) -> void:
#cards.erase(card)
#update_hand_visuals()
#
#func update_hand_visuals():
#var card_count = cards.size()
#if card_count == 0: return
#
#var current_spread = min(card_count * card_angle_spread, max_total_spread)
#var angle_step = 0
#if card_count > 1: angle_step = deg_to_rad(current_spread) / (card_count - 1)
#
#var start_angle = deg_to_rad(-90) - (deg_to_rad(current_spread) / 2)
#
#for i in range(card_count):
#var card = cards[i]
#var current_angle = start_angle + (angle_step * i)
#var target_pos = Vector2(
#hand_center.x + hand_radius * cos(current_angle),
#hand_center.y + hand_radius * sin(current_angle)
#)
#var target_rotation = current_angle + PI/2 
#
#_animate_card_to_position(card, target_pos, target_rotation)
#
#func _animate_card_to_position(card, target_pos, target_rot):
#var tween = create_tween()
#tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
#tween.parallel().tween_property(card, "global_position", target_pos, animation_speed)
#tween.parallel().tween_property(card, "rotation", target_rot, animation_speed)
#
#func _connect_card_signals(card: Card) -> void:
#card.reparent_event.connect(_on_reparent_event) 
#card.played_event.connect(_on_played_event)
#
#func _on_reparent_event(card: Card) -> void:
#card.reparent(self)
#update_hand_visuals()
#
#func _on_played_event(card: Card) -> void:
#remove_card(card)
#
#if card is SpellCard: deck.add_to_discard_pile(card)
#
#card.queue_free()
#
#
#=== FILE: g:\godot\cards\scripts\game\hero_face.gd ===
#class_name HeroFace
#extends Control
#
#@export var max_health := 30
#
#const PLAYER_LAYER := 4
#const ENEMY_LAYER  := 3
#
#@onready var owned: Enums.CharacterType
#@onready var collider: Area2D = $collider
#@onready var icon: TextureRect = $TextureRect
#@onready var health_label: Label = $health
#
#signal died(owned)
#
#var health := 30
#
#func init():
#health = max_health
#apply_layout()
#update_ui()
#_configure_collision()
#
#collider.area_entered.connect(_on_collider_area_entered)
#collider.area_exited.connect(_on_collider_area_exited)
#
#func _configure_collision():
#collider.collision_layer = 0
#collider.collision_mask = 0
#
#if owned == Enums.CharacterType.PLAYER:
#collider.set_collision_layer_value(PLAYER_LAYER, true)
#collider.set_collision_mask_value(ENEMY_LAYER, true)
#else:
#collider.set_collision_layer_value(ENEMY_LAYER, true)
#collider.set_collision_mask_value(PLAYER_LAYER, true)
#
#
#func apply_layout():
#if owned == Enums.CharacterType.ENEMY:
#
#anchor_left = 1
#anchor_right = 1
#offset_left = -200
#offset_right = 0
#else:
#anchor_left = 0
#anchor_right = 0
#offset_left = 0
#offset_right = 200
#
#fix_children_mirroring()
#
#
#func fix_children_mirroring():
#for c in get_children():
#if c is Control:
#c.scale.x = -scale.x
#
#func take_damage(value: int):
#health -= value
#update_ui()
#
#if health <= 0:
#died.emit(owner)
#
#func update_ui():
#health_label.text = str(health)
#
#var potential_targets := []
#
#func _on_collider_area_entered(area):
#if not potential_targets.has(area):
#potential_targets.append(area)
#
#func _on_collider_area_exited(area):
#potential_targets.erase(area)
#
#
#=== FILE: g:\godot\cards\scripts\game\mana_controller.gd ===
#class_name ManaController
#extends Node
#
#signal mana_changed(current: int, max: int)
#
#var owned: Enums.CharacterType
#
#@export var label: Label
#@export var max_mana_cap := 20
#
#var max_mana := 10
#var current_mana := 10
#
#func start_turn():
#if max_mana < max_mana_cap:
#max_mana += 1
#current_mana = max_mana
#mana_changed.emit(current_mana, max_mana)
#
#func can_pay(cost: int) -> bool:
#return current_mana >= cost
#
#func spend(cost: int) -> bool:
#if not can_pay(cost):
#return false
#
#current_mana -= cost
#mana_changed.emit(current_mana, max_mana)
#update_label()
#return true
#
#func _on_turn_started(turn):
#if turn == owned:
#start_turn()
#update_label()
#
#func update_label():
#label.text = str(current_mana)+"/"+str(max_mana)
#return
#
#
#=== FILE: g:\godot\cards\scripts\game\turn_manager.gd ===
#extends Node2D
#class_name TurnManager
#
#@export var player_board: CardBoard
#@export var enemy_board: CardBoard
#
#var turn_sequense: Array[Enums.CharacterType] = [ 
#Enums.CharacterType.PLAYER,
#Enums.CharacterType.ENEMY
#]
#
#var current_turn: Enums.CharacterType = turn_sequense[0]
#
#signal turn_changed(turn)
#
#func end_turn():
#var index = turn_sequense.find(current_turn)
#current_turn = (index + 1) % turn_sequense.size() as Enums.CharacterType
#
#turn_changed.emit(current_turn)
#
#func _on_button_pressed() -> void:
#if current_turn == Enums.CharacterType.PLAYER:
#end_turn()
#else:
#print("хіхіххіхіхіхі")
#end_turn()
#
#
#=== FILE: g:\godot\cards\scripts\loaders\card_database.gd ===
#class_name CardDatabase
#extends Service
#
#var CARD_FACTORY_TYPES = {
#"creature": MinionContext,
#"spell": SpellContext
#}
#
#var EFFECT_FACTORY_TYPES = {
#"print_effect": PrintEffect,
#"damage_effect": DamageEffect,
#"target_damage_effect": TargetDamageEffect,
#"erase_target_effect": EraseTargetEffect
#}
#
#@export var json_path := "res://data/cards.json"
#
#var _cards_registry: Dictionary[String, CardData]
#
#func init() -> void:
#_load_cards()
#
#func get_from_registry(value: String) -> CardData:
#return _cards_registry.get(value, null)
#
#func _load_cards() -> void:
#var file := FileAccess.open(json_path, FileAccess.READ)
#if file == null:
#push_error("Cannot open cards.json")
#return
#
#var parsed: Variant = JSON.parse_string(file.get_as_text())
#if typeof(parsed) != TYPE_DICTIONARY:
#push_error("Invalid cards.json format")
#return
#
#for id in parsed.keys():
#_cards_registry[id] = _create_card_data(parsed[id])
#
#func _create_card_data(raw: Dictionary) -> CardData:
#var card := CardData.new()
#card.name = raw.get("name", "UNKNOWN")
#card.cost = raw.get("cost", 0)
#card.image = load(raw.get("image", ""))
#
#card.card_context = _create_context(raw)
#
#match card.card_context.get_card_type():
#Enums.CardType.SPELL:
#card.card_context.on_play_effects = _create_effects(raw.get("effects", {}))
#Enums.CardType.MINION:
#var effects = raw.get("effects", {})
#card.card_context.on_spawn_effects = _create_effects(effects.get("spawn_effects", {}))
#card.card_context.on_attack_effects = _create_effects(effects.get("attack_effects", {}))
#card.card_context.on_die_effects = _create_effects(effects.get("die_effects", {}))
#
#return card
#
#func _create_context(raw: Dictionary) -> CardContext:
#var type = raw.get("card_type", "")
#if CARD_FACTORY_TYPES.has(type) == false:
#push_error("Unknown context type: %s" % type)
#return null
#
#var ctx = CARD_FACTORY_TYPES[type].new()
#_populate(ctx, raw)
#
#if ctx is MinionContext:
#var d = raw.get("portrait_offset", {})
#ctx.portrait_offset = Vector2(d.get("x", 0.0), d.get("y", 0.0))
#ctx.portrait_zoom = raw.get("portrait_zoom", 1)
#
#return ctx
#
#func _create_effects(list: Dictionary) -> Array[CardEffect]:
#var result: Array[CardEffect] = []
#
#for id in list.keys():
#if EFFECT_FACTORY_TYPES.has(id) == false:
#push_error("Unknown effect type: %s" % id)
#continue
#
#var e = EFFECT_FACTORY_TYPES[id].new()
#_populate(e, list[id])
#result.append(e)
#
#return result
#
#func _populate(obj, d: Dictionary) -> void:
#var props = obj.get_property_list()
#
#for p in props:
#if d.has(p.name) == false:
#continue
#
#obj.set(p.name, d[p.name])
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion.gd ===
#class_name Minion
#extends Control
#
#@onready var potential_targets: Array[Node] = []
#
#@onready var health_text := %health
#@onready var damage_text := %damage
#@onready var collision_detector: Area2D = %collider_detector
#@onready var character_icon := %character_icon
#
#signal died_event(minion: Minion)
#
#var health: int
#var damage: int
#var data: CardData
#var has_attacked: bool
#var state_machine: MinionStateMachine
#var minion_owner := Enums.CharacterType.PLAYER
#
#func setup(card_data: CardData) -> void:
#if not self.is_node_ready(): await self.ready
#
#var context := card_data.card_context as MinionContext
#if context == null:
#push_error("Wrong type expected MINION")
#return
#
#var states := [
#MinionIdleState.new(),
#MinionAimState.new(),
#MinionAttackState.new(),
#]
#state_machine = MinionStateMachine.new(self, states, MinionIdleState)
#
#data = card_data
#health = context.health
#damage = context.damage
#
#character_icon.texture = card_data.image
#var mat: Material = character_icon.material.duplicate()
#mat.set_shader_parameter("offset", context.portrait_offset)
#mat.set_shader_parameter("zoom", context.portrait_zoom)
#character_icon.material = mat
#
#_ui_update_health(health)
#_ui_update_damage(damage)
#_resolve_effects(context.on_spawn_effects, self)
#
#func _input(event: InputEvent) -> void:
#if not state_machine: return
#state_machine.on_input(event)
#
#func take_damage(value: int) -> void:
#health -= value
#
#if health <= 0:
#died_event.emit(self)
#_resolve_effects(data.card_context.on_die_effects, null)
#return
#
#_ui_update_health(health)
#
#func attack(target) -> void:
#target.take_damage(damage)
#if target is Minion:
#take_damage(target.damage)
#
#_resolve_effects(data.card_context.on_attack_effects, null)
#
#func _on_gui_input(event: InputEvent) -> void:
#if not state_machine: return
#state_machine.on_gui_input(event)
#
#func _on_mouse_entered() -> void:
#if not state_machine: return
#state_machine.on_mouse_enter()
#
#func _on_mouse_exited() -> void:
#if not state_machine: return
#state_machine.on_mouse_exit()
#
#func _resolve_effects(effects: Array[CardEffect], context) -> void:
#for effect in effects:
#effect.resolve(context)
#
#func _ui_update_health(value: int) -> void:
#%health.text = str(value)
#
#func _ui_update_damage(value: int) -> void:
#%damage.text = str(value)
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion_states\minion_aim_state.gd ===
#class_name MinionAimState
#extends MinionBaseState
#
#var events: EventBus = ServiceLocator.get_service(EventBus)
#
#func enter() -> void:
#target.scale = Vector2(1.15, 1.15)
#
#_highlight_enemies(Color.GREEN)
#events.target_selector_called_event.emit(target)
#
#func exit() -> void:
#target.scale = Vector2.ONE
#
#_highlight_enemies(Color.WHITE)
#events.target_selector_discard_event.emit(target)
#
#func on_input(event: InputEvent) -> void:
#if event.is_action_pressed("right_mouse"):
#transition.emit(self, MinionIdleState)
#return
#
#if event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse"):
#target.get_viewport().set_input_as_handled()
#transition.emit(self, MinionAttackState)
#
#func _highlight_enemies(color: Color) -> void:
#for in_zone: CardBoard in target.get_tree().get_nodes_in_group("card_zones"):
#if in_zone.board_owner == Enums.CharacterType.PLAYER: continue
#
#for minion in in_zone.minions:
#minion.modulate = color
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion_states\minion_attack_state.gd ===
#class_name MinionAttackState
#extends MinionBaseState
#
#func enter() -> void:
#if target.potential_targets.is_empty():
#transition.emit(self, MinionIdleState)
#return
#
#var potential_enemy = target.potential_targets[0].get_parent()
#if not potential_enemy.has_method("take_damage"):
#transition.emit(self, MinionIdleState)
#return
#
#_animate_attack(potential_enemy)
#
#func _animate_attack(enemy) -> void:
#target.has_attacked = true
#var start_pos = target.global_position
#var target_pos = enemy.global_position
#
#var original_z = target.z_index
#target.z_index = 300
#
#var direction = (target_pos - start_pos).normalized()
#var wind_up_pos = start_pos - (direction * 50)
#
#var tween = target.create_tween()
#tween.tween_property(target, "global_position", wind_up_pos, 0.2)\
#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#tween.tween_property(target, "global_position", target_pos, 0.15)\
#.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
#tween.tween_callback(func(): _on_impact(enemy))
#tween.tween_property(target, "global_position", start_pos, 0.4)\
#.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
#
#tween.finished.connect(func(): target.z_index = original_z)
#
#func _on_impact(enemy):
#target.attack(enemy)
#transition.emit(self, MinionIdleState)
#
#var shake = enemy.create_tween()
#shake.tween_property(enemy, "position:x", 10.0, 0.05).as_relative()
#shake.tween_property(enemy, "position:x", -10.0, 0.05).as_relative()
#shake.set_loops(3)
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion_states\minion_base_state.gd ===
#@abstract
#class_name MinionBaseState
#extends BaseState
#
#var target: Minion
#
#func on_input(_event: InputEvent) -> void:
#pass
#
#func on_gui_input(_event: InputEvent) -> void:
#pass
#
#func on_mouse_enter() -> void:
#pass
#
#func on_mouse_exit() -> void:
#pass
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion_states\minion_idle_state.gd ===
#class_name MinionIdleState
#extends MinionBaseState
#
#func enter() -> void:
#if not target.is_node_ready(): await target.ready
#
#func on_gui_input(event: InputEvent) -> void:
#if not event.is_action_pressed("left_mouse"): return
#if target.minion_owner == Enums.CharacterType.ENEMY: return
#if target.has_attacked: return
#
#transition.emit(self, MinionAimState)
#
#
#=== FILE: g:\godot\cards\scripts\minions\minion_states\minion_state_machine.gd ===
#class_name MinionStateMachine
#extends StateMachine
#
#func _init(from: Minion, new_states: Array, initial_state: Variant) -> void:
#for state in new_states:
#state.target = from
#
#super(new_states, initial_state)
#
#func on_input(event: InputEvent) -> void:
#var card_state: MinionBaseState = current_state as MinionBaseState
#if card_state: card_state.on_input(event)
#
#func on_gui_input(event: InputEvent) -> void:
#var card_state: MinionBaseState = current_state as MinionBaseState
#if card_state: card_state.on_gui_input(event)
#
#func on_mouse_enter() -> void:
#var card_state: MinionBaseState = current_state as MinionBaseState
#if card_state: card_state.on_mouse_enter()
#
#func on_mouse_exit() -> void:
#var card_state: MinionBaseState = current_state as MinionBaseState
#if card_state: card_state.on_mouse_exit()
#
#
#=== FILE: g:\godot\cards\scripts\state_machine\base_state.gd ===
#@abstract
#class_name BaseState
#
#@warning_ignore("unused_signal")
#signal transition(from: BaseState, to: Variant)
#
#func enter() -> void:
#pass
#
#func exit() -> void:
#pass
#
#
#=== FILE: g:\godot\cards\scripts\state_machine\state_machine.gd ===
#class_name StateMachine
#
#var current_state: BaseState
#var state_registry: Dictionary[Variant, BaseState]
#
#func _init(new_states: Array, initial_state: Variant) -> void:
#for state in new_states:
#var variant: Variant = state.get_script()
#if state_registry.has(variant): 
#push_warning("State collision. Found duplicate state of type: %s" % variant.get_global_name())
#continue
#
#state_registry[variant] = state
#state.transition.connect(_on_transition)
#
#if not state_registry.has(initial_state):
	#push_error("alredy has init state")
	#return
#
#current_state = state_registry[initial_state]
#
#if state_registry.has(initial_state) == false:
#push_error("Wrong initial state: %s" % initial_state.get_global_name())
#return
#current_state = state_registry[initial_state]
#current_state.enter()
#
#func _on_transition(from: BaseState, to: Variant) -> void:
#if from != current_state:
#var current_name: String = current_state.get_script().get_global_name()
#var from_name: String = from.get_script().get_global_name()
#push_warning("Inconsistent state flow. Expected %s, found %s" % current_name % from_name)
#return
#
#var new_state = state_registry.get(to, null)
#if not new_state:
#var new_state_name: String = to.get_global_name()
#push_error("Wrong state request. Request type: %s" % new_state_name)
#return
#
#if current_state: current_state.exit()
#current_state = new_state
#current_state.enter()
#
#
#=== FILE: g:\godot\cards\scripts\tools\ghost.gd ===
 #syntax: [ghost freq=5.0 span=10.0][/ghost]
#@tool
#extends RichTextEffect
#class_name RichTextGhost
#
#var bbcode = "ghost"
#
#func _process_custom_fx(char_fx):
#var speed = char_fx.env.get("freq", 5.0)
#var span = char_fx.env.get("span", 10.0)
#
#var alpha = sin(char_fx.elapsed_time * speed + (char_fx.range.x / span)) * 0.5 + 0.5
#char_fx.color.a = alpha
#return true
#
#
#=== FILE: g:\godot\cards\scripts\ui\card_panel.gd ===
#extends PanelContainer
#class_name CardPanelMinimized
#
#@onready var card_name := %card_name
#@onready var card_quatity := %card_quatity
#
#func setup(c_name: String, quantity: int) -> void:
#card_name.text = c_name
#card_quatity.text = str(quantity)
#
#
#=== FILE: g:\godot\cards\scripts\ui\character_box.gd ===
#class_name CharacterBox
#extends Button
#
#@onready var character_label := %character_name
#@onready var card_container := %cards_container
#
#var character_name: String
#var initial_deck: DeckMetadata
#var card_database: CardDatabase = ServiceLocator.get_service(CardDatabase)
#var scenes: SceneManager = ServiceLocator.get_service(SceneManager)
#
#func setup(character: CharacterMetadata) -> void:
#character_name = character.character_name
#initial_deck = character.deck
#character_label.text = character_name
#
#var previews = card_container.get_children()
#for preview in previews:
#preview.queue_free()
#
#var card_map: Dictionary[String, int]
#for card_id in initial_deck.cards:
#var data = card_database.get_from_registry(card_id)
#if data == null:
#push_error("Can't get requested card of type %s!" % card_id)
#continue
#
#if card_map.has(card_id) == false: card_map[card_id] = 0
#card_map[card_id] += 1
#
#var container_prefab = preload("res://scenes/card_panel.tscn")
#for card_id in card_map:
#var quantity = card_map[card_id]
#
#var instance: CardPanelMinimized = container_prefab.instantiate()
#card_container.add_child(instance)
#
#instance.name = card_id
#instance.setup(card_id, quantity)
#
#func _pressed() -> void:
#var scenetype = scenes.SceneType.BATTLE_SCENE
#var result = scenes.switch_scene(scenetype, initial_deck)
#if result == true: return
#
#push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[scenetype]))
#
#
#=== FILE: g:\godot\cards\scripts\ui\character_container.gd ===
#extends Panel
#
#@onready var container := %options
#
#func _ready() -> void:
#var previews = container.get_children()
#for preview in previews:
#preview.queue_free()
#
#var character_resources = load_all_resources("res://resources/character/")
#var character_box_prefab = preload("res://scenes/character_box.tscn")
#for character_meta in character_resources:
#var instance: CharacterBox = character_box_prefab.instantiate()
#container.add_child(instance)
#
#instance.name = character_meta.character_name
#instance.setup(character_meta)
#
#func load_all_resources(folder_path: String) -> Array[CharacterMetadata]:
#var resources: Array[CharacterMetadata] = []
#var dir = DirAccess.open(folder_path)
#
#if dir:
#dir.list_dir_begin()
#var file_name = dir.get_next()
#
#while file_name != "":
 #Skip directories and hidden files (like .)
#if not dir.current_is_dir():
 #Fix for exported projects: remove .remap extension
#if file_name.ends_with(".remap"):
#file_name = file_name.trim_suffix(".remap")
#
 #Check for valid extensions (optional but recommended)
#if file_name.ends_with(".tres") or file_name.ends_with(".png"):
#var full_path = folder_path + "/" + file_name
#var res = load(full_path)
#if res:
#resources.append(res)
#
#file_name = dir.get_next()
#
#dir.list_dir_end()
#else:
#print("An error occurred when trying to access the path.")
#
#return resources
#
#
#=== FILE: g:\godot\cards\scripts\ui\buttons\button_exit_game.gd ===
#extends Button
#
#func _pressed() -> void:
#get_tree().quit()
#
#
#=== FILE: g:\godot\cards\scripts\ui\buttons\button_resolution_picker.gd ===
#extends OptionButton
#
#var all_resolutions := [
#Vector2i(1280, 720),
#Vector2i(1600, 900),
#Vector2i(1920, 1080),
#Vector2i(2560, 1440),
#Vector2i(3840, 2160)
#]
#
#func _init():
#clear()
#selected = -1
#
#var resolutions = _get_supported_resolutions()
#for res in resolutions:
#add_item("%dx%d" % [res.x, res.y])
#
#item_selected.connect(_on_resolution_selected)
#
#func _get_supported_resolutions() -> Array[Vector2i]:
#var screen := DisplayServer.screen_get_size()
#var result: Array[Vector2i] = []
#
#for res in all_resolutions:
#if res.x > screen.x or res.y > screen.y:
#continue
#
#result.append(res)
#return result
#
#func _on_resolution_selected(index: int):
#DisplayServer.window_set_size(all_resolutions[index])
#
#
#=== FILE: g:\godot\cards\scripts\ui\buttons\button_switch_scene.gd ===
#extends Button
#
#@export var switch_scene: SceneManager.SceneType
#
#var scenes: SceneManager = ServiceLocator.get_service(SceneManager)
#
#func _pressed() -> void:
#var result = scenes.switch_scene(switch_scene, null)
#if result == true: return
#
#push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[switch_scene]))
#
#
#=== FILE: g:\godot\cards\scripts\ui\buttons\button_toggle_fullscreen.gd ===
#extends CheckButton
#
#func _ready() -> void:
#toggled.connect(_on_toggle)
#
#func _on_toggle(toggle_value: bool) -> void:
#var fullscreen = DisplayServer.WINDOW_MODE_FULLSCREEN
#var windowed = DisplayServer.WINDOW_MODE_WINDOWED
#
#var mode = fullscreen if toggle_value == true else windowed
#DisplayServer.window_set_mode(mode)
#
#
#=== FILE: g:\godot\cards\scripts\utils\basic_service.gd ===
#@abstract
#class_name Service
#
#@abstract func init() -> void
#
#
#=== FILE: g:\godot\cards\scripts\utils\enums.gd ===
#class_name Enums
#
#enum CharacterType { PLAYER, ENEMY }
#
#enum CardType { MINION, SPELL, NONE }
#
#
#=== FILE: g:\godot\cards\scripts\utils\events.gd ===
#class_name EventBus
#extends Service
#
#func init() -> void: pass
#
 #card events
#@warning_ignore("unused_signal")
#signal target_selector_called_event(context)
#@warning_ignore("unused_signal")
#signal target_selector_discard_event(context)
#@warning_ignore("unused_signal")
#signal target_selector_resolved_event(context)
#
 #game-state events
#
#
#
#
#
#
#
#
#=== FILE: g:\godot\cards\scripts\utils\scenes.gd ===
#class_name SceneManager
#extends Service
#
#enum SceneType {
#MAIN_SCENE,
#OPTIONS_SCENE,
#CHAR_SELECTOR_SCENE,
#BATTLE_SCENE,
#REWARD_DUNGEON_SCENE
#}
#
#var _scene_map: Dictionary[SceneType, PackedScene]
#
#func init() -> void:
#_scene_map = {
#SceneType.MAIN_SCENE: preload("res://scenes/gameplay/main_menu.tscn"),
#SceneType.OPTIONS_SCENE: preload("res://scenes/gameplay/options_menu.tscn"),
#SceneType.CHAR_SELECTOR_SCENE: preload("res://scenes/gameplay/character_select_menu.tscn"),
#SceneType.BATTLE_SCENE: preload("res://scenes/board_scene.tscn")
#}
#
#func get_scene(type: SceneType) -> PackedScene:
#return _scene_map.get(type, null)
#
#func switch_scene(type: SceneType, params) -> bool:
#if _scene_map.has(type) == false: return false
#
#var packed_instance = _scene_map[type].instantiate()
#if packed_instance.has_method("initialize_game"):
#packed_instance.initialize_game(params)
#
#var tree = ServiceLocator.get_tree()
#var current_scene = tree.current_scene
#tree.root.remove_child(current_scene)
#current_scene.queue_free()
#
#tree.root.add_child(packed_instance)
#tree.current_scene = packed_instance
#return true
#
#
#=== FILE: g:\godot\cards\scripts\utils\service_locator.gd ===
#extends Node
#
#var services: Dictionary[Variant, Service]
#
#func _init() -> void:
#services = {
#CardDatabase : CardDatabase.new(),
#SceneManager: SceneManager.new(),
#EventBus: EventBus.new()
#}
#
#func _ready() -> void:
#for service in services.values():
#service.init()
#
#func get_service(type: Variant) -> Service:
#return services.get(type, null)
#
