shader_type canvas_item;
uniform float corner_radius : hint_range(0, 50) = 12.0;
uniform float border_width : hint_range(0, 10) = 2.0;
uniform vec4 border_color : source_color = vec4(0, 0, 0, 1);

void fragment() {
    vec2 size = vec2(textureSize(TEXTURE, 0));
    vec2 pos = UV * size;
    vec2 corner = vec2(corner_radius);
    
    vec2 dist = min(pos, size - pos);
    float d = length(max(corner - dist, 0.0)) - corner_radius;
    
    float alpha = smoothstep(1.0, 0.0, d);
    float border = smoothstep(border_width + 1.0, border_width, abs(d));
    
    vec4 tex = texture(TEXTURE, UV);
    COLOR = mix(tex * vec4(1,1,1,alpha), border_color, border);
}