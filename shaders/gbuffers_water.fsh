#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- gbuffers_water.fsh
// Water fragment pass -- absorption, aberration, normals
// FIX 1: Removed local declaration of depthtex1 (already in uniforms.glsl)
// FIX 2: Absolute include paths
// FIX 3: Named layout outputs instead of gl_FragData
// FIX 4: Removed duplicate Sampler0 -- use gtexture (standard Iris name)
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/utils.glsl"
#include "/include/water.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec2 lightmap;
in vec3 normal;
in vec4 color;
in vec3 viewPosV;
in vec3 worldPosV;

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 outColor0;
layout(location = 1) out vec4 outColor1;
layout(location = 2) out vec4 outColor2;
layout(location = 3) out vec4 outColor3;

void main() {
    vec4 baseColor = texture(gtexture, texcoord) * color;
    if (baseColor.a < 0.1) discard;

    baseColor.rgb = toLinear(baseColor.rgb);

    // Chromatic aberration at screen edges
    vec2 screenUV = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec2 aberr = getChromaticAberration(screenUV);

    float r = toLinear(vec3(texture(gtexture, texcoord + aberr).r)).r;
    float g = baseColor.g;
    float b = toLinear(vec3(texture(gtexture, texcoord - aberr).b)).r;
    vec3 aberratedColor = vec3(r, g, b) * color.rgb;

    // Water depth via difference between water surface and terrain behind it
    // depthtex1 is declared in uniforms.glsl -- NOT re-declared here
    float terrainDepthRaw = texture(depthtex1, screenUV).r;
    vec4 ndc = vec4(screenUV * 2.0 - 1.0, terrainDepthRaw * 2.0 - 1.0, 1.0);
    vec4 terrainViewPos = gbufferProjectionInverse * ndc;
    terrainViewPos /= terrainViewPos.w;

    float waterDepth = distance(viewPosV, terrainViewPos.xyz);
    vec3 waterColor  = applyWaterAbsorption(aberratedColor, waterDepth);

    // Night darkening
    float dayLight = lightmap.x / 240.0;
    waterColor = applyWaterNightDarken(waterColor, dayLight);

    // Perturb normal with Gerstner-derived normal
    vec3 waterNormal = getWaterNormal(worldPosV.xz, frameTimeCounter);
    vec3 finalNormal = normalize(normal + waterNormal * 0.8);

    outColor0 = vec4(waterColor, baseColor.a);
    outColor1 = vec4(finalNormal * 0.5 + 0.5, 1.0);
    outColor2 = vec4(0.0, 1.0, 0.0, 1.0);  // g=1.0 flags water for SSR in composite
    outColor3 = vec4(lightmap / 240.0, 0.0, 1.0);
}
