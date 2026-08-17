#version 150 compatibility
#extension GL_ARB_explicit_attrib_location : enable
// ============================================================
// BLENDHER -- final.fsh
// Screen output pass -- reads composite result and outputs to display
// FIX 1: Added #version directive (was missing -- caused "texture() needs #version 130")
// FIX 2: Named layout output 'fragColor' instead of undefined 'outColor0'
// ============================================================

uniform sampler2D colortex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 fragColor;

void main() {
    vec3 color = texture(colortex0, texcoord).rgb;
    fragColor  = vec4(color, 1.0);
}
