extends Button

@export var character_box: CharacterBox

var scenes: SceneManager = ServiceLocator.get_service(SceneManager)

func _pressed() -> void:
	var scenetype = scenes.SceneType.BATTLE_SCENE
	var result = scenes.switch_scene(scenetype, character_box.character_metadata)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[scenetype]))
