#version 150 compatibility
// ============================================================
// BLENDHER -- shadow.vsh
// Shadow map render pass -- vertex stage
// FIX: All #include paths changed to absolute (/include/...)
//      Uniforms (shadowProjection, shadowModelView, sunPosition)
//      are declared in /include/uniforms.glsl -- do NOT re-declare here.
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/shadow.glsl"

out vec2 texcoord;
out vec4 color;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color    = gl_Color;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 projPos = gl_ProjectionMatrix * viewPos;

    // Apply cosine distortion for better near-player shadow resolution
    vec2 shadowUV = projPos.xy / projPos.w;
    shadowUV      = distortShadowUV(shadowUV);
    projPos.xy    = shadowUV * projPos.w;

    gl_Position = projPos;
}
