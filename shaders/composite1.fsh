#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- composite1.fsh
// Bloom -- horizontal Gaussian blur pass
// FIX 1: Absolute include paths
// FIX 2: Loop variable must be 'int', not 'float'
//         float loop variable causes: "OpenGL first class arrays require #version 120"
// FIX 3: Named layout output (fragColor) instead of gl_FragData
// FIX 4: Bloom bright-pass reads from colortex0 (lit scene from composite.fsh)
//         and outputs bright-pass to colortex3 buffer slot
// ============================================================

#include "/include/settings.glsl"
#include "/include/uniforms.glsl"

in vec2 texcoord;

/* DRAWBUFFERS:3 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec3  bloom       = vec3(0.0);
    float totalWeight = 0.0;

    vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
    int  radius = int(BLOOM_RADIUS);   // BLOOM_RADIUS = 7.0

    // Horizontal 1D Gaussian blur (separable -- 15 samples not 225)
    // int loop variable required for GLSL 1.30 arrays
    for (int i = -radius; i <= radius; i++) {
        float fi     = float(i);
        float weight = exp(-0.5 * (fi * fi) / (BLOOM_RADIUS * BLOOM_RADIUS));
        vec2  offset = vec2(fi * texel.x, 0.0);
        vec3  sample = texture(colortex0, texcoord + offset).rgb;

        // Bright-pass: only luminance above threshold contributes to bloom
        float lum = dot(sample, vec3(0.2126, 0.7152, 0.0722));
        bloom       += sample * weight * step(BLOOM_THRESHOLD, lum);
        totalWeight += weight;
    }

    fragColor = vec4(bloom / totalWeight, 1.0);
}
