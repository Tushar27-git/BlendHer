#version 150 compatibility
// ============================================================
// BLENDHER -- gbuffers_textured.vsh
// Textured pass (particles, overlays, breaking animation)
// ============================================================

out vec2 texcoord;
out vec4 color;

void main() {
    texcoord    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color       = gl_Color;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
