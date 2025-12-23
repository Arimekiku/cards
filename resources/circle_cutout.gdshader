shader_type canvas_item;

uniform vec2 offset;

void fragment() {
    vec2 uv = UV * 3.0 - 1.5;
    float dist = length(uv);
	
    if (dist > 1.0) {
        discard;
    }

    vec2 sample_uv = UV + offset * 0.5;
    sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));
    COLOR = texture(TEXTURE, sample_uv);
}