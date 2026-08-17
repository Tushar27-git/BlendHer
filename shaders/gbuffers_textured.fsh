#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- gbuffers_textured.fsh
// Textured fragment pass (particles, overlays)
// FIX: Absolute include paths
// ============================================================

#include "/include/settings.glsl"
#include "/include/utils.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 color;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

void main() {
    vec4 albedo = texture(gtexture, texcoord) * color;
    if (albedo.a < 0.1) discard;
    albedo.rgb = toLinear(albedo.rgb);
    outColor0  = albedo;
}
