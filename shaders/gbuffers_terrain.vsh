#version 150 compatibility
// ============================================================
// BLENDHER -- gbuffers_terrain.vsh
// Terrain vertex pass + wind displacement
// FIX 1: Absolute include paths
// FIX 2: Function was called as applyWindDisplacement() but defined as
//         getWindDisplacement() in displacement.glsl -- name aligned
// FIX 3: getWindDisplacement() requires vaUV0 parameter for ground-lock math.
//         We pass (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy as vaUV0.
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/displacement.glsl"

attribute vec4 mc_Entity;

out vec2 texcoord;
out vec2 lightmap;
out vec3 normal;
out vec4 color;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightmap = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    normal   = normalize(gl_NormalMatrix * gl_Normal);
    color    = gl_Color;

    vec4 viewPos  = gl_ModelViewMatrix * gl_Vertex;
    vec3 worldPos = (gbufferModelViewInverse * viewPos).xyz;

    // Wind displacement -- vaUV0 used for ground-lock (top vs bottom vertex)
    vec2 vaUV0   = texcoord;
    float entityId = mc_Entity.x;
    vec3 disp = getWindDisplacement(worldPos, entityId, frameTimeCounter, vaUV0, rainStrength);
    worldPos += disp;

    viewPos     = gbufferModelView * vec4(worldPos, 1.0);
    gl_Position = gl_ProjectionMatrix * viewPos;
}
