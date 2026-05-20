shader_type spatial;

uniform sampler2D color_noise;
uniform sampler2D large_color_noise;
uniform sampler2D bump_map;
uniform float bump_scale = 1.0;
uniform float color_scale = 1.0;
uniform float large_color_scale = 1.0;
uniform float color_mix_amount: hint_range(0.0, 1.0, 0.1) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scaled_color_uv = UV * color_scale;
	vec2 scaled_large_color_uv = UV * large_color_scale;
	
	vec3 color_noise_texture = texture(color_noise, scaled_color_uv).rgb;
	vec3 large_color_noise_texture = texture(large_color_noise, scaled_large_color_uv).rgb;
	
	vec3 final_color = mix(color_noise_texture, large_color_noise_texture, color_mix_amount);
	
	ALBEDO = final_color;
	
	vec2 scaled_bump_uv = UV * bump_scale;
	
	NORMAL_MAP = texture(bump_map, scaled_bump_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
