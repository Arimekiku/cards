extends Node2D
class_name RainbowWobbleText

@export var text: String = "HELLO GODOT!"
@export var char_spacing: float = 24.0
@export var wobble_amplitude: float = 5.0
@export var wobble_frequency: float = 5.0
@export var rainbow_speed: float = 0.5
@export var font: Font

var chars: Array = []
var elapsed: float = 0.0

func _ready():
	_create_chars()

func _process(delta: float) -> void:
	elapsed += delta
	_update_chars()

func _create_chars() -> void:
	var x_offset := -text.length() * char_spacing / 2.
	for c in text:
		var label := Label.new()
		label.text = c
		label.position = Vector2(x_offset, 0)
		
		if font != null:
			label.set("custom_fonts/font", font)
		
		add_child(label)
		chars.append(label)
		x_offset += char_spacing

func _update_chars() -> void:
	for i in chars.size():
		var char_s = chars[i]
		
		char_s.position.y = sin(elapsed * wobble_frequency + i * 0.5) * wobble_amplitude
		char_s.rotation = sin(elapsed * wobble_frequency + i * 0.5) * 0.1
		char_s.scale = Vector2.ONE * (1.0 + 0.1 * sin(elapsed * wobble_frequency + i * 0.5))
		
		var hue = fmod(i * 0.1 + elapsed * rainbow_speed, 1.0)
		char_s.modulate = Color.from_hsv(hue, 1.0, 1.0)
