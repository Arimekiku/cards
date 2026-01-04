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
	var mouse_position = ServiceLocator.get_viewport().get_mouse_position() + Vector2(20, 20)
	var tooltip: TooltipContainer = tooltip_scene.instantiate()
	
	ServiceLocator.get_tree().current_scene.add_child(tooltip)
	tooltip.set_text(text_data)
	tooltip.set_position(mouse_position)
	tooltip.layer = active_tooltips.size() + 1
	tooltip.tooltip_mouse_entered.connect(_on_tooltip_entered)
	tooltip.tooltip_mouse_exited.connect(_on_tooltip_exited)
	active_tooltips.append(tooltip)

func _on_tooltip_entered():
	close_timer.stop()

func _on_tooltip_exited():
	close_timer.start()

func _close_last_tooltip():
	if active_tooltips.size() <= 0: return
	
	var tooltip = active_tooltips.pop_back()
	tooltip.queue_free()
