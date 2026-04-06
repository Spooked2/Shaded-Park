shader_type spatial;

uniform vec3 base_color: source_color;
uniform sampler2D color_noise;
uniform sampler2D coarse_bump_noise;
uniform sampler2D fine_bump_noise;
uniform sampler2D glitter_noise;

varying vec2 vertex_center;

void vertex() {
	vertex_center = (VERTEX.xz / 2.0) + 0.5;
}

void fragment() {
	vec3 fine_bumps = texture(fine_bump_noise, vertex_center).xyz;
	vec3 coarse_bumps = texture(coarse_bump_noise, vertex_center).xyz;
	
	NORMAL_MAP = mix(fine_bumps, coarse_bumps, 0.8);
	
	vec3 color = texture(color_noise, vertex_center).rgb;
	
	ALBEDO = color;
	
	ROUGHNESS = 0.99;
	METALLIC = 0.0;
	SPECULAR = 0.1;
}

void light() {
	float glitter = texture(glitter_noise, vertex_center).x;
	
	if (glitter > 0.5) {
		vec3 half_way = normalize(VIEW + LIGHT);
		float half_way_dot = dot(NORMAL, half_way);
		float specular_amount = pow(half_way_dot, 10.0) * ATTENUATION;
		SPECULAR_LIGHT += 0.03 * specular_amount * LIGHT_COLOR;
	}
	
	//vec3 half_way = normalize(VIEW + LIGHT);
	//float half_way_dot = dot(NORMAL, half_way);
	//float specular_amount = pow(half_way_dot, 10.0) * ATTENUATION;
	//SPECULAR_LIGHT += 0.03 * specular_amount * LIGHT_COLOR;
	
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}
