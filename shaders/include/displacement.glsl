// ============================================================
// BLENDHER -------- displacement.glsl
// Vertex-stage wind displacement and ground-lock math
// Requires: settings.glsl, uniforms.glsl
//
// Block IDs set in shaders.properties:
//   block.10001 = grass, short_grass, tall_grass, fern
//   block.10002 = oak_leaves, spruce_leaves, birch_leaves...
//   block.10003 = wheat, potatoes, carrots, beetroots...
// ============================================================

vec3 getWindDisplacement(vec3 worldPos, float entityId,
                          float timeSeconds, vec2 vaUV0,
                          float rainAmt) {
    vec3 d = vec3(0.0);

    // ---- Grass: two-axis sine for organic, non-repeating motion ----
    float grassW    = step(abs(entityId - 10001.0), 0.5);
    float grassWave = sin(timeSeconds * WIND_GRASS_FREQ + worldPos.x * 0.5)
                    * cos(timeSeconds * WIND_GRASS_FREQ * 0.7 + worldPos.z * 0.3);
    d.x += grassWave * WIND_GRASS_AMP * grassW;

    // ---- Leaves: Y-axis phase variation across leaf layers ----
    float leafW    = step(abs(entityId - 10002.0), 0.5);
    float leafWave = sin(timeSeconds * WIND_LEAVES_FREQ + worldPos.y * 0.2)
                   * sin(timeSeconds * WIND_LEAVES_FREQ * 1.3 + worldPos.x * 0.15);
    d.xz += vec2(leafWave) * WIND_LEAVES_AMP * leafW * vec2(1.0, 0.7);

    // ---- Crops: higher frequency = frantic motion in wind ----
    float cropW    = step(abs(entityId - 10003.0), 0.5);
    float cropWave = sin(timeSeconds * WIND_CROPS_FREQ + worldPos.z * 1.0);
    d.x += cropWave * WIND_CROPS_AMP * cropW;

    // ---- Rain multiplier: 1.8x amplitude in heavy rain ----
    d *= mix(1.0, RAIN_WIND_MULT, rainAmt);

    // ---- GROUND LOCK -- CRITICAL ----
    // Without this, all 4 vertices of a sprite move equally -> base floats.
    // Minecraft UV: top-left origin, so top vertex has vaUV0.y < 0.5.
    // step(0.5, vaUV0.y) = 1 for bottom vertices (V >= 0.5).
    // 1 - step(...) = 1 for top, 0 for bottom.
    float isTopVertex    = 1.0 - step(0.5, vaUV0.y);
    float needsGroundLock = max(grassW, cropW); // leaves swing freely
    float lockMult       = mix(1.0, isTopVertex, needsGroundLock);
    d *= lockMult;

    return d;
}
