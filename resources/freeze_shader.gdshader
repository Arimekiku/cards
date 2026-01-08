shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform vec4 ice_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 frost_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float freeze_progress : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	
	float noise = texture(noise_texture, UV).r;
	float freeze_mask = smoothstep(1.0 - freeze_progress, (1.0 - freeze_progress) + 0.2, noise);
	vec3 icy_bg = mix(c.rgb, ice_color.rgb, ice_color.a);
	
	float frost_intensity = smoothstep(0.4, 0.6, noise);
	vec3 frozen_look = mix(icy_bg, frost_color.rgb, frost_intensity * frost_color.a);
	
	vec3 final_rgb = mix(c.rgb, frozen_look, freeze_mask);
	
	COLOR = vec4(final_rgb, c.a);
}