class_name EraseTargetEffect
extends CardEffect

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
	
	_callback = func(ctx):
		_erase_callback(ctx)
	
	_vfx.effect_finished.connect(_callback)
	
	for t in targets:
		if t is not Minion:
			continue
		
		_pending += 1
		_vfx.play("erase", t)

func _erase_callback(ctx) -> void:
	if ctx is not Minion:
		return
	if not is_instance_valid(ctx):
		return
	
	ctx.die(Enums.DeathCause.ERASE)
	
	_pending -= 1
	if _pending <= 0:
		_vfx.effect_finished.disconnect(_callback)
