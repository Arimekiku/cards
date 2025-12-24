class_name Minion
extends Control

@onready var health_text := %health
@onready var damage_text := %damage
@onready var collision_detector := %collider_detector

signal died_event(minion: Minion)

var health: int
var damage: int
var data: CardData
var attacking := false
var has_attacked := false
var minion_owner := Enums.CharacterType.PLAYER

func setup(card_data: CardData) -> void:
	var type = card_data.card_context.get_card_type()
	if type != Enums.CardType.MINION:
		push_error("Wrong type expected MINION, got: %s" % type)
		return
	
	data = card_data
	health = card_data.card_context.health
	damage = card_data.card_context.damage
	
	%character_icon.texture = card_data.image
	_ui_update_health(health)
	_ui_update_damage(damage)

func take_damage(value: int) -> void:
	health -= value
	
	if health <= 0:
		died_event.emit(self)
		return
	
	_ui_update_health(health)

func _ray_minion() -> Minion:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = 1
	
	var r = space.intersect_point(q)
	if r.is_empty(): return null
	
	var minion = r[0].collider.get_parent()
	if minion is Minion: return minion
	
	return null

func attack(target: Minion) -> void:
	if has_attacked: return

	has_attacked = true
	_animate_attack(target)

func _animate_attack(target_node: Minion) -> void:
	var start_pos = global_position
	var target_pos = target_node.global_position
	
	var original_z = z_index
	z_index = 300
	
	var direction = (target_pos - start_pos).normalized()
	var wind_up_pos = start_pos - (direction * 50)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", wind_up_pos, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.15)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): _on_impact(target_node))
	tween.tween_property(self, "global_position", start_pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func(): z_index = original_z)

func _on_impact(target: Minion):
	target.take_damage(damage)
	take_damage(target.damage)
	
	var shake = create_tween()
	shake.tween_property(target, "position:x", 10.0, 0.05).as_relative()
	shake.tween_property(target, "position:x", -10.0, 0.05).as_relative()
	shake.set_loops(3)

func _ui_update_health(value: int) -> void:
	%health.text = str(value)

func _ui_update_damage(value: int) -> void:
	%damage.text = str(value)
