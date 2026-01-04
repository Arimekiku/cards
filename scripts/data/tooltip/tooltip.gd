class_name TooltipContainer
extends CanvasLayer

@onready var label: RichTextLabel = $tooltip_panel/tooltip_margin/vertical_box/text
@onready var container: PanelContainer = $tooltip_panel

var tooltip_manager: TooltipManager = ServiceLocator.get_service(TooltipManager)
var parent_tooltip: TooltipContainer
var child_tooltip: TooltipContainer
var tooltip_id: String

func _ready() -> void:
	label.meta_hover_started.connect(_on_meta_hover)

func set_text(text_content: String) -> void:
	label.text = text_content

func set_position(pos: Vector2) -> void:
	container.global_position = pos

func get_size() -> Vector2:
	return container.size

func _on_meta_hover(meta) -> void:
	tooltip_manager.show_nested(meta, self)
