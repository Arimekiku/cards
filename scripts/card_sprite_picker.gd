extends Sprite2D

var color_index: int = 0

func _ready() -> void:
	set_card_sprite(color_index)

func _process(_delta: float) -> void:
	pass

func set_card_sprite(index: int) -> void:
	var mat := material.duplicate()
	material = mat
	
	var mate = mat as ShaderMaterial
	mate.set_shader_parameter("card_index", index)
