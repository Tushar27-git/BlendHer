// ============================================================
// BLENDHER -------- uniforms.glsl
// Centralized uniform declarations
// ============================================================

uniform sampler2D colortex0;    // albedo (RGBA8)
uniform sampler2D colortex1;    // world normals (RGB8_SNORM)
uniform sampler2D colortex2;    // specular / PBR flags (RGBA8)
uniform sampler2D colortex3;    // lightmap RG / bloom pass (RGBA8)

uniform sampler2D depthtex0;    // main scene depth
uniform sampler2D depthtex1;    // translucent / water depth
uniform sampler2D shadowtex0;   // shadow depth map
uniform sampler2D shadowcolor0; // shadow color (colored shadows)

#ifdef DISTANT_HORIZONS
uniform sampler2D dhDepthTex0;  // Distant Horizons LOD depth
#endif

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform int   worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
