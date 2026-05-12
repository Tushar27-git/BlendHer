# Phase 14: Performance Profiling & Debugging Guide

## Overview

Phase 14 focuses on performance profiling, optimization, and debugging of the BlendHer shader implementation. This guide provides systematic approaches to profiling, identifying bottlenecks, and validating correctness of all shader systems.

## Performance Profiling Methodology

### 14.1 Shader Performance Profiling on GTX 1650 Ti

**Objective**: Measure FPS in typical gameplay scenarios, identify performance bottlenecks, and profile each shader pass separately.

**Target Hardware**: NVIDIA GTX 1650 Ti
- VRAM: 4GB
- Memory Bandwidth: 192 GB/s
- Compute Capability: 7.5
- Max Texture Units: 32

**Performance Targets**:
- Minimum: 60 FPS
- Target: 90+ FPS in optimal conditions
- Budget: 16.67ms per frame (60 FPS)

**Profiling Approach**:

1. **Frame Time Measurement**
   - Use GPU timer queries (ARB_timer_query)
   - Measure total frame time
   - Measure per-pass time:
     - G-buffer passes: ~4ms
     - Deferred lighting: ~3ms
     - TAA resolve: ~2ms
     - Bloom: ~2ms
     - Post-processing: ~2ms
     - Headroom: ~3.67ms

2. **Bottleneck Identification**
   - Measure shader execution time per pass
   - Identify memory bandwidth bottlenecks
   - Check for texture cache misses
   - Monitor register pressure
   - Analyze instruction count

3. **Typical Gameplay Scenarios**
   - Outdoor daylight (high complexity)
   - Underground caves (medium complexity)
   - Dense forest (high complexity)
   - Open plains (low complexity)
   - Water surface (medium complexity)
   - Nether (high complexity)

**Profiling Tools**:
- NVIDIA FrameView (GPU profiling)
- NVIDIA NSight (detailed analysis)
- RenderDoc (frame capture and analysis)
- Iris debug output (shader timing)

**Expected Results**:
- GTX 1650 Ti: 60-90 FPS in typical gameplay
- Identify which passes consume most time
- Identify which scenarios are most demanding

---

### 14.2 Optimize Shader Compilation and Include Hierarchy

**Objective**: Minimize redundant includes, use preprocessor directives to skip unnecessary code, and profile compilation time.

**Current Include Structure**:
```
settings.glsl (configuration)
uniforms.glsl (shader uniforms)
utils.glsl (utility functions)
pbr.glsl (Cook-Torrance PBR)
lighting.glsl (PBR lighting)
tonemapping.glsl (ACES tonemapping)
atmosphere.glsl (fog, sky)
shadow.glsl (cascaded shadows)
water.glsl (Gerstner waves)
taa.glsl (temporal anti-aliasing)
velocity.glsl (velocity buffer)
material.glsl (material decoding)
blendstate.glsl (blend factor)
adaptiveQuality.glsl (quality scaling)
```

**Optimization Strategies**:

1. **Minimize Redundant Includes**
   - Each pass includes only needed functions
   - Use `#ifndef` guards to prevent double inclusion
   - Group related functions in single files

2. **Preprocessor Directives**
   - Use `#ifdef` to conditionally compile features
   - Skip unused features in specific passes
   - Example: `#ifdef ENABLE_TAA` for TAA-specific code

3. **Compilation Time Targets**
   - Target: <2 seconds total compilation
   - Measure per-pass compilation time
   - Identify slow-compiling passes

**Expected Results**:
- Compilation time <2 seconds
- No redundant includes
- Clear include hierarchy

---

### 14.3 Verify VRAM Usage Stays Under 150MB

**Objective**: Profile buffer allocations, optimize texture formats and sizes, and verify G-buffer layout efficiency.

**VRAM Budget Breakdown**:
- G-buffers: ~80MB (8 textures × 1920×1080 × 4 bytes)
- Shadow maps: ~32MB (2 cascades × 2048×2048 × 2 bytes)
- Bloom buffers: ~20MB (downsampled bloom chain)
- Miscellaneous: ~18MB (velocity, depth, etc.)
- **Total: <150MB**

**Profiling Approach**:

1. **Buffer Allocation Profiling**
   - Measure colortex0-4 sizes
   - Measure shadow map sizes
   - Measure bloom buffer sizes
   - Measure depth buffer sizes

2. **Texture Format Optimization**
   - colortex0: RGBA8 (4 bytes) - optimal
   - colortex1: RGBA8 (4 bytes) - optimal
   - colortex2: RGBA8 (4 bytes) - optimal
   - colortex3: RGBA8 (4 bytes) - optimal
   - colortex4: RG16F (4 bytes) - optimal for velocity
   - shadowtex0/1: R16 (2 bytes) - optimal for depth

3. **G-Buffer Layout Verification**
   - Verify all required data fits in 4 channels
   - Check for unused channels
   - Verify no data loss from quantization

**Expected Results**:
- Total VRAM usage <150MB
- All textures use optimal formats
- No wasted space in G-buffers

---

## Debugging Methodology

### 14.4 Debug Sky Rendering and Star Positioning

**Objective**: Verify dual sky detection works correctly, verify stars remain fixed in world-space, and test with various sky conditions.

**Dual Sky Detection**:
```glsl
bool isSky = (depth >= 1.0) || (texture2D(colortex2, texcoord).a < 0.5)
```

**Debugging Approach**:

1. **Verify Dual Sky Detection**
   - Check depth >= 1.0 detection
   - Check colortex2.a < 0.5 detection
   - Verify both methods agree
   - Test edge cases (near far plane)

2. **Verify Stars Remain Fixed in World-Space**
   - Stars should not move with camera
   - Stars should rotate with world rotation
   - Test by moving camera and checking star positions
   - Verify world-space coordinate calculation

3. **Test Various Sky Conditions**
   - Clear day (blue sky)
   - Sunset (orange/purple sky)
   - Night (dark sky with stars)
   - Stormy (grey sky)
   - Nether (red sky)
   - End (purple sky)

**Expected Results**:
- Dual sky detection works correctly
- Stars remain fixed in world-space
- Sky rendering matches expected appearance

---

### 14.5 Debug Gerstner Wave Displacement

**Objective**: Verify vertical displacement (not horizontal camera-relative), verify wave patterns match BSL aesthetic, and test with various water conditions.

**Gerstner Wave Equation**:
```glsl
displacement.y += amplitude * sin(frequency * (worldPos.x + worldPos.z) + phase + time)
```

**Debugging Approach**:

1. **Verify Vertical Displacement Only**
   - Check displacement.x == 0.0
   - Check displacement.z == 0.0
   - Check displacement.y != 0.0
   - Verify displacement is in world-space (not camera-relative)

2. **Verify Wave Patterns Match BSL Aesthetic**
   - Compare wave frequency with BSL
   - Compare wave amplitude with BSL
   - Compare wave phase with BSL
   - Verify smooth wave transitions

3. **Test Various Water Conditions**
   - Still water (no waves)
   - Calm water (small waves)
   - Rough water (large waves)
   - Underwater (caustic patterns)
   - Different water types (ocean, river, lake)

**Expected Results**:
- Vertical displacement only (no horizontal)
- Wave patterns match BSL aesthetic
- Smooth wave transitions

---

### 14.6 Debug Visual State Transitions

**Objective**: Verify smooth Hermite blend factor interpolation, verify no jarring color changes, and test all five visual states.

**Five Visual States**:
1. **Noon Vibrancy** (blend factor 1.0)
   - Full BSL saturation
   - Golden color grading
   - Invisible purple floor
   - Minimal fog (0.02)

2. **Creeping Shadows** (blend factor 0.0-0.3)
   - Reduced saturation
   - Darker tones
   - Active purple floor (0.3-0.6)
   - Moderate fog

3. **Sunset Purple Haze** (blend factor 0.2-0.8)
   - Transitional color grading
   - Growing purple floor (0.2-0.5)
   - Increasing fog

4. **Playable Midnight** (blend factor 0.1 + cyan tint)
   - Desaturated colors
   - Cyan tint (0.0, 0.6, 0.8)
   - Dominant purple floor (0.7-0.9)
   - Heavy fog (32+ block visibility)

5. **Storm** (blend factor 0.0 + grey-purple shivering)
   - Full desaturation
   - Grey-purple shivering
   - Dominant purple floor (0.8-1.0)
   - Reduced fog (40-50% of Spooklementary)

**Debugging Approach**:

1. **Verify Smooth Hermite Blend Factor Interpolation**
   - Check blend factor calculation
   - Verify Hermite smoothstep formula
   - Check transition timing (1200 ticks)
   - Verify no discontinuities

2. **Verify No Jarring Color Changes**
   - Monitor color changes frame-to-frame
   - Check for sudden jumps
   - Verify smooth gradients
   - Test at state boundaries

3. **Test All Five Visual States**
   - Set time to each state
   - Verify appearance matches expected
   - Check color grading
   - Check purple floor intensity
   - Check fog density

**Expected Results**:
- Smooth Hermite interpolation
- No jarring color changes
- All five states render correctly

---

### 14.7 Debug TAA and Motion Vectors

**Objective**: Verify velocity buffer calculation, verify TAA reprojection accuracy, and test with camera and object motion.

**Velocity Buffer Calculation**:
```glsl
vec2 velocity = (currentScreenPos - previousScreenPos) / frameTime
```

**Debugging Approach**:

1. **Verify Velocity Buffer Calculation**
   - Check current frame position calculation
   - Check previous frame position calculation
   - Verify velocity clamping
   - Test with known motion patterns

2. **Verify TAA Reprojection Accuracy**
   - Check reprojection formula
   - Verify disocclusion detection
   - Check history reset
   - Test with various motion speeds

3. **Test with Camera and Object Motion**
   - Camera movement (forward, backward, strafe, rotate)
   - Object movement (entities, particles)
   - Fast motion (high velocity)
   - Slow motion (low velocity)
   - Disocclusion (objects appearing/disappearing)

**Expected Results**:
- Velocity buffer calculated correctly
- TAA reprojection accurate
- No ghosting artifacts
- Smooth motion

---

### 14.8 Debug Cascaded Shadow Transitions

**Objective**: Verify cascade blending smooth, verify no visible cascade boundaries, and test shadow quality at different distances.

**Cascade Configuration**:
- Cascade 0: 0-64 blocks (high detail)
- Cascade 1: 64-128 blocks (medium detail)
- Cascade 2: 128-256 blocks (low detail)
- Cascade 3: 256+ blocks (fade out)

**Debugging Approach**:

1. **Verify Cascade Blending Smooth**
   - Check blend factor calculation
   - Verify smoothstep blending
   - Test at cascade boundaries
   - Verify no visible transitions

2. **Verify No Visible Cascade Boundaries**
   - Move camera across cascade boundaries
   - Check for shadow discontinuities
   - Verify smooth shadow transitions
   - Test with various light angles

3. **Test Shadow Quality at Different Distances**
   - Near shadows (high detail)
   - Medium shadows (medium detail)
   - Far shadows (low detail)
   - Shadow fade (256+ blocks)
   - Verify quality matches expectations

**Expected Results**:
- Cascade blending smooth
- No visible cascade boundaries
- Shadow quality appropriate for distance

---

## Debugging Tools and Techniques

### Visual Debugging

1. **Color Coding**
   - Render blend factor as color (0.0=black, 1.0=white)
   - Render cascade index as color (different colors per cascade)
   - Render material ID as color (different colors per material)
   - Render velocity as color (magnitude or direction)

2. **Wireframe Rendering**
   - Render shadow cascade boundaries
   - Render cascade split distances
   - Render velocity vectors

3. **Heatmaps**
   - Render frame time as heatmap
   - Render shader complexity as heatmap
   - Render memory bandwidth usage as heatmap

### Numerical Debugging

1. **Value Ranges**
   - Check blend factor in [0.0, 1.0]
   - Check colors in [0.0, 1.0]
   - Check normals normalized
   - Check velocities clamped

2. **Monotonicity**
   - Check blend factor transitions monotonic
   - Check fog factor monotonic with distance
   - Check shadow factor monotonic with depth

3. **Continuity**
   - Check no NaN/Inf values
   - Check smooth gradients
   - Check no discontinuities

### Performance Debugging

1. **Timing Analysis**
   - Measure per-pass execution time
   - Identify bottleneck passes
   - Profile shader complexity
   - Analyze memory bandwidth

2. **Memory Analysis**
   - Profile VRAM usage
   - Identify memory bottlenecks
   - Check texture cache efficiency
   - Analyze bandwidth utilization

3. **Compilation Analysis**
   - Measure compilation time
   - Identify slow-compiling passes
   - Analyze include dependencies
   - Check for redundant includes

---

## Validation Checklist

### Performance Validation
- [ ] GTX 1650 Ti achieves 60+ FPS
- [ ] Compilation time <2 seconds
- [ ] VRAM usage <150MB
- [ ] No frame rate drops below 60 FPS

### Visual Validation
- [ ] Sky rendering correct
- [ ] Stars fixed in world-space
- [ ] Water waves vertical only
- [ ] Visual state transitions smooth
- [ ] No jarring color changes
- [ ] All five visual states render correctly

### Technical Validation
- [ ] Velocity buffer calculated correctly
- [ ] TAA reprojection accurate
- [ ] No ghosting artifacts
- [ ] Cascade blending smooth
- [ ] No visible cascade boundaries
- [ ] Shadow quality appropriate

### Correctness Validation
- [ ] All blend factors in [0.0, 1.0]
- [ ] All colors in [0.0, 1.0]
- [ ] All normals normalized
- [ ] No NaN/Inf values
- [ ] Energy conservation maintained
- [ ] Smooth gradients throughout

---

## Next Steps

After completing Phase 14 profiling and debugging:

1. **Phase 15**: Compatibility & Final Integration
   - Test with Iris 1.8.5+ Fabric
   - Test with OptiFine
   - Test Distant Horizons integration
   - Test LabPBR 1.3 material support
   - Final visual quality review
   - Final performance review

2. **Phase 16**: Optional Advanced Features
   - Advanced water caustics
   - Parallax occlusion mapping
   - Screen-space reflections
   - Advanced cloud rendering
   - Lens flare effect
   - Chromatic aberration
   - Subsurface scattering
   - Porosity/wetness effects

