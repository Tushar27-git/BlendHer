#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- gbuffers_terrain.fsh
// Terrain fragment output to G-Buffers
// FIX 1: Absolute include paths
// FIX 2: DRAWBUFFERS:0123 with layout locations 0,1,2,3
//         Previously was DRAWBUFFERS:0124 with location 3 -- mismatch!
//         colortex3 is the lightmap buffer; layout location 3 writes to
//         the 4th slot in DRAWBUFFERS (index 3 = colortex3). Correct.
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
layout(location = 0) out vec4 outColor0;   // colortex0: albedo
layout(location = 1) out vec4 outColor1;   // colortex1: normal
layout(location = 2) out vec4 outColor2;   // colortex2: specular/PBR
layout(location = 3) out vec4 outColor3;   // colortex3: lightmap

void main() {
    vec4 albedo = texture(gtexture, texcoord) * color;
    if (albedo.a < 0.1) discard;

    albedo.rgb = toLinear(albedo.rgb);

    outColor0 = albedo;
    outColor1 = vec4(normal * 0.5 + 0.5, 1.0);
    outColor2 = vec4(0.0);                          // no PBR data for terrain
    outColor3 = vec4(lightmap / 240.0, 0.0, 1.0);  // normalize lightmap here
}
