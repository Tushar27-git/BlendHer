#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- composite2.fsh
// Bloom -- vertical Gaussian blur + composite onto scene
// FIX 1: Absolute include paths
// FIX 2: int loop variable (not float)
// FIX 3: Named layout output
// FIX 4: Reads horizontal blur result from colortex3,
//         composites onto scene in colortex0
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec3  bloom       = vec3(0.0);
    float totalWeight = 0.0;

    vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
    int  radius = int(BLOOM_RADIUS);

    // Vertical 1D Gaussian blur (second pass of separable bloom)
    // Reads from colortex3 which holds the horizontal blur from composite1.fsh
    for (int i = -radius; i <= radius; i++) {
        float fi     = float(i);
        float weight = exp(-0.5 * (fi * fi) / (BLOOM_RADIUS * BLOOM_RADIUS));
        vec2  offset = vec2(0.0, fi * texel.y);
        vec3  sample = texture(colortex3, texcoord + offset).rgb;

        bloom       += sample * weight;
        totalWeight += weight;
    }

    // Add blurred bloom onto the lit scene
    vec3 scene = texture(colortex0, texcoord).rgb;
    vec3 bloomResult = (bloom / totalWeight) * BLOOM_STRENGTH;

    fragColor = vec4(scene + bloomResult, 1.0);
}
