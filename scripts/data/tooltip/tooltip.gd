class_name TooltipContainer
extends CanvasLayer

signal tooltip_mouse_entered
signal tooltip_mouse_exited

@onready var label = $tooltip_panel/tooltip_margin/vertical_box/text
@onready var container = $tooltip_panel

var tooltip_manager: TooltipManager = ServiceLocator.get_service(TooltipManager)

func _ready():
	container.mouse_entered.connect(func(): tooltip_mouse_entered.emit())
	container.mouse_exited.connect(func(): tooltip_mouse_exited.emit())
	
	label.meta_hover_started.connect(tooltip_manager._on_meta_hover_started)
	label.meta_hover_ended.connect(tooltip_manager._on_meta_hover_ended)

func set_text(text_content: String) -> void:
	label.text = text_content

func set_position(pos: Vector2) -> void:
	container.global_position = pos

func get_size() -> Vector2:
	return container.size
