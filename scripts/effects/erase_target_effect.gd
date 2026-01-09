extends CardEffect
class_name EraseTargetEffect

var _pending := 0
var _callback: Callable
var _vfx: VFXService = ServiceLocator.get_service(VFXService)

func resolve(context):
	if context == null:
		return
	
	var targets = TargetResolver.resolve(target, context)
	if targets.is_empty():
		return

	_pending = 0

	if _callback and _vfx.effect_finished.is_connected(_callback):
		_vfx.effect_finished.disconnect(_callback)

	_callback = func(target):
		_erase_callback(target)

	_vfx.effect_finished.connect(_callback)

	for t in targets:
		if t is not Minion:
			continue

		_pending += 1
		_vfx.play("erase", t)

func _erase_callback(target) -> void:
	if target is not Minion:
		return

	if not is_instance_valid(target):
		return

	target.die(Enums.DeathCause.ERASE)

	_pending -= 1
	if _pending <= 0:
		if _vfx.effect_finished.is_connected(_callback):
			_vfx.effect_finished.disconnect(_callback)
