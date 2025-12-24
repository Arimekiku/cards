class_name CardHandler
extends Node2D

const COLLISION_MASK_I := 4

@export var hand: Hand
@export var turn_manager: TurnManager

var selected_attacker: Minion

func _ray_minion() -> Minion:
	var space = get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.position = get_global_mouse_position()
	q.collide_with_areas = true
	q.collision_mask = COLLISION_MASK_I
	
	var r = space.intersect_point(q)
	if r.is_empty(): return null
	
	r.sort_custom(_sort_highest_z)
	return r[0].collider.get_parent()

func _sort_highest_z(a, b) -> bool:
	return a.collider.get_parent().z_index > b.collider.get_parent().z_index
