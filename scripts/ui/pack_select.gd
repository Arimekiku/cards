class_name PackSelect
extends Control

signal on_pack_selected(pack_meta: DeckMetadata)

@export var character_box: CharacterBox

@onready var pick_button: Button = $pack_panel/vertical_container/pick_button

var pack_metadata: DeckMetadata

func _ready() -> void:
	var resources = load_all_resources("res://resources/card_packs/")
	var result = resources.pick_random()
	
	pack_metadata = result.deck
	character_box.setup(result)
	
	pick_button.pressed.connect(_on_pack_button_pressed)

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

func _on_pack_button_pressed() -> void:
	on_pack_selected.emit(pack_metadata)
