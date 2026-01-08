extends Node2D
class_name FireballVFX

signal finished(target)

@export var travel_time := 0.5
@export var impact_effect := "impact"

var _target: Node
var _start_pos: Vector2
var _timer := 0.0

func play(target: Node) -> void:
	if not is_instance_valid(target):
		_emit_finished()
		return

	_target = target
	_start_pos = global_position
	_timer = 0.0
	set_process(true)

func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		_emit_finished()
		return

	_timer += delta
	var t := _timer / travel_time
	if t > 1.0:
		t = 1.0

	global_position = _start_pos.lerp(_target.global_position, t)

	var dir = _target.global_position - global_position
	if dir.length() > 0:
		rotation = dir.angle()

	if t >= 1.0:
		_on_hit()

func _on_hit() -> void:
	set_process(false)

	var vfx_service: VFXService = ServiceLocator.get_service(VFXService)
	if is_instance_valid(_target):
		vfx_service.play("impact", _target)

	_emit_finished()

func _emit_finished() -> void:
	emit_signal("finished", _target)
	queue_free()
