// ============================================================
// BLENDHER -------- lighting.glsl
// Core Soul: BSL<->Spook branchless mode switch
// Requires: settings.glsl, utils.glsl, uniforms.glsl
// ============================================================

vec3 applyBlendHerLighting(vec3 albedo, float skyLight, float blockLight, vec3 worldNormal) {
    // Inputs: skyLight and blockLight are pre-normalized 0-1 (divided by 240)

    // STEP 1: Combined light level
    float totalLight = max(skyLight, blockLight);

    // STEP 2: BSL-Mode -- warm, saturated, golden near torches/sun
    vec3 bslColor = albedo * mix(vec3(1.0),
                                  vec3(BSL_WARMTH_R, BSL_WARMTH_G, BSL_WARMTH_B),
                                  blockLight);

    // STEP 3: Spook-Mode -- desaturated, olive-purple shadows
    float luma_val  = luma(albedo);
    vec3 desatColor = mix(albedo, vec3(luma_val), SPOOK_DESAT);
    vec3 spookColor = desatColor + vec3(0.015, 0.0, 0.03);

    // STEP 4: Branchless crossfade -- NO if/else (GPU warp divergence)
    // smoothstep returns 0 in shadow zone, 1 in lit zone
    float modeBlend = smoothstep(AMBIENT_THRESHOLD,
                                  AMBIENT_THRESHOLD + AMBIENT_BLEND_WIDTH,
                                  totalLight);
    vec3 litColor = mix(spookColor, bslColor, modeBlend);

    // STEP 5: Purple ambient floor -- ADDITIVE (multiplicative collapses black)
    vec3  ambiFloor = vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B);
    float floorFade = smoothstep(0.0, 0.1, totalLight);
    litColor = mix(litColor + ambiFloor, litColor, floorFade);

    // STEP 6: Half-Lambert diffuse (softer terminator than standard NdotL)
    vec3  sunDir = normalize(vec3(0.3, 1.0, 0.5));
    float NdotL  = dot(worldNormal, sunDir);
    float diffuse = clamp(NdotL * 0.5 + 0.5, 0.0, 1.0);
    litColor *= diffuse;

    // STEP 7: Moonlight cyan tint at night (branchless via worldTime fraction)
    float dayFrac = float(worldTime) / 24000.0;
    float isNight = smoothstep(0.45, 0.55, dayFrac)
                  - smoothstep(0.95, 1.0,  dayFrac);
    vec3 moonTint = vec3(MOON_CYAN_R, MOON_CYAN_G, MOON_CYAN_B);
    litColor = mix(litColor,
                   litColor * moonTint * (1.0 + MOON_INTENSITY),
                   isNight * skyLight * 0.6);

    return litColor;
}
