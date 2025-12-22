extends CheckButton

func _ready() -> void:
	toggled.connect(_on_toggle)

func _on_toggle(toggle_value: bool) -> void:
	var fullscreen = DisplayServer.WINDOW_MODE_FULLSCREEN
	var windowed = DisplayServer.WINDOW_MODE_WINDOWED
	
	var mode = fullscreen if toggle_value == true else windowed
	DisplayServer.window_set_mode(mode)
