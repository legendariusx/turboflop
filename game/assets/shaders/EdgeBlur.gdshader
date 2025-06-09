shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float blur_strength : hint_range(0.0, 1.0) = 0.5;
uniform float radius : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float blur = smoothstep(radius, 1.0, dist) * blur_strength;

    vec4 col = vec4(0.0);
    int samples = 8;
    float total = 0.0;

    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            vec2 offset = vec2(float(x), float(y)) / vec2(textureSize(screen_texture, 0)) * blur;
            col += texture(screen_texture, uv + offset);
            total += 1.0;
        }
    }

    col /= total;
    COLOR = col;
}
