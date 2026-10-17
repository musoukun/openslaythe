shader_type canvas_item;
render_mode blend_premul_alpha;
// Vera 用: outline.gdshader と同じ縁取りに加えて、輪郭から立ち上る炎と火の粉を描く。
// intensity (0〜1) が炎の強さ。0 なら縁取りだけ (outline.gdshader と同じ見た目)。
// 炎は絵の外へはみ出すので、vertex() で描く四角を margin px ずつ広げている。

uniform vec4 outline_color : source_color = vec4(0.95, 0.9, 0.75, 0.9);
uniform float width = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
// 絵の四辺を広げる量 (テクスチャのピクセル単位)。炎と火の粉はこの範囲までしか描けない
uniform float margin = 120.0;
// intensity 1 のときの炎の高さ (px)
uniform float flame_height = 110.0;
uniform vec4 color_outer : source_color = vec4(0.7, 0.06, 0.02, 1.0);
uniform vec4 color_mid : source_color = vec4(1.0, 0.4, 0.04, 1.0);
uniform vec4 color_core : source_color = vec4(1.0, 0.95, 0.65, 1.0);

// modulate / self_modulate (倒れて消える演出などの色と透明度)
varying vec4 modulate;
// 広げた後の UV。AnimatedSprite2D は fragment の UV を 0〜1 に切り詰める (clip_uv) ので、
// 余白の部分は UV ではなくこちらで読む (UV のままだと縁の 1 行が縦に伸びて筋になる)
varying vec2 uv;

void vertex() {
	modulate = COLOR;
	// 四隅で ±1。四角を外へ広げ、UV も同じだけ外へずらす (絵の位置と大きさは変わらない)
	vec2 dir = UV * 2.0 - 1.0;
	VERTEX += dir * margin;
	uv = UV + dir * margin * TEXTURE_PIXEL_SIZE;
}

// 広げた部分 (UV が 0〜1 の外) は何も無い扱い
vec4 body_color(sampler2D tex, vec2 at) {
	if (at.x < 0.0 || at.y < 0.0 || at.x > 1.0 || at.y > 1.0) {
		return vec4(0.0);
	}
	return texture(tex, at);
}

float body(sampler2D tex, vec2 at) {
	return body_color(tex, at).a;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vnoise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec4 col = body_color(TEXTURE, uv);

	// 縁取り (outline.gdshader と同じ)
	float a = 0.0;
	vec2 w = px * width;
	a = max(a, body(TEXTURE, uv + vec2(w.x, 0.0)));
	a = max(a, body(TEXTURE, uv - vec2(w.x, 0.0)));
	a = max(a, body(TEXTURE, uv + vec2(0.0, w.y)));
	a = max(a, body(TEXTURE, uv - vec2(0.0, w.y)));
	vec4 base = mix(vec4(outline_color.rgb, outline_color.a * a), col, col.a);
	vec3 rgb = base.rgb * base.a;	// premul
	float alpha = base.a;

	if (intensity > 0.001) {
		vec2 p = uv / px;	// テクスチャのピクセル座標
		float t = TIME;
		float h = flame_height * (0.2 + 0.8 * intensity * intensity);
		// 上へ流れるノイズ (y は下向きなので +t で模様が上がっていく)。強いほど速く揺らぐ
		float speed = 1.4 + 1.8 * intensity;
		float n = fbm(vec2(p.x * 0.04, p.y * 0.025 + t * speed));
		float n2 = fbm(vec2(p.x * 0.085 + 3.1, p.y * 0.05 + t * speed * 1.7));

		// 燃料: 自分のすぐ下 (横に少し揺れる) に体があるほど強い = 縁から上へ立ち上る
		float fuel = 0.0;
		for (int i = 0; i <= 8; i++) {
			float k = float(i) / 8.0;
			vec2 off = vec2((n - 0.5) * 30.0 * k, h * k);
			fuel = max(fuel, body(TEXTURE, uv + off * px) * pow(1.0 - k, 0.7));
		}
		// 横や下の縁にも薄くまとう
		float r = 4.0 + 10.0 * intensity;
		float side = 0.0;
		for (int i = 0; i < 8; i++) {
			float ang = float(i) * 0.785398;
			side = max(side, body(TEXTURE, uv + vec2(cos(ang), sin(ang)) * r * px));
		}
		fuel = max(fuel, side * 0.6);

		// 炎の舌: 燃料 × ノイズがしきい値を超えた所だけ燃える
		float v = fuel * (0.2 + 1.5 * n2 * n2 * 1.6);
		float th = 0.5 - 0.15 * intensity;
		float fa = smoothstep(th, th + 0.3, v) * (1.0 - col.a);
		// 弱いうちは薄く、強いほど濃い。最も強い段階では明滅する
		float flicker = 1.0 + 0.25 * intensity * intensity * sin(t * 13.0 + n * 6.0);
		fa *= mix(0.45, 1.0, intensity) * flicker;
		// 色: 外側は暗い赤、燃料が多い所ほど橙、芯は白っぽい黄色 (強いほど芯が出る)
		float heat = clamp(v * (0.7 + 0.6 * intensity) - 0.15, 0.0, 1.0);
		vec3 fc = mix(color_outer.rgb, color_mid.rgb, smoothstep(0.0, 0.5, heat));
		fc = mix(fc, color_core.rgb, smoothstep(0.55, 1.0, heat) * (0.4 + 0.6 * intensity));
		fa = clamp(fa, 0.0, 1.0);
		// 少し加算ぎみに重ねて光って見せる (premul で alpha を色より小さくする)
		rgb = fc * fa + rgb * (1.0 - fa * 0.75);
		alpha = clamp(fa * 0.75 + alpha * (1.0 - fa * 0.75), 0.0, 1.0);

		// 体の縁の内側が熱で光る
		float inner = 1.0;
		vec2 rr = px * 3.0;
		inner = min(inner, body(TEXTURE, uv + vec2(rr.x, 0.0)));
		inner = min(inner, body(TEXTURE, uv - vec2(rr.x, 0.0)));
		inner = min(inner, body(TEXTURE, uv + vec2(0.0, rr.y)));
		inner = min(inner, body(TEXTURE, uv - vec2(0.0, rr.y)));
		float rim = col.a * (1.0 - inner) * intensity * (0.6 + 0.4 * n2) * flicker;
		rgb += color_mid.rgb * rim * 0.8 * col.a;

		// 火の粉: 上へ流れる格子の中にまばらな点。体の上の方にだけ出す
		float cell = 13.0;
		vec2 q = vec2(p.x + sin(p.y * 0.05 + t) * 4.0, p.y + t * (40.0 + 50.0 * intensity)) / cell;
		vec2 id = floor(q);
		float rnd = hash(id);
		float density = 0.04 + 0.45 * intensity * intensity;
		if (rnd < density) {
			vec2 spot = vec2(hash(id + 1.7), hash(id + 5.3)) * 0.7 + 0.15;
			float d = length((fract(q) - spot) * cell);
			float dot_a = smoothstep(2.6 + intensity, 0.5, d);
			// 下に体がある所 (炎の届く高さの 2.5 倍まで) だけ
			float near = 0.0;
			for (int i = 1; i <= 5; i++) {
				float k = float(i) / 5.0;
				near = max(near, body(TEXTURE, uv + vec2(0.0, h * 2.5 * k) * px) * (1.1 - k * 0.8));
			}
			float sa = clamp(dot_a * near * (1.0 - col.a) * mix(0.5, 1.0, intensity), 0.0, 1.0);
			vec3 sc = mix(color_mid.rgb, color_core.rgb, hash(id + 9.1));
			rgb = sc * sa + rgb * (1.0 - sa * 0.6);
			alpha = clamp(sa * 0.6 + alpha * (1.0 - sa * 0.6), 0.0, 1.0);
		}
	}

	// modulate (premul なので色にも透明度を掛ける)
	COLOR = vec4(rgb * modulate.rgb * modulate.a, alpha * modulate.a);
}
