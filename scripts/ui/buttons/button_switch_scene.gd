extends Button

@export var switch_scene: Scenes.SceneType

func _pressed() -> void:
	var result = Scenes.switch_scene(switch_scene, null)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(Scenes.SceneType.keys()[switch_scene]))
