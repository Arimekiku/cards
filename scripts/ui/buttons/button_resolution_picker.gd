extends OptionButton

var all_resolutions := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _init():
	clear()
	selected = -1
	
	var resolutions = _get_supported_resolutions()
	for res in resolutions:
		add_item("%dx%d" % [res.x, res.y])
	
	item_selected.connect(_on_resolution_selected)

func _get_supported_resolutions() -> Array[Vector2i]:
	var screen := DisplayServer.screen_get_size()
	var result: Array[Vector2i] = []
	
	for res in all_resolutions:
		if res.x > screen.x or res.y > screen.y:
			continue
		
		result.append(res)
	return result

func _on_resolution_selected(index: int):
	DisplayServer.window_set_size(all_resolutions[index])
