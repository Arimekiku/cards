extends Button

@export var character_save: CharacterRuntime

var scenes: SceneManager = ServiceLocator.get_service(SceneManager)

func _pressed() -> void:
	var scenetype = scenes.SceneType.REWARD_DUNGEON_SCENE
	var result = scenes.switch_scene(
		scenetype,
		character_save.character_meta
	)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[scenetype]))
