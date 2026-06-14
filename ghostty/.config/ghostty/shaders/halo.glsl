// Soft halo: light amber bloom around the text. Shadertoy-style (Ghostty).
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    // approximate blur (9 taps) for the halo
    vec3 bloom = vec3(0.0);
    float r = 1.6 / iResolution.y;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 off = vec2(float(x), float(y)) * r;
            bloom += texture(iChannel0, uv + off).rgb;
        }
    }
    bloom /= 9.0;

    // amber tint + soft intensity (tune 0.35 to taste)
    vec3 amber = vec3(1.0, 0.706, 0.329); // #FFB454
    vec3 glow = bloom * amber * 0.35;

    fragColor = vec4(base.rgb + glow, base.a);
}
