shader_type spatial;

uniform sampler2D water_color_gradient;
uniform sampler2D wave_break_noise;
uniform float wave_speed: hint_range(0.0, 2.0) = 0.5;
uniform float wave_amount: hint_range(0.1, 3.0) = 1.1;
uniform float wave_start_position: hint_range(0.0, 0.9) = 0.7;

float wave(float amp, float x, float wavelength, float speed) {
	float freq = 2.0 / wavelength;
	
	return amp * sin(x * freq + (TIME * wave_speed) * (speed * freq));
}

void vertex() {
	float wave1 = wave(1.0, UV.y, 0.8, 1.1);
	float wave2 = wave(1.2, VERTEX.z, 1.18, 1.14);
	float wave3 = wave(0.9, UV.x, 1.22, 0.9);
	float wave4 = wave(1.1, VERTEX.x, 0.83, 0.85);
	
	float sine_wave_sum = wave1 + wave2 + wave3 + wave4;
	
	VERTEX += NORMAL * (sine_wave_sum * 0.05);
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
	float wave_sum = 0.075 * sin(wave1 + wave2 + wave3);
	
	float waves = smoothstep(0.5, 2.5, fract((wave_uv.x * wave_amount) + wave_sum - fract(TIME * wave_speed)));
	
	// Make the waves fade in
	float wave_fade = smoothstep(0.2, 1.0, wave_uv.x);
	waves *= wave_fade;
	
	// Break up the long waves for a more realistic look
	// It's worth noting Wind Waker does not do this
	vec3 wave_break_mask = texture(wave_break_noise, (UV - vec2(TIME * 0.05, TIME * 0.005))).rgb;
	
	float wave_break_final = smoothstep(0.2, 3.0, wave_break_mask.r);
	
	waves = max(waves - wave_break_final, 0.0);
	
	// Add swash wave
	float swash_wave = smoothstep(0.88, 1.0, UV.x);
	final_color += swash_wave;
	
	float flow = cos(TAU * waves + 3.5);
	
	// Normalize the wave so the output is always between 0 and 1
	flow = 0.5 * (1.0 - (flow));
	flow *= 1.5;
	
	ALPHA *= max(smoothstep(1.0, 0.6, UV.x), 0.85);
	
	// Only apply the swash wave to the designated area
	if (swash_wave > 0.0) {
		ALPHA *= smoothstep(0.7, 0.2, flow * swash_wave);
	}
	
	// Hide some of the waves in the back
	vec2 wave_mask = step(vec2(0.0), wave_uv);
	if (wave_mask.x > 0.0) {
		final_color += waves;
	}
	
	ALBEDO = final_color;
}

void light() {
	vec3 half_way = normalize(VIEW + LIGHT);
	float half_way_dot = dot(NORMAL, half_way);
	float specular_amount = max(pow(half_way_dot, 23.0 * 23.0), 0.0) * ATTENUATION;
	SPECULAR_LIGHT += 0.2 * specular_amount * LIGHT_COLOR;
	
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}

