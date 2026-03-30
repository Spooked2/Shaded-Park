shader_type spatial;

uniform vec3 base_color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = base_color;
}
