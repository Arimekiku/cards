extends RichTextLabel

var tooltip_manager: TooltipManager = ServiceLocator.get_service(TooltipManager)

func _ready():
	meta_hover_started.connect(_on_meta_hover_start)
	meta_hover_ended.connect(_on_meta_hover_end)

func _on_meta_hover_start(meta_data) -> void:
	tooltip_manager._on_meta_hover_started(meta_data)

func _on_meta_hover_end(meta_data) -> void:
	tooltip_manager._on_meta_hover_ended(meta_data)
