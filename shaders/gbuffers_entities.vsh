#version 150 compatibility
// ============================================================
// BLENDHER -- gbuffers_entities.vsh
// Entity vertex pass (mobs, players, item frames)
// FIX: Absolute include paths
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"

out vec2 texcoord;
out vec2 lightmap;
out vec3 normal;
out vec4 color;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightmap = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    normal   = normalize(gl_NormalMatrix * gl_Normal);
    color    = gl_Color;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
