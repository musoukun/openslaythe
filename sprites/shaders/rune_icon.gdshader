shader_type canvas_item;
// 祝福のアイコンを灰色に沈めたり、色を戻して明るくしたりする。
// saturation 0 で灰色、1 で元の色。brightness で明るさ。tint を掛ける (代償の小アイコンを赤くするなど)

uniform float saturation : hint_range(0.0, 1.0) = 0.0;
uniform float brightness = 0.5;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec4 col = COLOR;	// テクスチャの色 × modulate
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	col.rgb = mix(vec3(gray), col.rgb * tint.rgb, saturation) * brightness;
	COLOR = col;
}
