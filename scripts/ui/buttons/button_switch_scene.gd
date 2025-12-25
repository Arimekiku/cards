extends Button

@export var switch_scene: SceneManager.SceneType

var scenes: SceneManager = ServiceLocator.get_service(SceneManager)

func _pressed() -> void:
	var result = scenes.switch_scene(switch_scene, null)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[switch_scene]))
