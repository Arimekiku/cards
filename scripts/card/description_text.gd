extends RichTextLabel

var tooltip_manager: TooltipManager = ServiceLocator.get_service(TooltipManager)

func _ready():
	meta_hover_started.connect(tooltip_manager._on_meta_hover_started)
	meta_hover_ended.connect(tooltip_manager._on_meta_hover_ended)
