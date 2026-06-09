shader_type spatial;
render_mode world_vertex_coords, depth_prepass_alpha;

global uniform float wind_intensity;
global uniform float wind_scroll_speed;
global uniform vec3 wind_direction;
global uniform sampler2D wind_noise;

uniform sampler2D texture_albedo : source_color;

void vertex() {
	float wind_amount = texture(wind_noise, (VERTEX.xz + (TIME * wind_scroll_speed))).x;
	
	float wind_strength = COLOR.r * wind_intensity;
	
	VERTEX += wind_direction * (wind_strength * wind_amount);
	
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
