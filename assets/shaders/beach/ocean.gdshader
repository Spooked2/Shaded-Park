shader_type spatial;

uniform sampler2D water_color_gradient;
uniform sampler2D wave_break_noise;
uniform float wave_speed: hint_range(0.0, 2.0) = 0.5;
uniform float wave_amount: hint_range(0.1, 3.0) = 1.1;
uniform float wave_start_position: hint_range(0.0, 0.9) = 0.7;
uniform float wave_time_scale: hint_range(0.0, 2.0) = 0.2;
uniform float wave_intensity: hint_range(0.0, 2.0) = 0.13;

vec2 wave(float amp, float x, float wavelength, float speed) {
	float freq = 2.0 / wavelength;
	
	return vec2(amp * sin(x * freq + (TIME * wave_speed) * (speed * freq)),
	freq * amp * cos(x * freq + (TIME * wave_speed) * (speed * freq)));
}

vec3 wave_v2(vec2 pos, float amp, float wavelength, float time_scale) {
	float freq = 2.0 / wavelength;
	float time = TIME * wave_speed;
	float speed_mod = time_scale * freq;
	
	float input_x = pos.x * freq - time * speed_mod;
	float input_y = pos.y * freq - time * speed_mod * 2.0;
	float input_z = input_x + input_y;
	
	float sine_result = amp * sin(input_z) * pos.x;
	
	float cosine_x = cos(input_z) * freq * amp * pos.x + sin(input_z) * amp;
	float cosine_y = cos(input_z) * freq * amp * pos.x * 2.0;
	
	return vec3(sine_result, cosine_x, cosine_y);
}

void vertex() {
	vec3 wave1 = wave_v2(UV.xx, 1.8, 0.2, wave_time_scale);
	vec3 wave2 = wave_v2(-UV, 1.4, 0.7, wave_time_scale);
	vec3 wave3 = wave_v2(UV.xx, 0.8, 1.1, wave_time_scale);
	vec3 wave4 = wave_v2(-UV, 0.4, 2.25, wave_time_scale);
	vec3 wave5 = wave_v2(-UV.yy, 1.6, 0.4, wave_time_scale);
	vec3 wave6 = wave_v2(UV.yy, 1.2, 0.9, wave_time_scale);
	vec3 wave7 = wave_v2(-UV.yy, 0.8, 1.25, wave_time_scale);
	vec3 wave8 = wave_v2(UV.yx, 0.2, 2.25, wave_time_scale);
	
	float sine_wave_sum = sin(wave1.x 
	+ wave2.x 
	+ wave3.x 
	+ wave4.x
	+ wave5.x 
	+ wave6.x 
	+ wave7.x 
	+ wave8.x);
	
	VERTEX += NORMAL * (sine_wave_sum * wave_intensity);
	
	float cosine_wave_sum_x = (wave1.y 
	+ wave2.y 
	+ wave3.y 
	+ wave4.y
	+ wave5.y 
	+ wave6.y 
	+ wave7.y 
	+ wave8.y) * wave_intensity;
	
	float cosine_wave_sum_y = (wave1.z 
	+ wave2.z 
	+ wave3.z 
	+ wave4.z
	+ wave5.z 
	+ wave6.z 
	+ wave7.z 
	+ wave8.z) * wave_intensity;
	
	NORMAL += normalize(vec3(cosine_wave_sum_x, 1.0, cosine_wave_sum_y));
	
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
	float specular_amount = pow(half_way_dot, 23.0 * 23.0) * ATTENUATION;
	SPECULAR_LIGHT += 0.2 * specular_amount * LIGHT_COLOR;
	
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}

