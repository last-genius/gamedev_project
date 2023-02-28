shader_type canvas_item;

uniform sampler2D simulation_texture;
uniform sampler2D collision_texture;

uniform sampler2D left_texture: hint_black;
uniform sampler2D top_texture: hint_black;
uniform sampler2D right_texture: hint_black;
uniform sampler2D bottom_texture: hint_black;

uniform float phase = 0.18;
uniform float attenuation = 0.995;
uniform float deltaUV = 3.0;

uniform float size = 512.0;

uniform vec2 col_position;

void fragment() {
	float dv = 1.0 / size;
	float du = 1.0 / size;
	vec3 duv = vec3(du, dv, 0) * deltaUV;

	vec3 old_texture = texture(simulation_texture, UV).rgb;
	float pos_x, neg_x, pos_y, neg_y;
	
	if (UV.x > dv) {
		neg_x = texture(simulation_texture, UV - duv.xz).r;
	} else {
		neg_x = texture(left_texture, vec2(1.0, UV.y)).r;
	}
	
	if ((1.0 - UV.x) > dv) {
		pos_x = texture(simulation_texture, UV + duv.xz).r;
	} else {
		pos_x = texture(right_texture, vec2(0.0, UV.y)).r;
	}
	
	if (UV.y > du) {
		neg_y = texture(simulation_texture, UV - duv.zy).r;
	} else {
		neg_y = texture(bottom_texture, vec2(UV.x, 1.0)).r;
	}
	
	if ((1.0 - UV.y) > du) {
		pos_y = texture(simulation_texture, UV + duv.zy).r;
	} else {
		pos_y = texture(top_texture, vec2(UV.x, 0.0)).r;
	}

	float new_texture = (2.0 * old_texture.r - old_texture.g +
		phase * (neg_y + pos_y + neg_x + pos_x - 4.0 * old_texture.r)) * attenuation;
		
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