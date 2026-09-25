shader_type canvas_item;
// スプライトの外側に単色の縁取りを付ける (背景から浮かせる)

uniform vec4 outline_color : source_color = vec4(0.95, 0.9, 0.75, 0.9);
uniform float width = 2.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float a = 0.0;
	vec2 px = TEXTURE_PIXEL_SIZE * width;
	a = max(a, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a);
	a = max(a, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
	a = max(a, texture(TEXTURE, UV - vec2(0.0, px.y)).a);
	// 本体が無い所だけ縁取り色
	COLOR = mix(vec4(outline_color.rgb, outline_color.a * a), col, col.a);
}
