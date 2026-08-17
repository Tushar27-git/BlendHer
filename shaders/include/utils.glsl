// ============================================================
// BLENDHER -------- utils.glsl
// Math helpers and utility functions
// ============================================================

// Rec. 709 luma for desaturation math
float luma(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

// Remap a value from one range to another
float remap(float value, float inMin, float inMax, float outMin, float outMax) {
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin);
}

// Gamma 2.2 linearization (sRGB -> linear)
vec3 toLinear(vec3 srgb) {
    return pow(max(srgb, vec3(0.0001)), vec3(2.2));
}

// Linear -> sRGB gamma correction
vec3 toSRGB(vec3 linear) {
    return pow(max(linear, vec3(0.0001)), vec3(1.0 / 2.2));
}
