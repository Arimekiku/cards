shader_type canvas_item;

uniform sampler2DArray tex_array;
uniform int card_index = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(tex_array, vec3(UV, float(card_index)));
    COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
