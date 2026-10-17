shader_type canvas_item;
// 祝福のアイコンを囲む細い円のリング (LoL のルーン選択風)。正方形の ColorRect に掛ける。
// 中は暗い円で、アイコンをその上に重ねる。intensity で灰色から系統色へ光る。

uniform vec4 ring_color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float intensity : hint_range(0.0, 1.5) = 0.0;
uniform float radius = 0.44;	// リングの半径 (UV。0.5 で端に接する)

void fragment() {
	float r = length(UV - 0.5);
	float aa = fwidth(r);
	// 細いリングと、その外にもう1本ごく細いリング
	float ring = 1.0 - smoothstep(0.008, 0.008 + aa, abs(r - radius));
	float outer = (1.0 - smoothstep(0.003, 0.003 + aa, abs(r - radius - 0.035))) * 0.5;
	// リングの光のにじみ (内と外)
	float glow = exp(-pow((r - radius) / 0.03, 2.0)) * intensity;
	float disc = 1.0 - smoothstep(radius - aa, radius, r);

	vec3 gray = vec3(0.42, 0.45, 0.52);
	vec3 lit = mix(gray, ring_color.rgb * 1.25, clamp(intensity, 0.0, 1.0));
	vec4 col = vec4(0.02, 0.03, 0.06, disc * 0.85);	// 中の暗い円
	col = mix(col, vec4(lit, 1.0), clamp(glow * 0.6, 0.0, 1.0));
	col = mix(col, vec4(lit, 1.0), clamp(ring + outer * (0.4 + intensity * 0.6), 0.0, 1.0));
	col.a *= COLOR.a;
	COLOR = col;
}
