shader_type spatial;

uniform sampler2D water_color_gradient;
uniform float wave_speed: hint_range(0.0, 2.0) = 0.5;

float wave(float amp, float x, float wavelength, float speed) {
	float freq = 2.0 / wavelength;
	
	return amp * sin(x * freq + (TIME * wave_speed) * (speed * freq));
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Set the base color of the water to the given gradient uniform
	vec3 final_color = texture(water_color_gradient, UV).rgb;
	
	// Create some scrolling white foam waves and overlay them on top of the base color
	vec2 wave_uv = (UV - vec2(0.8, 0.0)) * 5.0;
	
	// Make the waves wavy
	float wave1 = wave(1.2, wave_uv.y, 1.1, 0.55);
	float wave2 = wave(0.95, wave_uv.y, 0.9, 0.5);
	float wave3 = wave(1.05, wave_uv.y, 1.2, 0.65);
	float wave_sum = 0.075 * cos(wave1 + wave2 + wave3);
	
	float waves = smoothstep(0.5, 3.0, fract((wave_uv.x * 1.25) + wave_sum - fract(TIME * wave_speed)));
	
	// Hide some of the waves
	vec2 wave_mask = step(vec2(0.0), wave_uv) * step(wave_uv, vec2(1.0));
	if (wave_mask.x > 0.0) {
		final_color += waves;
	}
	
	ALBEDO = final_color;
}
