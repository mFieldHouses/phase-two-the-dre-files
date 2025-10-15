shader_type spatial;

render_mode unshaded, cull_back;

uniform float cylinder_length = 2.0;
varying float vertex_pos_y;

uniform sampler2D noise_tex;
uniform sampler2D displacement_noise_tex;

uniform float rotation_speed = 1.0;
uniform float emission_speed = 1.0;
uniform float stretch = 1.0;
uniform float opacity = 1.0;

void vertex() {
	vertex_pos_y = VERTEX.y;
	
	VERTEX.x += texture(displacement_noise_tex, vec2(0.0, (vertex_pos_y * 0.007 - (TIME * 0.4)))).r * 0.5 - 0.25;
	VERTEX.z += texture(displacement_noise_tex, vec2(0.0, (vertex_pos_y * 0.007 - (TIME * 0.43)))).r * 0.5 - 0.25;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float blue_fac = texture(noise_tex, vec2(UV.x + TIME / 10.0 * rotation_speed, (UV.y / 3.0 / stretch + (TIME * 0.6 * emission_speed)) * cylinder_length)).r;
	blue_fac *= 0.8;
	blue_fac += 0.5;
	blue_fac = clamp(pow(blue_fac, 7.0), 0.0, 1.0);
	
	ALBEDO = vec3(clamp(1.0 - pow(blue_fac * 20.0, 2), 0.0, 1.0), (1.0 - pow(blue_fac, 0.6)) * 2.0, 1.5);
	ALPHA = (1.0 - blue_fac / 1.5) * opacity;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
