// ============================================================
// BLENDHER -------- pbr.glsl
// Screen Space Reflections (SSR) via view-space raymarching
// Requires: settings.glsl, uniforms.glsl
// ============================================================

vec3 getSSR(vec3 viewPos, vec3 viewNormal, sampler2D sceneColor, sampler2D depthBuffer) {
    vec3 viewDir = normalize(viewPos);
    vec3 reflDir = reflect(viewDir, viewNormal);

    vec3 rayPos  = viewPos;
    vec3 rayStep = reflDir * 0.3; // step size in view space

    for (int i = 0; i < SSR_STEPS; i++) {
        rayPos += rayStep;

        // Project ray to screen space
        vec4 projected = gbufferProjection * vec4(rayPos, 1.0);
        projected      /= projected.w;
        vec2 screenUV   = projected.xy * 0.5 + 0.5;

        // Skip if ray has left screen
        if (any(lessThan(screenUV, vec2(0.0))) ||
            any(greaterThan(screenUV, vec2(1.0)))) break;

        float sceneDepth = texture(depthBuffer, screenUV).r;
        float rayDepth   = projected.z * 0.5 + 0.5;

        // Intersection: ray depth > scene depth AND within thickness tolerance
        if (rayDepth > sceneDepth && rayDepth - sceneDepth < SSR_THICKNESS) {
            // Fade out reflections near screen borders (avoids sharp cutoff)
            vec2  edgeFade = smoothstep(vec2(0.0), vec2(0.1), screenUV)
                           * smoothstep(vec2(1.0), vec2(0.9), screenUV);
            float fade = edgeFade.x * edgeFade.y;

            return texture(sceneColor, screenUV).rgb * fade;
        }
    }

    return vec3(0.0); // no intersection found -- caller uses sky fallback
}
