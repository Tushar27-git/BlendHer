#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- composite.fsh
// Main deferred pass: lighting, shadows, fog, god rays, SSR
// FIX 1: Absolute include paths
// FIX 2: Named layout output (fragColor) instead of gl_FragData
// FIX 3: lightmap read from colortex3 (mapped from water pass outColor3)
//         and from terrain pass which outputs to colortex3 index in DRAWBUFFERS
// FIX 4: dhDepthTex0 guarded with #ifdef for non-DH setups
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/utils.glsl"
#include "/include/lighting.glsl"
#include "/include/shadow.glsl"
#include "/include/atmosphere.glsl"
#include "/include/tonemapping.glsl"
#include "/include/pbr.glsl"

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4  albedo   = texture(colortex0, texcoord);
    vec3  normal   = texture(colortex1, texcoord).rgb * 2.0 - 1.0;
    float depth    = texture(depthtex0, texcoord).r;
    // colortex3 stores the lightmap (R=sky, G=block) written by terrain/entity passes
    vec2  lightmap = texture(colortex3, texcoord).rg;  // already /240 from gbuffers

    // Sky / background pixels -- pass through unlit
    if (depth >= 1.0) {
        fragColor = vec4(albedo.rgb, 1.0);
        return;
    }

    // Reconstruct view-space position from depth
    vec4 ndc     = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * ndc;
    viewPos     /= viewPos.w;
    float vDist  = length(viewPos.xyz);

    // Reconstruct world position and world-space normal
    vec3 worldPos    = (gbufferModelViewInverse * viewPos).xyz;
    vec3 worldNormal = mat3(gbufferModelViewInverse) * normal;

    // === LIGHTING: BSL <-> Spook branchless switch ===
    vec3 lit = applyBlendHerLighting(albedo.rgb, lightmap.r, lightmap.g, worldNormal);

    // === SHADOWS: PCF 3x3 ===
    float shadow = getShadow(worldPos, worldNormal, shadowtex0);
    lit *= mix(vec3(0.08, 0.08, 0.12), vec3(1.0), shadow);

    // === SSR for water surfaces ===
    // colortex2 g-channel == 1.0 marks water pixels (set in gbuffers_water.fsh)
    float isWater = step(0.5, texture(colortex2, texcoord).g);
    if (isWater > 0.5) {
        vec3 ssr = getSSR(viewPos.xyz, normal, colortex0, depthtex0);
        lit += ssr * WATER_REFLECT_STRENGTH;
    }

    // === GOD RAYS: radial screen-space blur ===
    vec4 sunProj   = gbufferProjection * gbufferModelView * vec4(sunPosition, 1.0);
    vec2 sunScreen = (sunProj.xy / sunProj.w) * 0.5 + 0.5;
    lit += getGodRays(colortex0, texcoord, sunScreen);

    // === DISTANT HORIZONS fog wall ===
    // dhDepthTex0 is provided by Iris when iris.features=DISTANT_HORIZONS
#ifdef DISTANT_HORIZONS
    float dhDepth   = texture(dhDepthTex0, texcoord).r;
    bool  useDH     = (dhDepth < depth) && (dhDepth < 0.9999);
    if (useDH) {
        vec4 dhNdc     = vec4(texcoord * 2.0 - 1.0, dhDepth * 2.0 - 1.0, 1.0);
        vec4 dhViewPos = gbufferProjectionInverse * dhNdc;
        vDist = length((dhViewPos / dhViewPos.w).xyz);
    }
#endif

    // === FOG ===
    // Sample sky color from top of screen (sky texture rendered into colortex0)
    vec3 sky = texture(colortex0, vec2(0.5, 0.999)).rgb;
    lit = applyFog(lit, sky, vDist);

    // === TONEMAPPING: horror curve blend ===
    lit = blendHerTonemap(lit, max(lightmap.r, lightmap.g));

    fragColor = vec4(lit, albedo.a);
}
