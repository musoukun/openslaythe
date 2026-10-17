// カードのレア加工の輝き (遊戯王のレア / スーパー / ウルトラ / シークレット / パラレルのイメージ)。
// カードに重ねた板 (ColorRect) に加算合成で描く。tier 0 で何も描かない。段階が上がるほど光が足される:
//   1 レア: 銀の光が斜めに走る
//   2 スーパー: 金色の光の帯 + 縁の輝き
//   3 ウルトラ: 虹色のホロ
//   4 シークレット: きらめく星
//   5 パラレル: 全面の虹の斜め縞
// 説明文の欄 (text_box) は光を弱めて文字を読めるようにする。
shader_type canvas_item;
render_mode blend_add;

uniform int tier = 0;
uniform float phase = 0.0;	// カードごとにずらして、光が全部同時に走らないようにする
uniform vec2 card_size = vec2(144.0, 184.0);
uniform float corner_radius = 10.0;
uniform vec4 text_box = vec4(0.05, 0.6, 0.95, 0.97);	// 説明文の欄 (UV の左, 上, 右, 下)

vec3 hue(float h) {
	return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 角丸の長方形の内側で 1
float rounded_mask(vec2 uv) {
	vec2 p = uv * card_size;
	vec2 half_size = card_size * 0.5;
	vec2 d = abs(p - half_size) - (half_size - vec2(corner_radius));
	float dist = length(max(d, 0.0)) - corner_radius;
	return 1.0 - smoothstep(-1.0, 0.5, dist);
}

// 縁に近いほど 1
float edge(vec2 uv) {
	vec2 p = uv * card_size;
	float d = min(min(p.x, card_size.x - p.x), min(p.y, card_size.y - p.y));
	return 1.0 - smoothstep(0.0, 9.0, d);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME + phase;
	vec3 light = vec3(0.0);

	// 斜めに走る光の帯 (段階が上がるほど速く・太く)
	float speed = 0.35 + 0.1 * float(tier);
	float band_pos = fract(t * speed) * 2.6 - 0.8;
	float diag = uv.x * 0.8 + uv.y * 0.5;
	float width = 0.05 + 0.02 * float(tier);
	float band = 1.0 - smoothstep(0.0, width, abs(diag - band_pos));

	if (tier >= 1) {
		light += vec3(0.85, 0.9, 1.0) * band * 0.55;
	}
	if (tier >= 2) {
		light += vec3(1.0, 0.78, 0.3) * band * 0.45;
		light += vec3(1.0, 0.8, 0.35) * edge(uv) * (0.25 + 0.15 * sin(t * 3.0));
	}
	if (tier >= 3) {
		float h = fract(uv.x * 0.9 + uv.y * 0.6 + t * 0.12);
		light += hue(h) * 0.16;
		light += hue(h + 0.3) * band * 0.4;
	}
	if (tier >= 4) {
		vec2 cell = floor(uv * vec2(10.0, 12.0));
		float rnd = hash(cell);
		vec2 in_cell = fract(uv * vec2(10.0, 12.0)) - 0.5;
		float twinkle = pow(max(sin(t * (2.0 + rnd * 3.0) + rnd * 6.28), 0.0), 12.0);
		float star = smoothstep(0.22, 0.0, length(in_cell)) * step(0.55, rnd);
		light += vec3(1.0) * star * twinkle * 1.2;
	}
	if (tier >= 5) {
		float stripes = 0.5 + 0.5 * sin((uv.x + uv.y) * 70.0 - t * 4.0);
		light += hue(fract(uv.y * 1.5 - t * 0.25)) * stripes * 0.22;
		light += hue(fract(t * 0.3)) * edge(uv) * 0.45;
	}

	// 説明文の欄は弱める (文字を読めるように)
	float in_text = step(text_box.x, uv.x) * step(uv.x, text_box.z) * step(text_box.y, uv.y) * step(uv.y, text_box.w);
	light *= mix(1.0, 0.18, in_text);

	COLOR = vec4(light * rounded_mask(uv), 1.0);
}
