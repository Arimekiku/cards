extends Button

@export var character_box: CharacterBox
@export var boss_picker: RandomBossSelector

var scenes: SceneManager = ServiceLocator.get_service(SceneManager)

func _pressed() -> void:
	var scenetype = scenes.SceneType.BATTLE_SCENE
	var metas: Array[CharacterMetadata] = [
		character_box.character_metadata,
		boss_picker.selected_boss
	]
	var result = scenes.switch_scene(
		scenetype, 
		metas
	)
	if result == true: return
	
	push_warning("Can't load scene of SceneType: %s" % str(scenes.SceneType.keys()[scenetype]))
