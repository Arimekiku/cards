class_name TooltipManager
extends Service

var tooltip_scene = preload("res://scenes/tooltip.tscn")

var active_tooltips: Array[TooltipContainer] = []
var close_timer: Timer

var card_database: CardDatabase

func init() -> void:
	card_database = ServiceLocator.get_service(CardDatabase)
	
	close_timer = Timer.new()
	close_timer.wait_time = 0.3
	close_timer.timeout.connect(_try_close_tooltips)
	ServiceLocator.add_child(close_timer)

func _on_meta_hover_started(meta_data) -> void:
	close_timer.stop()
	show_tooltip(meta_data)

func _on_meta_hover_ended(_meta_data) -> void:
	close_timer.start()

func show_tooltip(key_id: String) -> void:
	clear_all()
	
	var text_data = card_database.KEYWORDS[key_id]
	var tooltip: TooltipContainer = tooltip_scene.instantiate()
	ServiceLocator.get_tree().current_scene.add_child(tooltip)
	
	await ServiceLocator.get_tree().process_frame
	
	tooltip.tooltip_id = key_id
	tooltip.set_text(text_data)
	
	active_tooltips.append(tooltip)
	_smart_position_tooltip(tooltip)

func show_nested(key_id: String, parent: TooltipContainer) -> void:
	erase_nested(parent)
	
	var text_data = card_database.KEYWORDS[key_id]
	var tooltip: TooltipContainer = tooltip_scene.instantiate()
	ServiceLocator.get_tree().current_scene.add_child(tooltip)
	
	await ServiceLocator.get_tree().process_frame
	
	tooltip.tooltip_id = key_id
	tooltip.parent_tooltip = parent
	tooltip.set_text(text_data)
	parent.child_tooltip = tooltip
	
	active_tooltips.append(tooltip)
	_smart_position_tooltip(tooltip)

func clear_all() -> void:
	for t in active_tooltips:
		t.queue_free()
	
	active_tooltips.clear()

func _try_close_tooltips() -> void:
	var mouse := ServiceLocator.get_viewport().get_mouse_position()
	
	for t in active_tooltips:
		if t.container.get_global_rect().has_point(mouse):
			return
	
	clear_all()

func erase_nested(tooltip: TooltipContainer) -> void:
	if not tooltip.child_tooltip:
		return
	
	active_tooltips.erase(tooltip.child_tooltip)
	erase_nested(tooltip.child_tooltip)
	tooltip.child_tooltip.queue_free()

func _smart_position_tooltip(tooltip: TooltipContainer) -> void:
	var viewport_rect = ServiceLocator.get_viewport().get_visible_rect()
	var mouse_pos = ServiceLocator.get_viewport().get_mouse_position()
	
	var offset = Vector2(15, 15)
	var tip_size = tooltip.get_size()
	var final_pos = mouse_pos + offset
	
	if final_pos.x + tip_size.x > viewport_rect.size.x:
		final_pos.x = mouse_pos.x - tip_size.x - offset.x
	if final_pos.y + tip_size.y > viewport_rect.size.y:
		final_pos.y = mouse_pos.y - tip_size.y - offset.y
	
	final_pos.x = max(final_pos.x, 0)
	final_pos.y = max(final_pos.y, 0)
	tooltip.set_position(final_pos)
