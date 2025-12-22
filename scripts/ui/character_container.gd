extends Panel

@onready var container := %options

func _ready() -> void:
	var previews = container.get_children()
	for preview in previews:
		preview.queue_free()
	
	var character_resources = load_all_resources("res://resources/character/")
	var character_box_prefab = preload("res://scenes/character_box.tscn")
	for character_meta in character_resources:
		var instance: CharacterBox = character_box_prefab.instantiate()
		container.add_child(instance)
		
		instance.name = character_meta.character_name
		instance.setup(character_meta)

func load_all_resources(folder_path: String) -> Array[CharacterMetadata]:
	var resources: Array[CharacterMetadata] = []
	var dir = DirAccess.open(folder_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Skip directories and hidden files (like .)
			if not dir.current_is_dir():
				# Fix for exported projects: remove .remap extension
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
				
				# Check for valid extensions (optional but recommended)
				if file_name.ends_with(".tres") or file_name.ends_with(".png"):
					var full_path = folder_path + "/" + file_name
					var res = load(full_path)
					if res:
						resources.append(res)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources
