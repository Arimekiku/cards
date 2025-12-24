shader_type canvas_item;

uniform vec2 offset = vec2(0.0, 0.0);
uniform float zoom = 1.0;

void fragment() {
    vec2 aspect = vec2(
        TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x,
        1.0
    );

    vec2 uv = (UV * 2.0 - 1.0) * aspect;

    if (length(uv) > 1.0) {
        discard;
    }

    vec2 sample_uv = UV - 0.5;
    sample_uv /= zoom;
    sample_uv += 0.5;
    sample_uv += offset * 0.5;
    sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));

    COLOR = texture(TEXTURE, sample_uv);
}
