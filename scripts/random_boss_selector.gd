class_name RandomBossSelector
extends Control

@onready var boss_label := $panel_1/boss_portrait/boss_label
@onready var boss_phrase := $panel_1/boss_portrait/boss_catch_phrase

var selected_boss: CharacterMetadata

func _ready() -> void:
	var character_resources = load_all_resources("res://resources/bosses/")
	selected_boss = character_resources.pick_random()
	
	boss_label.text = selected_boss.character_name
	boss_phrase.text = selected_boss.character_phrase

func load_all_resources(folder_path: String) -> Array[CharacterMetadata]:
	var resources: Array[CharacterMetadata] = []
	var dir = DirAccess.open(folder_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
				
				if file_name.ends_with(".tres") or file_name.ends_with(".png"):
					var full_path = folder_path + "/" + file_name
					var res = load(full_path)
					if res: resources.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
	
	return resources
