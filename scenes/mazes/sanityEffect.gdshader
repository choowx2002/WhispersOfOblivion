shader_type canvas_item;

uniform float sanity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec3 col = texture(SCREEN_TEXTURE, uv).rgb;

    float vignette_strength = 0.0;
    float shake = 0.0;
    float chroma_offset = 0.0;
    float noise_strength = 0.0;

    float cycle = mod(TIME, 10.0);
    float pulse = smoothstep(0.0, 0.2, cycle) * (1.0 - smoothstep(1.8, 2.0, cycle));

    if (sanity > 0.7) {
        vignette_strength = 0.9;
    } else if (sanity > 0.3) {
        vignette_strength = 0.75;
        shake = 0.003 * (1.0 - sanity) * pulse;
        chroma_offset = 0.002 * (1.0 - sanity) * pulse;
        noise_strength = 0.05 * (1.0 - sanity);
    } else {
        vignette_strength = 0.6;
        shake = 0.005 * (1.0 - sanity) * pulse;
        chroma_offset = 0.003 * (1.0 - sanity) * pulse;
        noise_strength = 0.08 * (1.0 - sanity);
    }

    uv.x += sin(TIME * 20.0) * shake;
    uv.y += cos(TIME * 15.0) * shake;

    col.r = texture(SCREEN_TEXTURE, uv + vec2(chroma_offset * 1.2, 0)).r;
    col.g = texture(SCREEN_TEXTURE, uv - vec2(chroma_offset * 0.3, 0)).g;
    col.b = texture(SCREEN_TEXTURE, uv - vec2(chroma_offset * 0.5, 0)).b;

    float noise = (rand(uv * TIME) - 0.5) * noise_strength;
    col += noise;

    vec2 center = uv - 0.5;
    float vignette = 1.0 - smoothstep(vignette_strength, 1.0, length(center));
    col *= vignette;

    COLOR = vec4(col, 1.0);
}
