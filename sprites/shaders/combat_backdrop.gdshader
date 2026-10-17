// 戦闘背景の細部を少し落として、キャラと敵を浮き出させる (絵のコンセプトはそのまま、細かさを 10 -> 7 くらいに)。
// 1. Kuwahara フィルタ: 周りの 4 つの区画のうち色のばらつきが一番小さい区画の平均を取る。
//    葉や石目のような細かい模様はならされ、アーチや幹の輪郭 (大きな形の境目) は残るので、筆で大きく塗った絵に近づく。
//    区画が四角いので、そのままだとモザイクのような段が出る。範囲全体の平均 (軽いぼかし) を少し混ぜてならす。
// 2. 明暗差と彩度を少し下げ、全体を少し暗くする (背景はキャラより低いコントラストに。docs/art_direction.md)。
shader_type canvas_item;

// ならす範囲 (元画像のピクセル数)。大きいほど細部が消える
uniform int radius : hint_range(1, 6) = 2;
// 範囲全体の平均 (ぼかし) を混ぜる割合
uniform float blur_mix : hint_range(0.0, 1.0) = 0.4;
// 明暗差 (1 で元のまま、小さいほど pivot の明るさに寄る)。暗めの pivot に寄せて、明るい所だけを抑える
uniform float contrast : hint_range(0.0, 1.0) = 0.85;
uniform float pivot : hint_range(0.0, 1.0) = 0.25;
// 彩度 (1 で元のまま)
uniform float saturation : hint_range(0.0, 1.0) = 0.85;
// 明るさ (1 で元のまま)
uniform float brightness : hint_range(0.0, 1.0) = 0.9;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	// 4 区画 (左上 / 右上 / 左下 / 右下) の色の合計と、明るさの 2 乗の合計
	vec3 sum[4] = vec3[4](vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
	float lum_sum[4] = float[4](0.0, 0.0, 0.0, 0.0);
	float lum_sq[4] = float[4](0.0, 0.0, 0.0, 0.0);
	vec3 total = vec3(0.0);
	for (int y = -radius; y <= radius; y++) {
		for (int x = -radius; x <= radius; x++) {
			vec3 c = texture(TEXTURE, UV + vec2(float(x), float(y)) * px).rgb;
			float l = dot(c, vec3(0.299, 0.587, 0.114));
			total += c;
			// 中心の行・列はとなり合う 2 区画の両方に入れる
			for (int q = 0; q < 4; q++) {
				bool in_x = (q % 2 == 0) ? x <= 0 : x >= 0;
				bool in_y = (q < 2) ? y <= 0 : y >= 0;
				if (in_x && in_y) {
					sum[q] += c;
					lum_sum[q] += l;
					lum_sq[q] += l * l;
				}
			}
		}
	}
	float n = float((radius + 1) * (radius + 1));
	vec3 color = sum[0] / n;
	float best = 1e9;
	for (int q = 0; q < 4; q++) {
		float mean = lum_sum[q] / n;
		float variance = lum_sq[q] / n - mean * mean;
		if (variance < best) {
			best = variance;
			color = sum[q] / n;
		}
	}
	float side = float(radius * 2 + 1);
	color = mix(color, total / (side * side), blur_mix);
	float lum = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(lum), color, saturation);
	color = mix(vec3(pivot), color, contrast) * brightness;
	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
