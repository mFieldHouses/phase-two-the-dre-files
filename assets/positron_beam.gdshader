shader_type spatial;

render_mode unshaded;

uniform float cylinder_length = 2.0;
varying float vertex_pos_y;

uniform sampler2D noise_tex;

uniform float rotation_speed = 1.0;
uniform float emission_speed = 1.0;
uniform float stretch = 1.0;

void vertex() {
	vertex_pos_y = VERTEX.y * cylinder_length;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float blue_fac = texture(noise_tex, vec2(UV.x + TIME / 10.0 * rotation_speed, (UV.y / 3.0 / stretch + (TIME * 0.6 * emission_speed)) * cylinder_length)).r;
	blue_fac *= 0.8;
	blue_fac += 0.5;
	blue_fac = clamp(pow(blue_fac, 7.0), 0.0, 1.0);
	
	ALBEDO = vec3(0.0, 1.0 - pow(blue_fac, 0.6), 1.0);
	ALPHA = 1.0 - blue_fac;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
