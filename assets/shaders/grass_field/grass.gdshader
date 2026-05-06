shader_type spatial;

uniform float density = 128;
uniform float thickness = 0.9;
uniform float strand_height = 0.095;
uniform float max_height = 5.0;
uniform float taper_strength = 7.0;
uniform float displacement_strength = 2.0;
uniform vec4 ground_color: source_color;
instance uniform int layer_count;
instance uniform int layer_index;
instance uniform bool is_ground = false;

varying float height;
varying vec2 squared_uv;

float hash11( uint n ) {
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 789221U) + 1376312589U;
	return float( n & uint(0x7fffffffU))/float(0x7fffffff);
}

void vertex() {
	float seperation = strand_height / float(layer_count);
	
	height = float(layer_index) * seperation;
	
	VERTEX.y += height;
	
	squared_uv = VERTEX.xz * UV;
	
	float value = hash11(uint((squared_uv * density).x));
	value = (value * 2.0) - 1.0;
	
	VERTEX += vec3(value, -0.3, value) * displacement_strength * (float(layer_index) / float(layer_count));
}

void fragment() {
	if (is_ground) {
		ALBEDO = ground_color.rgb;
	} else {
		vec2 uv_density = squared_uv * density;
		uvec2 uv_density_int = uvec2(floor(uv_density));
		
		uint seed = uv_density_int.x + 100u * uv_density_int.y + 1000u;
		
		float value = hash11(seed);
		
		vec2 local_space = fract(uv_density) * 2.0 - 1.0;
		
		float local_space_length = length(local_space);
		
		if (local_space_length > (thickness - (height * taper_strength))) {
			discard;
		}
		
		bool is_visible = (value - (height * max_height)) > 0.1;
		
		if (!is_visible) {
			discard;
		}
		
		ALBEDO = vec3(0.0, (0.01 + height * 8.0), 0.0);
		//ALBEDO = vec3(0.0, 0.8, 0.0);
	}
}

//void light() {
	//vec3 half_way = normalize(VIEW + LIGHT);
	//float half_way_dot = dot(NORMAL, half_way);
	//float specular_amount = pow(half_way_dot, 200.0) * ATTENUATION;
	////SPECULAR_LIGHT += 0.2 * specular_amount * LIGHT_COLOR;
	//
	//DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
//}
