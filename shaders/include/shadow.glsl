// ============================================================
// BLENDHER -------- shadow.glsl
// Cosine Distortion, PCF Filtering, Radial God Rays
// Requires: settings.glsl, uniforms.glsl
// ============================================================

// Distort shadow UVs toward center for better near-player resolution.
// SHADOW_DISTORTION = 0.9: 90% of resolution allocated to inner radius.
vec2 distortShadowUV(vec2 uv) {
    float d  = length(uv);
    float dm = mix(d, 1.0, SHADOW_DISTORTION);
    return uv / dm;
}

// Full shadow sampling: normal offset acne fix + PCF 3x3 soft edges
float getShadow(vec3 worldPos, vec3 worldNormal, sampler2D shadowMap) {
    // Normal offset: push surface along normal to prevent self-shadowing
    vec3 offs = worldPos + worldNormal * SHADOW_NORMAL_OFFSET;

    vec4 shadowClip = shadowProjection * shadowModelView * vec4(offs, 1.0);
    vec3 sNDC       = shadowClip.xyz / shadowClip.w;

    vec2  sUV    = sNDC.xy * 0.5 + 0.5;
    float sDepth = sNDC.z  * 0.5 + 0.5;

    // Apply distortion to match what was done in shadow.vsh
    sUV = distortShadowUV(sUV * 2.0 - 1.0) * 0.5 + 0.5;

    // Skip pixels outside shadow map bounds
    if (any(lessThan(sUV, vec2(0.0))) || any(greaterThan(sUV, vec2(1.0)))) {
        return 1.0; // outside shadow frustum = fully lit
    }

    // PCF 3x3: Percentage Closer Filtering for soft shadow edges
    float shadow = 0.0;
    vec2  tSz    = 1.0 / vec2(float(SHADOW_RESOLUTION));

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float stored = texture(shadowMap, sUV + vec2(x, y) * tSz).r;
            shadow += step(sDepth - 0.001, stored);
        }
    }

    return shadow / 9.0;
}

// Radial screen-space god rays (NOT volumetric -- safe for GTX 1650 Ti)
// sunPos: sun projected to 0-1 screen space
vec3 getGodRays(sampler2D col, vec2 uv, vec2 sunPos) {
    vec2  dv  = (uv - sunPos) / float(GODRAY_SAMPLES);
    float dec = 1.0;
    vec3  ray = vec3(0.0);
    vec2  suv = uv;

    for (int i = 0; i < GODRAY_SAMPLES; i++) {
        suv -= dv;
        // Clamp to screen bounds
        suv = clamp(suv, vec2(0.001), vec2(0.999));
        vec3  s   = texture(col, suv).rgb;
        float lum = dot(s, vec3(0.299, 0.587, 0.114));
        // Only bright sky pixels contribute -- not terrain
        ray += s * dec * step(0.8, lum);
        dec *= GODRAY_DECAY;
    }

    // Gate on sun-above-horizon: zero rays when sun is below ground
    float sunUp = max(0.0, dot(normalize(sunPosition), vec3(0.0, 1.0, 0.0)));

    return ray * GODRAY_STRENGTH / float(GODRAY_SAMPLES) * sunUp;
}
