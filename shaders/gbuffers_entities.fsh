#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- gbuffers_entities.fsh
// Entity fragment pass
// FIX 1: Absolute include paths
// FIX 2: DRAWBUFFERS and layout aligned with terrain (0123)
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"
#include "/include/utils.glsl"

uniform sampler2D gtexture;

in vec2 texcoord;
in vec2 lightmap;
in vec3 normal;
in vec4 color;

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 outColor0;
layout(location = 1) out vec4 outColor1;
layout(location = 2) out vec4 outColor2;
layout(location = 3) out vec4 outColor3;

void main() {
    vec4 albedo = texture(gtexture, texcoord) * color;
    if (albedo.a < 0.1) discard;

    albedo.rgb = toLinear(albedo.rgb);

    outColor0 = albedo;
    outColor1 = vec4(normal * 0.5 + 0.5, 1.0);
    outColor2 = vec4(0.0);
    outColor3 = vec4(lightmap / 240.0, 0.0, 1.0);
}
