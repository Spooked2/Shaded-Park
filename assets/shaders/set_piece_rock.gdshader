shader_type spatial;

uniform sampler2D color_noise;
uniform sampler2D bump_map;
uniform float texture_scale = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scaled_uv = UV * texture_scale;
	
	vec3 final_color = texture(color_noise, scaled_uv).rgb;
	
	ALBEDO = final_color;
	
	NORMAL_MAP = texture(bump_map, scaled_uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
