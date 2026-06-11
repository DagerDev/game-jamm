shader_type canvas_item;

uniform float speed : hint_range(-1.0, 1.0) = 0.1;

void fragment() {
	vec2 uv = UV;
	uv.x = fract(uv.x + TIME * speed);
	
	vec4 tex_color = texture(TEXTURE, uv);
	COLOR = tex_color * COLOR; // This line adds modulate/self_modulate back
}