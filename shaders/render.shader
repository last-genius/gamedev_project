shader_type spatial;

uniform sampler2D sim_tex;

void fragment() {
	vec4 input = texture(sim_tex, UV);
	ALBEDO = vec3(input.r, 0.0, 0.0);
}