shader_type spatial;

uniform sampler2D color_noise;
uniform sampler2D normal_map;
uniform float color_scale = 1.0;
uniform float normal_scale = 1.0;

varying vec2 squared_uv;

void vertex() {
	squared_uv = VERTEX.xz * UV;
}

void fragment() {
	ALBEDO = texture(color_noise, squared_uv * color_scale).rgb;
	
	NORMAL_MAP = texture(normal_map, squared_uv * normal_scale).rgb;
}
