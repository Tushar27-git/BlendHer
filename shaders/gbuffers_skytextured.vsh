#version 150 compatibility
// ============================================================
// BLENDHER -- gbuffers_skytextured.vsh
// Sky textured pass (sun, moon, stars)
// ============================================================

out vec2 texcoord;
out vec4 color;

void main() {
    texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color       = gl_Color;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
