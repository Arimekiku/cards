class_name TooltipManager
extends Service

var tooltip_scene = preload("res://scenes/tooltip.tscn")

var active_tooltips: Array = []
var close_timer: Timer

func init():
	close_timer = Timer.new()
	close_timer.wait_time = 0.3
	close_timer.one_shot = true
	close_timer.timeout.connect(_close_last_tooltip)
	ServiceLocator.add_child(close_timer)

func _on_meta_hover_started(meta_data):
	close_timer.stop()
	spawn_tooltip(meta_data)

func _on_meta_hover_ended(_meta_data):
	close_timer.start()

func spawn_tooltip(key_id):
	var text_data = "sss"
	var tooltip: TooltipContainer = tooltip_scene.instantiate()
	
	ServiceLocator.get_tree().current_scene.add_child(tooltip)
	tooltip.set_text(text_data)
	tooltip.layer = active_tooltips.size() + 1
	tooltip.tooltip_mouse_entered.connect(_on_tooltip_entered)
	tooltip.tooltip_mouse_exited.connect(_on_tooltip_exited)
	active_tooltips.append(tooltip)
	
	await ServiceLocator.get_tree().process_frame
	
	_smart_position_tooltip(tooltip)

func _on_tooltip_entered():
	close_timer.stop()

func _on_tooltip_exited():
	close_timer.start()

func _close_last_tooltip():
	if active_tooltips.size() <= 0: return
	
	var tooltip = active_tooltips.pop_back()
	tooltip.queue_free()

func _smart_position_tooltip(tooltip: TooltipContainer):
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
