class_name HeroFace
extends Control

@export var max_health := 30

const PLAYER_LAYER := 4
const ENEMY_LAYER  := 3

@onready var owned: Enums.CharacterType
@onready var collider: Area2D = $collider
@onready var icon: TextureRect = $TextureRect
@onready var health_label: Label = $health

signal died(owned)

var health := 30
var potential_targets := []

func init():
	health = max_health
	update_ui()
	_configure_collision()

func _configure_collision():
	collider.collision_layer = 0
	collider.collision_mask = 0

	if owned == Enums.CharacterType.PLAYER:
		collider.set_collision_layer_value(PLAYER_LAYER, true)
		collider.set_collision_mask_value(ENEMY_LAYER, true)
	else:
		collider.set_collision_layer_value(ENEMY_LAYER, true)
		collider.set_collision_mask_value(PLAYER_LAYER, true)

func fix_children_mirroring():
	for c in get_children():
		if c is Control:
			c.scale.x = -scale.x

func take_damage(value: int):
	health -= value
	update_ui()
	
	if health <= 0:
		died.emit(owned)

func update_ui():
	health_label.text = str(health)

func _on_collider_area_entered(area):
	if not potential_targets.has(area):
		potential_targets.append(area)

func _on_collider_area_exited(area):
	potential_targets.erase(area)
