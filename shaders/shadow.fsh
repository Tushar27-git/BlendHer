#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- shadow.fsh
// Shadow map render pass -- fragment stage
// ============================================================

#include "/include/settings.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 color;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 albedo = texture(gtexture, texcoord) * color;
    if (albedo.a < 0.1) discard;
    fragColor = albedo;
}
