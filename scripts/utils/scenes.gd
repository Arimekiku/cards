class_name SceneManager
extends Service

enum SceneType {
	MAIN_SCENE,
	OPTIONS_SCENE,
	CHAR_SELECTOR_SCENE,
	BATTLE_SCENE,
	REWARD_DUNGEON_SCENE
}

var _scene_map: Dictionary[SceneType, PackedScene]

func init() -> void:
	_scene_map = {
		SceneType.MAIN_SCENE: preload("res://scenes/gameplay/main_menu.tscn"),
		SceneType.OPTIONS_SCENE: preload("res://scenes/gameplay/options_menu.tscn"),
		SceneType.CHAR_SELECTOR_SCENE: preload("res://scenes/gameplay/character_select_menu.tscn"),
		SceneType.BATTLE_SCENE: preload("res://scenes/board_scene.tscn"),
		SceneType.REWARD_DUNGEON_SCENE: preload("res://scenes/gameplay/hub_menu.tscn")
	}

func get_scene(type: SceneType) -> PackedScene:
	return _scene_map.get(type, null)

func switch_scene(type: SceneType, params) -> bool:
	if _scene_map.has(type) == false: return false
	
	var packed_instance = _scene_map[type].instantiate()
	if packed_instance.has_method("load_with_cards"):
		packed_instance.load_with_cards(params)
	
	var tree = ServiceLocator.get_tree()
	var current_scene = tree.current_scene
	tree.root.remove_child(current_scene)
	current_scene.queue_free()
	
	tree.root.add_child(packed_instance)
	tree.current_scene = packed_instance
	return true
