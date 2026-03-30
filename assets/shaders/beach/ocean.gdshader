shader_type spatial;

uniform sampler2D water_color_gradient;
uniform sampler2D wave_break_noise;
uniform float wave_speed: hint_range(0.0, 2.0) = 0.5;
uniform float wave_start_position: hint_range(0.0, 0.9) = 0.7;

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
	vec2 wave_uv = (UV - vec2(wave_start_position, 0.0)) * 5.0;
	
	// Make the waves wavy
	float wave1 = wave(0.45, wave_uv.y, 0.25, 0.55);
	float wave2 = wave(0.95, wave_uv.y, 0.6, 0.5);
	float wave3 = wave(0.55, wave_uv.y, 0.4, 0.65);
	float wave_sum = 0.075 * cos(wave1 + wave2 + wave3);
	
	float waves = smoothstep(0.5, 2.5, fract((wave_uv.x * 1.1) + wave_sum - fract(TIME * wave_speed)));
	
	// Make the waves fade in
	float wave_fade = smoothstep(0.2, 1.0, wave_uv.x);
	waves *= wave_fade;
	
	// Break up the long waves for a more realistic look
	// It's worth noting Wind Waker does not do this
	vec3 wave_break_mask = texture(wave_break_noise, (UV - vec2(TIME * 0.05, TIME * 0.005))).rgb;
	
	float wave_break_final = smoothstep(0.2, 3.0, wave_break_mask.r);
	
	waves = max(waves - wave_break_final, 0.0);
	
	// Hide some of the waves in the back
	vec2 wave_mask = step(vec2(0.0), wave_uv);
	if (wave_mask.x > 0.0) {
		final_color += waves;
	}
	
	ALBEDO = final_color;
}
