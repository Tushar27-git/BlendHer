#version 150 compatibility
// ============================================================
// BLENDHER -- gbuffers_water.vsh
// Water vertex pass -- Gerstner wave displacement
// FIX: Absolute include paths
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/water.glsl"

out vec2 texcoord;
out vec2 lightmap;
out vec3 normal;
out vec4 color;
out vec3 viewPosV;
out vec3 worldPosV;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightmap = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    normal   = normalize(gl_NormalMatrix * gl_Normal);
    color    = gl_Color;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec3 worldPos = (gbufferModelViewInverse * viewPos).xyz;

    // Gerstner wave vertex displacement (two-layer organic surface)
    vec3 w1 = gerstnerWave(worldPos.xz, frameTimeCounter,
                           normalize(vec2(1.0, 0.6)),
                           WATER_WAVE_FREQ, WATER_WAVE_AMP, 0.8);
    vec3 w2 = gerstnerWave(worldPos.xz * 1.5, frameTimeCounter,
                           normalize(vec2(-0.7, 1.0)),
                           WATER_WAVE_FREQ * 1.3, WATER_WAVE_AMP * 0.6, 1.1);
    vec3 disp = mix(w1, w2, 0.5);

    worldPos += disp;
    viewPos   = gbufferModelView * vec4(worldPos, 1.0);

    viewPosV  = viewPos.xyz;
    worldPosV = worldPos;

    gl_Position = gl_ProjectionMatrix * viewPos;
}
