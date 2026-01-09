extends CardEffect
class_name EraseTargetEffect

var _pending := 0
var _callback: Callable
var _vfx: VFXService = ServiceLocator.get_service(VFXService)

func resolve(context):
	if context == null: return
	
	var targets = TargetResolver.resolve(target, context)
	_pending = 0
	_vfx.effect_finished.connect(erase_callback)
	
	for t in targets:
		if t is not Minion: continue
		
		_pending += 1
		_vfx.play("erase", t)

func erase_callback(minion) -> void:
	if minion is not Minion: return
	
	minion.die(Enums.DeathCause.ERASE)
	_pending -= 1
	if _pending == 0: _vfx.effect_finished.disconnect(_callback)
