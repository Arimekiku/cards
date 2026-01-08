shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform float dissolve_progress : hint_range(0.0, 1.0) = 0.0;
uniform float burn_size : hint_range(0.0, 1.0) = 0.05;
uniform vec4 burn_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform vec2 target_point = vec2(0.5, 0);
uniform float curve_power : hint_range(0.1, 2.0) = 1.0;

// The Color Gradient: Hottest -> Middle -> Coolest
uniform vec4 fire_core : source_color = vec4(1.0, 1.0, 0.5, 1.0); // Pale Yellow/White
uniform vec4 fire_mid : source_color = vec4(1.0, 0.5, 0.0, 1.0);  // Bright Orange
uniform vec4 fire_edge : source_color = vec4(0.5, 0.0, 0.0, 1.0); // Dark Red/Brown

void fragment() {
	vec4 tex_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (tex_color.a > 0.0001) {
		tex_color.rgb /= tex_color.a;
	}
	
    float dist = distance(UV, target_point);
    float shape_gradient = pow(1.2 - dist, curve_power);

    // 2. Add Noise
    float noise = texture(noise_texture, UV).r;
    float final_mask = shape_gradient - (noise * 0.2);
    
    // 3. Dissolve Check
    if (final_mask < dissolve_progress) {
        discard;
    }
    
    // 4. FIRE GRADIENT LOGIC
    // Check if we are inside the burn zone
    if (final_mask < dissolve_progress + burn_size) {
        
        // Calculate "How far into the fire are we?"
        // 0.0 = Right at the edge of the hole (HOTTEST)
        // 1.0 = Furthest part of the glow (COOLEST)
        float burn_depth = (final_mask - dissolve_progress) / burn_size;
        
        // Create the gradient based on depth
        vec3 fire_color;
        
        if (burn_depth < 0.3) {
            // Inner Core (0.0 to 0.3): Mix Core -> Mid
            // We map 0.0-0.3 to 0.0-1.0 for the mix function
            float t = burn_depth / 0.3;
            fire_color = mix(fire_core.rgb, fire_mid.rgb, t);
        } else {
            // Outer Edge (0.3 to 1.0): Mix Mid -> Edge
            // We map 0.3-1.0 to 0.0-1.0
            float t = (burn_depth - 0.3) / 0.7;
            fire_color = mix(fire_mid.rgb, fire_edge.rgb, t);
        }
        
        // Add a "Pulsing" effect (Optional but cool)
        // Makes the fire flicker slightly
        fire_color *= (1.0 + sin(TIME * 10.0) * 0.1);

        // Mix the fire onto the texture
        // We use step/smoothstep to ensure the fire completely covers the pixels near the hole
        tex_color.rgb = mix(tex_color.rgb, fire_color, 0.9);
    }
    
    COLOR = tex_color;
}