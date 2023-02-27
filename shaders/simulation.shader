shader_type canvas_item;

uniform sampler2D simulation_texture;
uniform sampler2D collision_texture;

uniform float phase = 0.18;
uniform float attenuation = 0.995;
uniform float deltaUV = 3.0;

uniform vec2 col_position;

void fragment() {
	float dv = 1.0 / 512.0;
	float du = 1.0 / 512.0;
	vec3 duv = vec3(du, dv, 0) * deltaUV;

	vec3 old_texture = texture(simulation_texture, UV).rgb;

	float new_texture = (2.0 * old_texture.r - old_texture.g + phase * (
		texture(simulation_texture, UV - duv.zy).r +
		texture(simulation_texture, UV + duv.zy).r +
		texture(simulation_texture, UV - duv.xz).r +
		texture(simulation_texture, UV + duv.xz).r - 4.0 * old_texture.r)) * attenuation;
		
	vec2 col_uv = vec2(UV.x, 1.0 - UV.y);
	float col = texture(collision_texture, col_uv).r;
	float prevCol = old_texture.b;
	
	if (col > 0.0 && prevCol == 0.0) {
        new_texture += col * 0.5;
    }
	
	if (prevCol > 0.0 && col == 0.0) {
		new_texture -= prevCol * 0.5;
	}
		
	COLOR = vec4(new_texture, old_texture.r, col, 1);
}