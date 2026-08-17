// ============================================================
// BLENDHER -------- atmosphere.glsl
// Exponential fog, DH fog wall, rain desaturation
// Requires: settings.glsl, uniforms.glsl
// ============================================================

// Derive fog color from sky: desaturate 15%, add purple shift
vec3 getFogColor(vec3 skyColor) {
    float luma_val = dot(skyColor, vec3(0.299, 0.587, 0.114));
    vec3  desat    = mix(skyColor, vec3(luma_val), FOG_SAT_REDUCE);
    // Subtle purple push: red+0.025, blue+0.05
    desat += vec3(FOG_PURPLE_SHIFT * 0.5, 0.0, FOG_PURPLE_SHIFT);
    return desat;
}

float getFogDensity(float viewDist) {
    // Exponential fog: fog = 1 - exp(-density * distance)
    float localFog = 1.0 - exp(-FOG_DENSITY * max(viewDist - FOG_START, 0.0));

    // DH fog wall: ramps 0->0.9 over 300 unit transition zone
    // Hides the visual seam where normal chunks meet LOD geometry
    float dhFog = smoothstep(FOG_DH_START, FOG_DH_END, viewDist) * 0.9;

    return max(localFog, dhFog);
}

vec3 applyFog(vec3 scene, vec3 sky, float viewDist) {
    vec3  fogColor = getFogColor(sky);
    float fogFact  = getFogDensity(viewDist);

    // Rain: desaturate scene (not add fog density -- keeps visibility >= 32 blocks)
    float rainDesat  = rainStrength * RAIN_DESAT;
    float sceneLuma  = dot(scene, vec3(0.299, 0.587, 0.114));
    scene = mix(scene, vec3(sceneLuma), rainDesat);

    return mix(scene, fogColor, fogFact);
}
