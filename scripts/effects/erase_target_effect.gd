extends CardEffect
class_name EraseTargetEffect

var _pending := 0
var _callback: Callable
var _vfx: VFXService

func resolve(context):
	if context == null:
		return

	_vfx = ServiceLocator.get_service(VFXService)
	var targets = TargetResolver.resolve(target, context)

	_pending = 0

	_callback = func(t):
		if t is Minion:
			t.die(Enums.DeathCause.ERASE)

		_pending -= 1
		if _pending == 0:
			_vfx.effect_finished.disconnect(_callback)

	_vfx.effect_finished.connect(_callback)

	for t in targets:
		if t is Minion:
			_pending += 1
			_vfx.play("erase", t)
