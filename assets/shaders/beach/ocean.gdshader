shader_type spatial;

uniform sampler2D water_color_gradient;
uniform sampler2D wave_break_noise;
uniform float wave_speed: hint_range(0.0, 2.0) = 0.5;
uniform float wave_amount: hint_range(0.1, 3.0) = 1.1;
uniform float wave_start_position: hint_range(0.0, 0.9) = 0.7;
uniform float wave_time_scale: hint_range(0.0, 2.0) = 0.2;
uniform float wave_intensity: hint_range(0.0, 5.0) = 1.0;
uniform float wave_scale: hint_range(0.0, 4.0) = 1.0;

const int wave_detail = 64;

vec2 wave(float amp, float x, float wavelength, float speed) {
	float freq = 2.0 / wavelength;
	
	return vec2(amp * sin(x * freq + (TIME * wave_speed) * (speed * freq)),
	freq * amp * cos(x * freq + (TIME * wave_speed) * (speed * freq)));
}

vec3 fbm(vec3 value, float base_seed) {
	float freq = 1.0;
	float amp = 1.0;
	float speed = 2.0 * wave_time_scale;
	float seed = base_seed;
	
	vec3 variable_value = value;
	
	float sine_sum = 0.0;
	vec2 cosine_sum = vec2(0.0);
	float amp_sum = 0.0;
	
	float max_peak = 1.0;
	float peak_offset = 1.2;
	float drag = 0.5;
	
	for (int i = 0; i < wave_detail; i++) {
		vec2 direction = normalize(vec2(cos(seed), sin(seed)));
		
		float wave_base = dot(direction, variable_value.xz) * freq + (TIME * speed);
		float new_wave = amp * exp(max_peak * sin(wave_base) - peak_offset);
		vec2 differential = freq * direction * (max_peak * new_wave * cos(wave_base));
		
		sine_sum += new_wave;
		variable_value.xz += -differential * amp * drag;
		
		cosine_sum += differential;
		
		amp_sum += amp;
		amp *= 0.82;
		freq *= 1.18;
		speed *= 1.1;
		seed += 4.3;
	}
	
	vec3 output = vec3(sine_sum, cosine_sum) / amp_sum;
	output.x *= 1.48;
	
	return output;
}

void vertex() {
	vec3 wave_sums = fbm(VERTEX * wave_scale, 4.0);
	
	wave_sums *= (wave_intensity * (1.0 - UV.x));
	
	VERTEX.y += wave_sums.x;
	
	NORMAL += normalize(vec3(-wave_sums.y, 1.0, -wave_sums.z));
}

void fragment() {
	// Set the base color of the water to the given gradient uniform
	vec3 final_color = texture(water_color_gradient, UV).rgb;
	
	// Create some scrolling white foam waves and overlay them on top of the base color
	vec2 wave_uv = (UV - vec2(wave_start_position, 0.0)) * 5.0;
	
	// Make the foam waves wavy
	float wave1 = wave(1.25, wave_uv.y, 0.45, wave_time_scale).x;
	float wave2 = wave(0.95, -wave_uv.x, 1.1, wave_time_scale).x;
	float wave3 = wave(0.55, wave_uv.y, 1.6, wave_time_scale).x;
	float wave4 = wave(1.45, wave_uv.y, 0.45, wave_time_scale).x;
	float wave5 = wave(0.75, -wave_uv.y, 1.3, wave_time_scale).x;
	float wave6 = wave(0.45, wave_uv.x, 1.9, wave_time_scale).x;
	float wave_sum = 0.05 * sin(wave1 + wave2 + wave3 + wave4 + wave5 + wave6);
	
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
	float specular_amount = pow(half_way_dot, 200.0) * ATTENUATION;
	SPECULAR_LIGHT += 0.2 * specular_amount * LIGHT_COLOR;
	
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}

