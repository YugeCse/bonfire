shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

// 可调节参数
uniform float border_width : hint_range(0, 0.5) = 0.1;
uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // 红色边框示例

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float radius = 0.5;
    float distance = length(UV - center);

    // 主圆形区域（白色）
    if (distance <= radius) {
        COLOR = vec4(0.8);
    }

    // 边框区域
    if (distance > radius - border_width && distance <= radius) {
        COLOR = border_color;
    }

    // 透明背景
    if (distance > radius) {
        discard;
    }
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
