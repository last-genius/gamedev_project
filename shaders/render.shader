shader_type spatial;

uniform sampler2D sim_tex;
uniform sampler2D col_tex;
uniform float amplitude = 1;
uniform float murkiness = 0.01;
//uniform float refraction = 1;

uniform vec3 shallow_water_color = vec3(0.27, 0.682, 1);
uniform vec3 deep_water_color = vec3(0, 0.0823, 0.34);
uniform vec3 waves_color = vec3(0.7, 0.7, 0.7);

void fragment() {
	float d = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	d = d * 2.0 - 1.0;
	d = PROJECTION_MATRIX[3][2] / (d + PROJECTION_MATRIX[2][2]);
	d = d + VERTEX.z;
	float depth = exp(-d * murkiness);
	
	vec4 input = texture(sim_tex, UV);
	
	vec3 duv = vec3(4.0 / 512.0, 4.0 / 512.0, 0);
	float v1 = texture(sim_tex, UV - duv.xz).y;
	float v2 = texture(sim_tex, UV + duv.xz).y;
	float v3 = texture(sim_tex, UV - duv.zy).y;
	float v4 = texture(sim_tex, UV + duv.zy).y;
	
	vec3 normal = normalize(vec3(v1 - v2, v3 - v4, 0.3));
	
	
	/*
	// An attempt at a refraction shader
	vec2 new_normal = (normal * refraction).xy + SCREEN_UV;
	vec4 refracted_tex = texture(SCREEN_TEXTURE, new_normal);
	ALBEDO = mix(refracted_tex.xyz, mixed_colors, 0.9); */
	
	//ALBEDO = mix(deep_water_color, shallow_water_color, depth);
	ALBEDO = mix(mix(deep_water_color, shallow_water_color, depth), waves_color, input.r);
	//NORMAL = normal;
}

void vertex() {
	/*if (texture(col_tex, UV).r == 0.0f) {
		vec4 input = texture(sim_tex, UV);
		VERTEX.y += amplitude * input.r * NORMAL.y;
	}*/
}