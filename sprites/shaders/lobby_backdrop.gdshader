// タイトル/メニュー (ロビー) の背景絵を LoL のロビーのように暗い一色へ沈める。
// 明るさだけを残して一色に置き換え (彩度ゼロ) -> 軽くぼかす -> 明暗差を縮める -> 周辺を暗くする。
// 絵の中の森や遺跡はシルエットがうっすら分かる程度になり、上の文字やキャラ絵の邪魔をしない。
shader_type canvas_item;

// いちばん暗いところの色 (ほぼ黒の紺)
uniform vec3 shadow_color : source_color = vec3(0.02, 0.04, 0.06);
// いちばん明るいところの色 (暗い青緑)。全体の色味はこれで決まる
uniform vec3 light_color : source_color = vec3(0.10, 0.25, 0.27);
// 明暗差の強さ (0 で一色ベタ塗り、1 で元の明暗のまま)
uniform float contrast : hint_range(0.0, 1.0) = 0.7;
// ぼかしの半径 (絵の大きさに対する割合)。細部を読めなくする
uniform float blur_radius : hint_range(0.0, 0.02) = 0.006;
// 周辺の暗さ (0 で暗くしない)
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.75;
// 明るさを残す中心 (画面上の位置、0..1)
uniform vec2 vignette_center = vec2(0.5, 0.45);

float luminance(sampler2D tex, vec2 uv) {
	return dot(texture(tex, uv).rgb, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	// 中心 + 内側と外側の輪 (各 8 方向) を平均する簡単なぼかし。外側の輪は半分ずらして隙間を埋める
	float lum = luminance(TEXTURE, UV);
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.785398;
		lum += luminance(TEXTURE, UV + vec2(cos(angle), sin(angle)) * blur_radius * 0.5);
		angle += 0.392699;
		lum += luminance(TEXTURE, UV + vec2(cos(angle), sin(angle)) * blur_radius);
	}
	lum /= 17.0;
	// 中間の明るさ (0.5) を軸に明暗差を縮める
	lum = clamp(mix(0.5, lum, contrast), 0.0, 1.0);
	vec3 color = mix(shadow_color, light_color, lum);
	// 画面の端ほど暗く。SCREEN_UV を使うので絵の切り取り方に関係なく画面の周辺が沈む
	float dist = distance(SCREEN_UV, vignette_center);
	color *= 1.0 - vignette_strength * smoothstep(0.25, 0.85, dist);
	COLOR = vec4(color, 1.0);
}
