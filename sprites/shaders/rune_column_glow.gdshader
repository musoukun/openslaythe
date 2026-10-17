shader_type canvas_item;
render_mode blend_add;
// 祝福の柱の「間接照明」(LoL のルーン選択風)。柱と同じ大きさの ColorRect に掛ける。
// 選んでいない柱は左右の仕切り線がうっすら見えるだけ。intensity を上げると、
// 上端から細い縦の光が差し込み、リングのまわりと柱全体に系統色の光がにじむ。

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float intensity : hint_range(0.0, 1.5) = 0.0;
uniform vec2 rect_size = vec2(160.0, 420.0);	// 柱の大きさ (px)。細い線の太さを px で決めるのに使う
uniform float ring_y = 70.0;	// リングの中心の高さ (px)

// x=center を中心にした幅 width (px) の細い線
float beam(float x, float center, float width) {
	float d = (x - center) / width;
	return exp(-d * d);
}

void fragment() {
	float fade = COLOR.a;	// modulate の透明度 (出てくる・消える演出)
	vec2 px = UV * rect_size;
	float cx = rect_size.x * 0.5;

	// 柱の左右の仕切り線 (上下の端は消える)
	float edge_fade = smoothstep(0.0, 0.2, UV.y) * (1.0 - smoothstep(0.55, 1.0, UV.y));
	float edge = (beam(px.x, 0.5, 0.8) + beam(px.x, rect_size.x - 0.5, 0.8)) * edge_fade;
	vec3 base = vec3(0.45, 0.5, 0.62) * edge * 0.18;

	// 上端から差し込む縦の光: 中央の長い1本 (リングへ届く) と、左右に短くなっていく2本ずつ
	float flow = 0.7 + 0.3 * sin(px.y * 0.08 - TIME * 3.0);	// 下へ流れる明滅
	float beams = beam(px.x, cx, 1.4) * exp(-px.y / (ring_y * 1.2)) * 2.2;
	beams += (beam(px.x, cx - 26.0, 1.0) + beam(px.x, cx + 26.0, 1.0)) * exp(-px.y / (ring_y * 0.6)) * 1.3;
	beams += (beam(px.x, cx - 52.0, 0.9) + beam(px.x, cx + 52.0, 0.9)) * exp(-px.y / (ring_y * 0.32)) * 1.0;
	// 短い線の先の光の粒 (回路の節)
	vec2 n1 = (px - vec2(cx - 26.0, ring_y * 0.6)) / 2.0;
	vec2 n2 = (px - vec2(cx + 26.0, ring_y * 0.6)) / 2.0;
	float nodes = (exp(-dot(n1, n1)) + exp(-dot(n2, n2))) * 1.1;

	// 上端のにじみ (横に広い楕円)
	vec2 t = (px - vec2(cx, 0.0)) / vec2(rect_size.x * 0.55, ring_y * 1.0);
	float bloom = exp(-dot(t, t)) * 0.35;
	// リングのまわりの後光
	vec2 r = (px - vec2(cx, ring_y)) / vec2(rect_size.x * 0.4, rect_size.x * 0.4);
	float halo = exp(-dot(r, r) * 1.4) * 0.55;
	// 柱全体ににじむ色: 上ほど濃く下へ消え、柱の中央ほど濃い。上端は少しだけぼかす
	float across = 1.0 - pow(abs(UV.x - 0.5) * 2.0, 2.0) * 0.6;
	float wash = (0.16 * exp(-px.y / (rect_size.y * 0.35)) + 0.025) * across * smoothstep(0.0, 18.0, px.y);
	// 色付きの仕切り線 (上ほど明るい)
	float lit_edge = (beam(px.x, 0.5, 0.8) + beam(px.x, rect_size.x - 0.5, 0.8)) * exp(-px.y / (rect_size.y * 0.5)) * 0.7;
	float lit = beams * flow + nodes + bloom + halo + wash + lit_edge;

	COLOR = vec4((base + glow_color.rgb * lit * intensity) * fade, 1.0);
}
