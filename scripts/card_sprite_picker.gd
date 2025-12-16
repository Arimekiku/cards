extends Sprite2D

func _ready() -> void:
	set_card_sprite(25)

func _process(_delta: float) -> void:
	pass

func set_card_sprite(index: int) -> void:
	var mat := material as ShaderMaterial
	mat.set_shader_parameter("card_index", index)
