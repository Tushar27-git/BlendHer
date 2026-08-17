// ============================================================
// BLENDHER -------- tonemapping.glsl
// ACES filmic curve + Spooklementary horror shadow crush
// ============================================================

vec3 horrorTonemap(vec3 hdrColor) {
    // ACES input matrix (linear -> ACES color space)
    const mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
    );

    // RRT+ODT fast approximation (OHara fit)
    vec3 v    = m1 * hdrColor;
    vec3 a    = v * (v + 0.0245786) - 0.000090537;
    vec3 b    = v * (0.983729 * v + 0.4329510) + 0.238081;
    vec3 aces = clamp(a / b, 0.0, 1.0);

    // Horror shadow crush: pow(x, 1.15) darkens shadows, barely touches highlights
    // pow(0.5, 1.15) = 0.478 (midtones ~6% darker)
    // pow(0.1, 1.15) = 0.072 (shadows ~28% darker)
    vec3 crushed = pow(aces, vec3(HORROR_SHADOW_CRUSH));

    return pow(crushed, vec3(1.0 / 2.2)); // gamma to sRGB
}

// Dark scenes get horror curve, bright scenes get standard ACES
vec3 blendHerTonemap(vec3 hdrColor, float lightLevel) {
    float horrorBlend = 1.0 - smoothstep(0.02, 0.15, lightLevel);

    vec3 horror = horrorTonemap(hdrColor);

    vec3 standard = pow(clamp(
        (hdrColor * (hdrColor + 0.0245786) - 0.000090537) /
        (hdrColor * (0.983729 * hdrColor + 0.432951) + 0.238081),
        0.0, 1.0), vec3(1.0 / 2.2));

    return mix(standard, horror, horrorBlend);
}
