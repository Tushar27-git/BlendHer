// ============================================================
// BLENDHER -------- water.glsl
// Gerstner Waves, Beer-Lambert Absorption, Chromatic Aberration
// Requires: settings.glsl
// ============================================================

// ---------- VERTEX STAGE: GERSTNER WAVES ------------------------------------

// Single Gerstner wave: circular arc motion (peaked crests, flat troughs)
// dir: wave travel direction (normalized)
// freq: spatial frequency, amp: height, spd: time speed
vec3 gerstnerWave(vec2 pos, float t, vec2 dir, float freq, float amp, float spd) {
    float ph = dot(dir, pos) * freq + t * spd;
    return vec3(
        amp * dir.x * cos(ph),   // X: forward/back
        amp * sin(ph),            // Y: up/down
        amp * dir.y * cos(ph)    // Z: lateral
    );
}

// Two-layer Gerstner blend for organic, non-repeating surface
vec3 getWaterNormal(vec2 worldUV, float t) {
    vec3 w1 = gerstnerWave(worldUV, t,
                           normalize(vec2(1.0, 0.6)),
                           WATER_WAVE_FREQ, WATER_WAVE_AMP, 0.8);
    vec3 w2 = gerstnerWave(worldUV * 1.5, t,
                           normalize(vec2(-0.7, 1.0)),
                           WATER_WAVE_FREQ * 1.3, WATER_WAVE_AMP * 0.6, 1.1);

    vec3 combined = mix(w1, w2, 0.5);
    return normalize(vec3(combined.x * 2.0, 1.0, combined.z * 2.0));
}

// ---------- FRAGMENT STAGE: ABSORPTION & COLOR ------------------------------

// Beer-Lambert: light absorbed by depth, wavelength-selective
// Red absorbs fastest -> deep water looks teal
vec3 applyWaterAbsorption(vec3 color, float depth) {
    vec3 ab = vec3(WATER_ABSORB_R, WATER_ABSORB_G, WATER_ABSORB_B);
    // * 8.0: at depth 1 block, blue channel = exp(-0.1*8) = 0.45 (55% absorbed)
    return color * exp(-ab * depth * 8.0);
}

// Night darkening: water becomes teal-black mirror at midnight
vec3 applyWaterNightDarken(vec3 waterColor, float dayLight) {
    float dark = 1.0 - dayLight * WATER_NIGHT_DARKEN;
    return waterColor * vec3(dark * 0.85, dark, dark * 0.95);
}

// Chromatic aberration: R/B channels offset toward screen edges (lens sim)
vec2 getChromaticAberration(vec2 screenUV) {
    vec2  center = screenUV - 0.5;
    float dist   = length(center);
    return center * dist * WATER_CHROMA_ABERR;
}
