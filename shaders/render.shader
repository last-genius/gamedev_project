shader_type spatial;

uniform sampler2D col_tex;
uniform float murkiness = 0.01;

uniform vec3 shallow_water_color = vec3(0.27, 0.682, 1);
uniform vec3 deep_water_color = vec3(0, 0.0823, 0.34);

void fragment() {
	float d = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	d = d * 2.0 - 1.0;
	d = PROJECTION_MATRIX[3][2] / (d + PROJECTION_MATRIX[2][2]);
	d = d + VERTEX.z;
	float depth = exp(-d * murkiness);
	
	ALBEDO = mix(deep_water_color, shallow_water_color, depth);
}