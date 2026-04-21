shader_type spatial;

uniform sampler2D color_noise;
uniform sampler2D bump_noise;
uniform sampler2D bump_normal;
uniform float bump_scale = 0.5;
uniform float normal_scale = 1.0;

varying vec2 vertex_center;

void vertex() {
	vertex_center = (VERTEX.xz * 0.5) + 0.5;
	
	float height = texture(bump_noise, vertex_center).x;
	
	height = smoothstep(0.0, 1.0, height);
	height *= bump_scale;
	
	float shore = step(distance(UV.x, 0.0), 0.25);
	float main_path = step(distance(UV.y, 0.5), 0.085);
	
	float flattening_mask = 1.0 - min((shore + main_path), 1.0);
	
	height *= max(flattening_mask, 0.3);
	
	VERTEX.y += height;
}

void fragment() {
	vec2 scaled_center = vertex_center * normal_scale;
	
	vec3 color = texture(color_noise, scaled_center).rgb;
	
	NORMAL_MAP = texture(bump_normal, scaled_center).rgb;
	
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
